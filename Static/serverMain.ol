init {
  // Inizializzo lo stato del server
  scope( initServer ) {
    with(global.status) {
      .currentTerm = 0 |
      .votedFor = undefined |
      with(.log[0]) {
        .term = 0 |
        .entry = void
      } |
      .commitIndex = 0 |
      .lastApplied = 0 |
      .leader = false |
      .candidate = false |
      .follower = true |
      //.myID = 1 | // #dynamic
      .lastIndexOfLog = 0
    };

    for(i = 0, i < 4, i++) {
      global.status.nextIndices[i] = 1;
      global.status.matchIndices[i] = 0
    }
  };

  scope( initSemaphores ) {
    // Semaforo che permette di eseguire sulla macchina la richiesta che è stata replicata dalla maggiorparte dei server
    with( global.replicationSemaphore ) {
      .name = "LogReplication" |
      .permits = 1
    } | // Semafori per la gestione dell'ordine di esecuzione delle richieste
    with(global.executionSemaphores[0]) {
      .name = new |
      .permits = 1
    };

    release@SemaphoreUtils(global.executionSemaphores[0])(res)
  };

  // Inizializzo i dati per il Network Visualizer
  scope( initNetworVisualizer ) {
    with( global.visualizer ) {
      .leader.id = global.status.myID |
      .leader.port = "socket://localhost:800" + global.status.myID |
      .items = void |
      .carts = void
    };

    for(i = 0, i < 5, i++)
      global.visualizer.servers.status[i] = true
  };

  // Parte il timer per l'elezione
  setElectionTimer
}

main {

  /* --- ELECTION --- */

  [RequestVote(request)(response) {
    if(request.term > global.status.currentTerm) {
      global.status.currentTerm = request.term;
      synchronized( serverRoleToken ) {
        global.status.candidate = false ; global.status.follower = true ; global.status.leader = false

      };
      undef(global.status.votedFor);

      synchronized( nextIndicesToken ) {
        for(i = 0, i < #global.status.nextIndices, i++)
          global.status.nextIndices[i] = global.status.lastIndexOfLog + 1
      };
      synchronized( matchIndicesToken ) {
        for(i = 0, i < #global.status.matchIndices, i++)
          global.status.matchIndices[i] = 0
      };

      setElectionTimer // Faccio ripartire il timer solo se "entro" in un nuovo termine, in quanto il mio era vecchio [verificato con la simulazione]
    };

    ourLastLogTerm = -1;
    synchronized( lastIndexOfLogToken ) {
      if(global.status.lastIndexOfLog != 0)
        ourLastLogTerm = global.status.log[global.status.lastIndexOfLog].term;
      ourLastLogIndex = global.status.lastIndexOfLog
    };

    synchronized( votedForToken ) {
      if( request.term >= global.status.currentTerm && // Se il termine del candidato è maggiore uguale al mio
          request.lastLogIndex >= ourLastLogIndex && // Se il server che richiede il voto non è più indietro di me nel log
          request.lastLogTerm >= ourLastLogTerm && // il termine dell'ultimo elemento del log combacia (controllo di sicurezza)
          (!is_defined(global.status.votedFor) || // e non ho già votato per qualcuno (in questo termine)
          global.status.votedFor == request.candidateID) // o chi ho già votato è lo stesso che mi chiede il voto adesso
        ) {
        global.status.votedFor = request.candidateID;
        response.VoteGranted = true;
        response.Term = global.status.currentTerm
      } else {
        response.VoteGranted = false;
        response.Term = global.status.currentTerm
      }
    };

    println@Console( "Vote " + response.VoteGranted + " to " + request.candidateID )()
  }]  {nullProcess}

  /* --- COMMUNICATION --- */

  [AppendEntries(appendEntriesRequest)] {
    csets.serverSID = appendEntriesRequest.leaderID;
    println@Console()();
    synchronized( operationOnLogToken ) {
      for ( i = 0, i < #global.status.log, i++ )
        print@Console( "[" + i + ", " + global.status.log[i].term + "]" )()
    };
    println@Console()();
    success = false;

    if (appendEntriesRequest.term >= global.status.currentTerm) { // Se il termine della richiesta è maggiore divento follower e aggiorno il mio termine
      scope(checkTermOutOfDate) {
        synchronized( currentTermToken ) {
          if(appendEntriesRequest.term > global.status.currentTerm) {
            global.status.currentTerm = appendEntriesRequest.term;
            synchronized( serverRoleToken ) {
              global.status.candidate = false ; global.status.follower = true ; global.status.leader = false
            };
            undef(global.status.votedFor);

            synchronized( nextIndicesToken ) {
              for(i = 0, i < #global.status.nextIndices, i++)
                global.status.nextIndices[i] = global.status.lastIndexOfLog + 1
            };
            synchronized( matchIndicesToken ) {
              for(i = 0, i < #global.status.matchIndices, i++)
                global.status.matchIndices[i] = 0
            }
          }
        }
      } |
      scope(setElectionTimer) {
        setElectionTimer
      };

      if(is_defined( ackResponse.replicatedTerm ))
        undef( ackResponse.replicatedTerm );
      if(is_defined( ackResponse.replicatedIndex ))
        undef( ackResponse.replicatedIndex );

      synchronized( operationOnLogToken ) {
        if(appendEntriesRequest.term == global.status.currentTerm) {
          if(appendEntriesRequest.prevLogIndex <= global.status.lastIndexOfLog &&
             global.status.log[appendEntriesRequest.prevLogIndex].term == appendEntriesRequest.prevLogTerm) {
            success = true;
            global.status.leaderAddress = int(csets.serverSID); // Se è un'appendEntries valida, imposto l'indirizzo del leader
            println@Console("Server " + global.status.myID + " - Leader Address " + global.status.leaderAddress)();
            index = appendEntriesRequest.prevLogIndex + 1;

            if(is_defined(appendEntriesRequest.entries[0])) {
              if(index >= global.status.lastIndexOfLog + 1 || global.status.log[index].term != appendEntriesRequest.entries[0].term) {
                // Cancello tutte le entries del log successive
                for(j = index, j < #global.status.log, j++)
                  undef(global.status.log[j]);
                // Riempio il log con l'entry corretta
                global.status.log[index] << appendEntriesRequest.entries[0];
                // Aggiorno la posizione dell'ultimo elemento del log
                synchronized( lastIndexOfLogToken ) {
                  global.status.lastIndexOfLog = index
                };

                ackResponse.replicatedIndex = index;
                ackResponse.replicatedTerm = appendEntriesRequest.entries[0].term
              } else if(global.status.log[index].term == appendEntriesRequest.entries[0].term) {
                synchronized( lastIndexOfLogToken ) {
                  global.status.lastIndexOfLog = index
                }
              }
            };

            // Se commitIndex è inferiore a quello del leader, lo imposto come il minore tra l'ultimo elemento del log e l'indice di commit del leader (in caso contrario ho committato più del leader quindi non faccio niente) [da verificate: un server non può avere mai commitIndex > leaderCommit, al massimo uguale, se no il leader non sarebbe salito]
            synchronized( commitIndexToken ) {
              if(appendEntriesRequest.leaderCommit > global.status.commitIndex)
                synchronized( lastIndexOfLogToken ) {
                  if(appendEntriesRequest.leaderCommit < global.status.lastIndexOfLog)
                    global.status.commitIndex = appendEntriesRequest.leaderCommit
                  else
                    global.status.commitIndex = global.status.lastIndexOfLog
                };

              // Se ho eseguito meno dell'indice di commit, mi metto in pari (indice compreso), è synchronized in quanto se diventa leader durante questa esecuzione attende prima il termine e poi esegue le altre richieste
              synchronized( executionToken ) {
                if(global.status.commitIndex > global.status.lastApplied)
                  for(i = global.status.lastApplied + 1, i <= global.status.commitIndex, i++) {
                    if(is_defined(global.status.log[i].adminAction)) {
                      println@Console("Execution on the State-Machine: log[" + i + "] - adminAction? " + global.status.log[i].adminAction )();
                      if(global.status.log[i].adminAction)
                        AdminAction@DataManager(global.status.log[i].entry)(response)
                      else
                        ClientAction@DataManager(global.status.log[i].entry)(response);
                      global.status.lastApplied = i
                    }
                  }
              }
            }
          } else {
            for ({i = appendEntriesRequest.prevLogIndex | break = false}, i > 0 && !break, i--) { // Scorro all'indietro perchè in casi di log molto lunghi troverei prima la prima occorrenza di un temine <= al prevLogTerm
              ackResponse.conflictingIndex = i;
              if(is_defined(global.status.log[i]) && global.status.log[i].term <= appendEntriesRequest.prevLogTerm && global.status.log[i-1].term < global.status.log[i].term)
                break = true
            }
          }
        }
      }
    };

    scope (sendAck) {
      {ackResponse.term = global.status.currentTerm | ackResponse.success = success | ackResponse.senderID = global.status.myID | ackResponse.lastIndex = global.status.lastIndexOfLog};

      if(#appendEntriesRequest.entries > 0) {
        print@Console( "appendentries - " )();
        ackResponse.isHeartbeat = false
      } else {
        print@Console( "heartbeat - " )();
        ackResponse.isHeartbeat = true
      };

      println@Console( "return (" + ackResponse.term + ", " + ackResponse.success + ")" )();

      toVisualizer = sendTo = int(csets.serverSID);

      if(sendTo >= global.status.myID)
        sendTo--;
      toVisualizer--;

      if(sendTo == 1) // #dynamic
        scope( outA ) {
          install( IOException => {global.visualizer.servers.status[1] = false | println@Console("Server A DOWN")()} ); // #dynamic
          global.visualizer.servers.status[toVisualizer] = true;
          Ack@OutServerA(ackResponse)
        }
      else if(sendTo == 2) // #dynamic
        scope( outB ) {
          install( IOException => {global.visualizer.servers.status[2] = false | println@Console("Server B DOWN")()} ); // #dynamic
          global.visualizer.servers.status[toVisualizer] = true;
          Ack@OutServerB(ackResponse)
        }
      else if(sendTo == 3) // #dynamic
        scope( outC ) {
          install( IOException => {global.visualizer.servers.status[3] = false | println@Console("Server C DOWN")()} ); // #dynamic
          global.visualizer.servers.status[toVisualizer] = true;
          Ack@OutServerC(ackResponse)
        }
      else if(sendTo == 4) // #dynamic
        scope( outD ) {
          install( IOException => {global.visualizer.servers.status[4] = false | println@Console("Server D DOWN")()} ); // #dynamic
          global.visualizer.servers.status[toVisualizer] = true;
          Ack@OutServerD(ackResponse)
        }
      else
        println@Console("Server not identified.")()
    }
  }

  [Ack(ackRequest)] {
    csets.serverSID = ackRequest.senderID;
    print@Console( "Received Ack from " + ackRequest.senderID + " (" + ackRequest.term + ", " + ackRequest.success + ") - " )();

    if(ackRequest.isHeartbeat)
      println@Console( "heartbeat")()
    else
      println@Console( "appendentries")();

    synchronized( lastIndexOfLogToken ) { // Considero l'ultimo indice del log a questo momento, se nel frattempo aumentano non mi riguarda per questo ack
      lastIndexOfLog = global.status.lastIndexOfLog
    };

    // Se ho termine inferiore a quello del server che mi risponde divento direttamente follower ed esco
    synchronized( currentTermToken ) {
      if(ackRequest.term > global.status.currentTerm) {
        global.status.currentTerm = ackRequest.term;
        synchronized( serverRoleToken ) {
          global.status.candidate = false ; global.status.follower = true ; global.status.leader = false
        };
        undef(global.status.votedFor);

        synchronized( nextIndicesToken ) {
          for(i = 0, i < #global.status.nextIndices, i++)
            global.status.nextIndices[i] = lastIndexOfLog + 1
        };
        synchronized( matchIndicesToken ) {
          for(i = 0, i < #global.status.matchIndices, i++)
            global.status.matchIndices[i] = 0
        }
      } else if(ackRequest.term == global.status.currentTerm) { // Se i nostri termini sono uguali controllo l'esito
        if(int(csets.serverSID) > global.status.myID) senderPos = int(csets.serverSID) - 2
        else senderPos = int(csets.serverSID) - 1;

        if(ackRequest.success) {
          if(ackRequest.lastIndex <= lastIndexOfLog) { // Non può un follower avere più elementi di me
            synchronized( nextIndicesToken ) {
              global.status.nextIndices[senderPos] = ackRequest.lastIndex + 1
            };
            synchronized( matchIndicesToken ) {
              global.status.matchIndices[senderPos] = ackRequest.lastIndex
            };

            if(is_defined(ackRequest.replicatedIndex) && is_defined(ackRequest.replicatedTerm)) {
              synchronized( replicationInServersToken ) {
                if(global.status.log[ackRequest.replicatedIndex].term == ackRequest.replicatedTerm && global.replicationInServers[ackRequest.replicatedIndex].valid) { // Verifica di consistenza
                  global.replicationInServers[ackRequest.replicatedIndex]++;

                  if(global.replicationInServers[ackRequest.replicatedIndex] == 2) { // Se raggiungo la maggioranza disabilito questa voce e rilascio il semaforo
                    global.replicationInServers[ackRequest.replicatedIndex].valid = false;
                    global.status.commitIndex = ackRequest.lastIndex;
                    release@SemaphoreUtils( global.replicationSemaphore )(res)
                  }
                }
              }
            }
          }
        } else { // se la risposta è false decremento il nextIndex del server
          synchronized( nextIndicesToken ) {
            global.status.nextIndices[senderPos] = ackRequest.conflictingIndex
          };

          ackSendTo = int(csets.serverSID);
          if(ackSendTo >= global.status.myID)
            ackSendTo--;

          scope( sendAppendEntries ) {
            if(ackSendTo == 1) { // #dynamic
              println@Console("A replied FALSE resend appendentries")();
              appendEntriesA
            } else if(ackSendTo == 2) { // #dynamic
              println@Console("B replied FALSE resend appendentries")();
              appendEntriesB
            } else if(ackSendTo == 3) { // #dynamic
              println@Console("C replied FALSE resend appendentries")();
              appendEntriesC
            } else if(ackSendTo == 4) { // #dynamic
              println@Console("D replied FALSE resend appendentries")();
              appendEntriesD
            }
          }
        }
      }
    }
  }

  /* --- TIMEOUT HANDLERS --- */

  [VisualizerTimeout()] {
    if(global.status.leader) {
      scope( getShopStatus ) {
        GetShopStatus@DataManager()(status);
        global.visualizer << status
      };

      scope( updateNetworkVisualizer ) {
        install(IOException => println@Console( "Network Visualizer DOWN" )());
        GlobalStatus@NetworkVisualizer(global.visualizer)
      } |
      scope( setVisualizerTimer ) {
        setVisualizerTimer
      }
    }
  }

  [HeartbeatTimeoutA()] { // NOTA: Si sfrutta il fatto che quando viene reinvocato lo stesso timer riparte da 0
    println@Console( "Send heartbeat to A" )();
    appendEntriesA
  }

  [HeartbeatTimeoutB()] {
    println@Console( "Send heartbeat to B" )();
    appendEntriesB
  }

  [HeartbeatTimeoutC()] {
    println@Console( "Send heartbeat to C" )();
    appendEntriesC
  }

  [HeartbeatTimeoutD()] {
    println@Console( "Send heartbeat to D" )();
    appendEntriesD
  }

  [ElectionTimeout()] {
    if(!global.status.leader) {
      scope(startElection) {
        println@Console("Start election!")();
        election
      } |
      scope(setElectionTimer) {
        setElectionTimer
      }
    }
  }

  /* --- CLIENT --- */

  [ClientRequest(request)(response) {
    if(!global.status.leader)
      if(is_defined(global.status.leaderAddress))
        response.address = "socket://localhost:900" + global.status.leaderAddress
      else // Se vi è una votazione, contatto il server successivo
        response.address = "socket://localhost:900" + ((global.status.myID + 1) % 5)
    else if(request.code == 1 || request.code == 5) // Se sono richieste azioni di sola lettura non le scrivo nel log e le eseguo concorrentemente (gestendo il Readers-Writers problem)
      ClientAction@DataManager(request)(response)
    else {
      synchronized( initRequestToken ) {
        scope( initReq ) {
          semaphorePosition = #global.executionSemaphores;

          with( global.executionSemaphores[semaphorePosition] ) {
            .name = new |
            .permits = 1
          };

          acquireSemaphoreC << global.executionSemaphores[(semaphorePosition - 1)];
          releaseSemaphoreC << global.executionSemaphores[(semaphorePosition)]
        } |
        synchronized( lastIndexOfLogToken ) {
          global.status.lastIndexOfLog++;

          synchronized( operationOnLogToken ) {
            global.replicationInServers[global.status.lastIndexOfLog] = 0;
            global.replicationInServers[global.status.lastIndexOfLog].valid = true;

            global.status.log[global.status.lastIndexOfLog].entry << request;
            global.status.log[global.status.lastIndexOfLog].adminAction = false;
            global.status.log[global.status.lastIndexOfLog].term = global.status.currentTerm
          }
        }
      };

      acquire@SemaphoreUtils(acquireSemaphoreC)(res);

        appendEntriesToAll |
        acquire@SemaphoreUtils( global.replicationSemaphore )(res); // permette di eseguire solo se si ha la maggioranza di replicazione degli altri server

        synchronized( executionToken ) {
          ClientAction@DataManager(request)(response) | global.status.lastApplied++
        };

      release@SemaphoreUtils(releaseSemaphoreC)(res)
    }
  }]  {nullProcess}

  /* --- ADMIN --- */

  [AdminRequest(request)(response) {
    if(!global.status.leader)
      if(is_defined(global.status.leaderAddress))
        response.address = "socket://localhost:1000" + global.status.leaderAddress
      else // Se vi è una votazione, contatto il server successivo
        response.address = "socket://localhost:1000" + ((global.status.myID + 1) % 5)
    else if(request.code == 1) // Se è richiesta un'azione di sola lettura non la scrivo nel log e la eseguo concorrentemente (gestendo il Readers-Writers problem)
      AdminAction@DataManager(request)(response)
    else {
      synchronized( initRequestToken ) {
        scope( initReq ) {
          semaphorePosition = #global.executionSemaphores;

          with( global.executionSemaphores[semaphorePosition] ) {
            .name = new |
            .permits = 1
          };

          acquireSemaphoreA << global.executionSemaphores[(semaphorePosition - 1)];
          releaseSemaphoreA << global.executionSemaphores[(semaphorePosition)]
        } |
        synchronized( lastIndexOfLogToken ) {
          global.status.lastIndexOfLog++;

          synchronized( operationOnLogToken ) {
            global.replicationInServers[global.status.lastIndexOfLog] = 0;
            global.replicationInServers[global.status.lastIndexOfLog].valid = true;

            global.status.log[global.status.lastIndexOfLog].entry << request;
            global.status.log[global.status.lastIndexOfLog].adminAction = true;
            global.status.log[global.status.lastIndexOfLog].term = global.status.currentTerm
          }
        }
      };

      acquire@SemaphoreUtils(acquireSemaphoreA)(res);

        appendEntriesToAll |
        acquire@SemaphoreUtils( global.replicationSemaphore )(res); // permette di eseguire solo se si ha la maggioranza di replicazione degli altri server

        synchronized( executionToken ) {
          AdminAction@DataManager(request)(response) | global.status.lastApplied++
        };

      release@SemaphoreUtils(releaseSemaphoreA)(res)
    }
  }]  {nullProcess}

  /* --- HTTP --- */

  [ClientHTTPDefault(request)(response) {
    format = "html";

    scope(filerequest) {
      install (FileNotFound => file.filename = "HTTP/404.html"; readFile@File(file)(response),  // Pagina non trovata
               AccessDenied => file.filename = "HTTP/401.html"; readFile@File(file)(response)); // Accesso negato

      if(request.operation != "admin.html") {
        file.filename = "HTTP/" + request.operation;
        readFile@File(file)(response);
        println@Console("HTTP: send file - " + request.operation)()
      } else {
        throw( AccessDenied )
      }
    }
  }]  {nullProcess}

  [AdminHTTPDefault(request)(response) {
    format = "html";

    scope(filerequest) {
      install (FileNotFound => file.filename = "HTTP/404.html"; readFile@File(file)(response),  // Pagina non trovata
               AccessDenied => file.filename = "HTTP/401.html"; readFile@File(file)(response)); // Accesso negato

      if(request.operation != "client.html") {
        file.filename = "HTTP/" + request.operation;
        readFile@File(file)(response);
        println@Console("HTTP: send file - " + request.operation)()
      } else {
        throw( AccessDenied )
      }
    }
  }]  {nullProcess}

}

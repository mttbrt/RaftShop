include "Static/header.iol"

// Outside the servers' group
inputPort ClientPort {
  Location: "socket://localhost:9005" // #dynamic
	Protocol: http {
		.format -> format;
		.default = "ClientHTTPDefault"
	}
  Interfaces: ClientInterface
}

inputPort AdminPort {
  Location: "socket://localhost:10005" // #dynamic
	Protocol: http {
		.format -> format;
		.default = "AdminHTTPDefault"
	}
  Interfaces: AdminInterface
}

outputPort NetworkVisualizer {
  Location: "socket://localhost:12000"
  Protocol: sodep
  Interfaces: VisualizerInterface
}

// Inside the servers' group

// Inputs
inputPort InServer {
  Location: "socket://localhost:8005" // #dynamic
  Protocol: sodep
  Interfaces: TimerInterface, ElectionInterface, ServerInterface
}

// Outputs
outputPort OutServerA {
  Location: "socket://localhost:8001" // #dynamic
  Protocol: sodep
  Interfaces: ElectionInterface, ServerInterface
}

outputPort OutServerB {
  Location: "socket://localhost:8002" // #dynamic
  Protocol: sodep
  Interfaces: ElectionInterface, ServerInterface
}

outputPort OutServerC {
  Location: "socket://localhost:8003" // #dynamic
  Protocol: sodep
  Interfaces: ElectionInterface, ServerInterface
}

outputPort OutServerD {
  Location: "socket://localhost:8004" // #dynamic
  Protocol: sodep
  Interfaces: ElectionInterface, ServerInterface
}

execution { concurrent }

cset {
  serverSID: AppendEntriesType.leaderID
}

/* Timers */

define setVisualizerTimer {
  visualizerTimerReq = 1000;
  visualizerTimerReq.port = "8005"; // #dynamic
  SetVisualizerTimer@VisualizerTimer(visualizerTimerReq)
}

define setHeartbeatTimerA {
  heartbeatTimerReq = 50*3;
  heartbeatTimerReq.port = "8005"; // #dynamic
  SetHeartbeatTimer@HeartbeatTimerA(heartbeatTimerReq)
}

define setHeartbeatTimerB {
  heartbeatTimerReq = 50*3;
  heartbeatTimerReq.port = "8005"; // #dynamic
  SetHeartbeatTimer@HeartbeatTimerB(heartbeatTimerReq)
}

define setHeartbeatTimerC {
  heartbeatTimerReq = 50*3;
  heartbeatTimerReq.port = "8005"; // #dynamic
  SetHeartbeatTimer@HeartbeatTimerC(heartbeatTimerReq)
}

define setHeartbeatTimerD {
  heartbeatTimerReq = 50*3;
  heartbeatTimerReq.port = "8005"; // #dynamic
  SetHeartbeatTimer@HeartbeatTimerD(heartbeatTimerReq)
}

define setElectionTimer {
  random@Math()(delay);
  min = 150;
  max = 300;
  x = min + int(delay * (max - min + 1));
  electionTimerReq = x*3;
  electionTimerReq.port = "8005"; // #dynamic
  SetElectionTimer@ElectionTimer(electionTimerReq)
}

/* AppendEntries */

define appendEntriesA {
  if(global.status.leader) {
    scope( setHeartbeatData ) {
      install( IOException => {global.visualizer.servers.status[0] = false | println@Console("Server A DOWN")()} ); // #dynamic
      global.visualizer.servers.status[0] = true; // #dynamic

      with(appEntriesRequestA) {
        .term = global.status.currentTerm;
        .leaderID = global.status.myID;
        .leaderCommit = global.status.commitIndex
      };

      // Se il nextIndex di questo server è superiore all'ultimo elemento del mio log, lo reimposto
      synchronized( nextIndicesToken ) {
        synchronized( lastIndexOfLogToken ) {
          if(global.status.nextIndices[0] > global.status.lastIndexOfLog + 1)
            global.status.nextIndices[0] = global.status.lastIndexOfLog + 1
        };

        // Il prevLogIndex è l'indice della voce immediatamente precedente alla nuova voce da aggiungere per questo server
        appEntriesRequestA.prevLogIndex = global.status.nextIndices[0] - 1;

        synchronized( operationOnLogToken ) {
          // Invio l'elemento in nextIndices come nuova entry
          if(global.status.nextIndices[0] <= global.status.lastIndexOfLog)
            appEntriesRequestA.entries[0] << global.status.log[global.status.nextIndices[0]]
          else
            undef(appEntriesRequestA.entries);

          // Il prevLogTerm è il termine dell'elemento del log alla prevLogIndex-esima posizione
          appEntriesRequestA.prevLogTerm = global.status.log[appEntriesRequestA.prevLogIndex].term
        }
      };

      AppendEntries@OutServerA(appEntriesRequestA)
    } |
    scope( setHeartbeatTimerToA ) {
      setHeartbeatTimerA
    }
  }
}

define appendEntriesB {
  if(global.status.leader) {
    scope( setHeartbeatData ) {
      install( IOException => {global.visualizer.servers.status[1] = false | println@Console("Server B DOWN")()} ); // #dynamic
      global.visualizer.servers.status[1] = true; // #dynamic

      with(appEntriesRequestB) {
        .term = global.status.currentTerm;
        .leaderID = global.status.myID;
        .leaderCommit = global.status.commitIndex
      };

      // Se il nextIndex di questo server è superiore all'ultimo elemento del mio log, lo reimposto
      synchronized( nextIndicesToken ) {
        synchronized( lastIndexOfLogToken ) {
          if(global.status.nextIndices[1] > global.status.lastIndexOfLog + 1)
            global.status.nextIndices[1] = global.status.lastIndexOfLog + 1
        };

        // Il prevLogIndex è l'indice della voce immediatamente precedente alla nuova voce da aggiungere per questo server
        appEntriesRequestB.prevLogIndex = global.status.nextIndices[1] - 1;

        synchronized( operationOnLogToken ) {
          // Invio l'elemento in nextIndices come nuova entry
          if(global.status.nextIndices[1] <= global.status.lastIndexOfLog)
            appEntriesRequestB.entries[0] << global.status.log[global.status.nextIndices[1]]
          else
            undef(appEntriesRequestB.entries);

          // Il prevLogTerm è il termine dell'elemento del log alla prevLogIndex-esima posizione
          appEntriesRequestB.prevLogTerm = global.status.log[appEntriesRequestB.prevLogIndex].term
        }
      };

      AppendEntries@OutServerB(appEntriesRequestB)
    } |
    scope( setHeartbeatTimerToB ) {
      setHeartbeatTimerB
    }
  }
}

define appendEntriesC {
  if(global.status.leader) {
    scope( setHeartbeatData ) {
      install( IOException => {global.visualizer.servers.status[2] = false | println@Console("Server C DOWN")()} ); // #dynamic
      global.visualizer.servers.status[2] = true; // #dynamic

      with(appEntriesRequestC) {
        .term = global.status.currentTerm;
        .leaderID = global.status.myID;
        .leaderCommit = global.status.commitIndex
      };

      // Se il nextIndex di questo server è superiore all'ultimo elemento del mio log, lo reimposto
      synchronized( nextIndicesToken ) {
        synchronized( lastIndexOfLogToken ) {
          if(global.status.nextIndices[2] > global.status.lastIndexOfLog + 1)
            global.status.nextIndices[2] = global.status.lastIndexOfLog + 1
        };

        // Il prevLogIndex è l'indice della voce immediatamente precedente alla nuova voce da aggiungere per questo server
        appEntriesRequestC.prevLogIndex = global.status.nextIndices[2] - 1;

        synchronized( operationOnLogToken ) {
          // Invio l'elemento in nextIndices come nuova entry
          if(global.status.nextIndices[2] <= global.status.lastIndexOfLog)
            appEntriesRequestC.entries[0] << global.status.log[global.status.nextIndices[2]]
          else
            undef(appEntriesRequestC.entries);

          // Il prevLogTerm è il termine dell'elemento del log alla prevLogIndex-esima posizione
          appEntriesRequestC.prevLogTerm = global.status.log[appEntriesRequestC.prevLogIndex].term
        }
      };

      AppendEntries@OutServerC(appEntriesRequestC)
    } |
    scope( setHeartbeatTimerToC ) {
      setHeartbeatTimerC
    }
  }
}

define appendEntriesD {
  if(global.status.leader) {
    scope( setHeartbeatData ) {
      install( IOException => {global.visualizer.servers.status[3] = false | println@Console("Server D DOWN")()} ); // #dynamic
      global.visualizer.servers.status[3] = true; // #dynamic

      with(appEntriesRequestD) {
        .term = global.status.currentTerm;
        .leaderID = global.status.myID;
        .leaderCommit = global.status.commitIndex
      };

      // Se il nextIndex di questo server è superiore all'ultimo elemento del mio log, lo reimposto
      synchronized( nextIndicesToken ) {
        synchronized( lastIndexOfLogToken ) {
          if(global.status.nextIndices[3] > global.status.lastIndexOfLog + 1)
            global.status.nextIndices[3] = global.status.lastIndexOfLog + 1
        };

        // Il prevLogIndex è l'indice della voce immediatamente precedente alla nuova voce da aggiungere per questo server
        appEntriesRequestD.prevLogIndex = global.status.nextIndices[3] - 1;

        synchronized( operationOnLogToken ) {
          // Invio l'elemento in nextIndices come nuova entry
          if(global.status.nextIndices[3] <= global.status.lastIndexOfLog)
            appEntriesRequestD.entries[0] << global.status.log[global.status.nextIndices[3]]
          else
            undef(appEntriesRequestD.entries);

          // Il prevLogTerm è il termine dell'elemento del log alla prevLogIndex-esima posizione
          appEntriesRequestD.prevLogTerm = global.status.log[appEntriesRequestD.prevLogIndex].term
        }
      };

      AppendEntries@OutServerD(appEntriesRequestD)
    } |
    scope( setHeartbeatTimerToD ) {
      setHeartbeatTimerD
    }
  }
}

define appendEntriesToAll {
    scope( sendToA ) {
      println@Console("Sending appendEntries to A")();
      appendEntriesA
    } |
    scope( sendToB ) {
      println@Console("Sending appendEntries to B")();
      appendEntriesB
    } |
    scope( sendToC ) {
      println@Console("Sending appendEntries to C")();
      appendEntriesC
    } |
    scope( sendToD ) {
      println@Console("Sending appendEntries to D")();
      appendEntriesD
    }
}

/* Election */

define election {
  // Inizializza la richiesta di elezione
  scope( initElectionRequest ) {
    synchronized( serverRoleToken ) {
      global.status.candidate = true | global.status.follower = false | global.status.leader = false
    };
    global.status.currentTerm++; // Incremento il mio termine
    synchronized( votedForToken ) {
      global.status.votedFor = global.status.myID // Voto esplicito per se stesso (come richiesto dalle specifiche)
    };
    with( elecReq ) {
      .term = global.status.currentTerm;
      .candidateID = global.status.myID;
      synchronized( lastIndexOfLogToken ) {
        .lastLogIndex = global.status.lastIndexOfLog;
        .lastLogTerm = global.status.log[global.status.lastIndexOfLog].term
      }
    }
  };

  println@Console( "CANDIDATE: this is the server " + elecReq.candidateID + " with term " + elecReq.term )();

  // Richiede un voto a tutti gli altri
  scope( sendElectionRequest ) {
    scope( A ) {
      install( IOException => {global.visualizer.servers.status[0] = false | println@Console("Server A DOWN")()} ); // #dynamic
      global.visualizer.servers.status[0] = true; // #dynamic
      RequestVote@OutServerA(elecReq)(result[0])
    } |
    scope( B ) {
      install( IOException => {global.visualizer.servers.status[1] = false | println@Console("Server B DOWN")()} ); // #dynamic
      global.visualizer.servers.status[1] = true; // #dynamic
      RequestVote@OutServerB(elecReq)(result[1])
    } |
    scope( C ) {
      install( IOException => {global.visualizer.servers.status[2] = false | println@Console("Server C DOWN")()} ); // #dynamic
      global.visualizer.servers.status[2] = true; // #dynamic
      RequestVote@OutServerC(elecReq)(result[2])
    } |
    scope( D ) {
      install( IOException => {global.visualizer.servers.status[3] = false | println@Console("Server D DOWN")()} ); // #dynamic
      global.visualizer.servers.status[3] = true; // #dynamic
      RequestVote@OutServerD(elecReq)(result[3])
    }
  };

  //Analizza il risultato dell'elezione. Viene fatto dopo l'ElectionRequest per evitare busy waiting
  scope( analyzeResults ) {
    voteCounter = 1; // Il mio voto
    eletto = false;
    for(i = 0, i < 4, i++) {
      synchronized( currentTermToken ) {
        if(result[i].Term > global.status.currentTerm) { // Se il termine del server che mi vota è maggiore del mio, divento follower
          println@Console( "FOLLOWER: found term greater than mine" )();
          global.status.currentTerm = result[i].Term; // Aggiorno il mio termine
          synchronized( serverRoleToken ) {
            global.status.candidate = false ; global.status.follower = true ; global.status.leader = false
          };
          undef(global.status.votedFor); // NOTA: ogni volta che aggiorno il mio termine perchè qualcuno lo ha maggiore, faccio l'undef di votedFor perchè posso votare per candidati con questo termine, in quanto non ho ancora votato (infatti votedFor viene settato solo quando voto per me stesso o true per un altro)

          synchronized( nextIndicesToken ) {
            for(i = 0, i < #global.status.nextIndices, i++)
              global.status.nextIndices[i] = global.status.lastIndexOfLog + 1
          };
          synchronized( matchIndicesToken ) {
            for(i = 0, i < #global.status.matchIndices, i++)
              global.status.matchIndices[i] = 0
          }
        } else if(result[i].VoteGranted == true) { // Se ha votato per me aumento il conto e faccio ripartire il timer
          println@Console( "Vote true from " + i + " with term " + result[i].Term )();
          voteCounter++
        }
      }
    };

    // Se sono ancora candidato, ovvero nessuno ha termine maggiore del mio e non sono diventato follower per causa di un appendEntries valida con termine >= al mio (synchronized), conto i voti
    // NOTA: si può entrare qui solo quando scatta un electionTimer e non si è leader, quindi non vi sarà la possibilità di essere a questo punto del codice come leader.
    if(global.status.candidate && voteCounter >= 3) { // E ho ricevuto la maggioranza dei voi
      println@Console("\n\t>>> I'M THE LEADER <<<\t\n")();

      synchronized( serverRoleToken ) {
        global.status.candidate = false | global.status.follower = false | global.status.leader = true
      };

      synchronized( nextIndicesToken ) {
        for(i = 0, i < #global.status.nextIndices, i++)
          global.status.nextIndices[i] = global.status.lastIndexOfLog + 1
      };
      synchronized( matchIndicesToken ) {
        for(i = 0, i < #global.status.matchIndices, i++)
          global.status.matchIndices[i] = 0
      };

      setVisualizerTimer;
      appendEntriesToAll // Mando un heartbeat a tutti
    } else {
      println@Console( "FOLLOWER: I got the majority" )();
      synchronized( serverRoleToken ) {
        global.status.candidate = false ; global.status.follower = true ; global.status.leader = false
      }
    }
  }
}

init {
  global.status.myID = 5 // #dynamic
}

include "Static/serverMain.ol"

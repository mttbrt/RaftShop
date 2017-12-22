include "console.iol"
include "math.iol"
include "string_utils.iol"
include "maininterface.iol"

outputPort ServerPort {
	Protocol: http
  Interfaces: AdminInterface
}

execution { single }

define admin {
	stop = true; // Evita che se si preme solo invio senza niente faccia un ciclo infinito di connessione
	quit = false;

  while(!quit) {

		if(iter < #buffer) { // Se il buffer non è stato completato, lo eseguo
			choice = buffer[iter].code
		} else if(is_defined(choice)) { // Se choice è già settata, la mantengo finchè il leader non la esegue
			choice = choice
		} else {
			println@Console("Execution codes:")();
	    println@Console("0. Exit")();
	    println@Console("1. Items list")();
	    println@Console("2. Add/Increase item")();
	    println@Console("3. Remove/Decrease item")();

			print@Console("# ")();
	    registerForInput@Console()();
	    in(choice);
			choice = int(choice)
		};

		if (choice == 0) { // Quit
			stop = true | quit = true
		} else if (choice == 1) { // Items List
			stop = false;

			undef(request);
			undef(response);
			request.code = choice;
			request.data = void;

			AdminRequest@ServerPort(request)(response);

			if(response instanceof LeaderAddress) { // Ho contattato un follower e mi ha mandato l'indirizzo del leader
				ServerPort.location = response.address;
				println@Console("Follower here, the leader is: " + response.address)();

				undef(pos);
				pos = response.address;

				length@StringUtils(pos)(length);

				pos.end = length;
				pos.begin = length - 1;

				substring@StringUtils(pos)(res);

				WrongLeaderException.serverPos = int(res) - 1; // Indico la posizione del server leader e lancio un fault
				throw( WrongLeaderException )
			} else { // Mi ha mandato la lista con tutti gli items (piena o vuota che sia)
				for(i = 0, i < 5, i++) { // Ho trovato il leader e in caso di down o follower si ricomincia a cercare da capo
					servers[i].isDown = false;
					servers[i].isFollower = false
				};

				println@Console("Items List:")();
				if(is_defined(response))
					foreach (item : response)
						println@Console( "> " + response.(item).name + "/" + response.(item).quantity )()
				else
					println@Console("No items available.")()
			};
			println@Console()()
    } else if(choice == 2) { // Add item
			stop = false;

			if(iter < #buffer) { // Se il buffer non è stato completato, lo eseguo
				reqAddItem.itemName = buffer[iter].itemName;
				addQnt = buffer[iter].itemQnt
			} else if(is_defined(reqAddItem) && is_defined(addQnt)) {
				reqAddItem << reqAddItem;
				addQnt = int(addQnt)
			} else {
				print@Console("Item name: ")();
				registerForInput@Console()();
		    in(reqAddItem.itemName);

				print@Console("Quantity: ")();
				registerForInput@Console()();
				in(addQnt)
			};

			// Tolgo gli spazi
			name = reqAddItem.itemName;
			name.replacement = "";
			name.regex = " ";
			replaceAll@StringUtils(name)(noSpaces);
			reqAddItem.itemName = noSpaces;

			// Deve essere presente almeno un carattere
			length@StringUtils(noSpaces)(len);

			if(len > 0) {
				if(int(addQnt) > 0) { // Con questo sappiamo che è un intero e maggiore di 0
	        reqAddItem.itemQnt = int(addQnt);

					undef(request);
					undef(response);
					request.code = choice;
					request.data << reqAddItem;

					AdminRequest@ServerPort(request)(response);

					if(response instanceof LeaderAddress) { // Ho contattato un follower e mi ha mandato l'indirizzo del leader
						ServerPort.location = response.address;
						println@Console("Follower here, the leader is: " + response.address)();

						undef(pos);
						pos = response.address;

						length@StringUtils(pos)(length);

						pos.end = length;
						pos.begin = length - 1;

						substring@StringUtils(pos)(res);

						WrongLeaderException.serverPos = int(res) - 1; // Indico la posizione del server leader e lancio un fault
						throw( WrongLeaderException )
					} else {
						undef(reqAddItem);
						undef(addQnt);
						for(i = 0, i < 5, i++) { // Ho trovato il leader e in caso di down o follower si ricomincia a cercare da capo
							servers[i].isDown = false;
							servers[i].isFollower = false
						};

						if (response.result)
							println@Console("Success: " + response.msg + "\n")()
						else
							println@Console("Attention: " + response.msg + "\n")()
					}
	      } else {
					println@Console("Quantity must be an integer greater than zero.\n")();
					undef(reqAddItem); // Invalido la richiesta
					undef(addQnt)
				}
			} else {
				println@Console("Name cannot be empty.\n")();
				undef(reqAddItem); // Invalido la richiesta
				undef(addQnt)
			}

    } else if(choice == 3) { // Remove item
			stop = false;

			if(iter < #buffer) { // Se il buffer non è stato completato, lo eseguo
				reqRmvItem.itemName = buffer[iter].itemName;
				rmvQnt = buffer[iter].itemQnt
			} else if(is_defined(reqRmvItem) && is_defined(rmvQnt)) {
				reqRmvItem << reqRmvItem;
				rmvQnt = int(rmvQnt)
			} else {
				print@Console("Item name: ")();
				registerForInput@Console()();
		    in(reqRmvItem.itemName);

				print@Console("Quantity: ")();
				registerForInput@Console()();
		    in(rmvQnt)
			};

			// Tolgo gli spazi
			name = reqRmvItem.itemName;
			name.replacement = "";
			name.regex = " ";
			replaceAll@StringUtils(name)(noSpaces);
			reqRmvItem.itemName = noSpaces;

			// Deve essere presente almeno un carattere
			length@StringUtils(noSpaces)(len);

			if(len > 0) {
				if(int(rmvQnt) > 0) { // Con questo sappiamo che è un intero e maggiore di 0
	        reqRmvItem.itemQnt = int(rmvQnt);

					undef(request);
					undef(response);
					request.code = choice;
					request.data << reqRmvItem;

					AdminRequest@ServerPort(request)(response);

					if(response instanceof LeaderAddress) { // Ho contattato un follower e mi ha mandato l'indirizzo del leader
						ServerPort.location = response.address;
						println@Console("Follower here, the leader is: " + response.address)();

						undef(pos);
						pos = response.address;

						length@StringUtils(pos)(length);

						pos.end = length;
						pos.begin = length - 1;

						substring@StringUtils(pos)(res);

						WrongLeaderException.serverPos = int(res) - 1; // Indico la posizione del server leader e lancio un fault
						throw( WrongLeaderException )
					} else {
						undef(reqRmvItem);
						undef(rmvQnt);
						for(i = 0, i < 5, i++) { // Ho trovato il leader e in caso di down o follower si ricomincia a cercare da capo
							servers[i].isDown = false;
							servers[i].isFollower = false
						};

						if (response.result)
							println@Console("Success: " + response.msg + "\n")()
						else
							println@Console("Attention: " + response.msg + "\n")()
					}
	      } else {
					println@Console("Quantity must be an integer greater than zero.\n")();
					undef(reqRmvItem); // Invalido la richiesta
					undef(rmvQnt)
				}
			} else {
				println@Console("Name cannot be empty.\n")();
				undef(reqRmvItem); // Invalido la richiesta
				undef(rmvQnt)
			}

		} else if (choice < 0 || choice > 3) {
			println@Console("Command not found.")()
		};

		iter++;
		undef(choice)
  }
}

init {
	// Creo la lista di operazioni da fare prima di richiedere l'input all'utente
	for (i = 0 | j = 0, i < #args, i++ | j++) {
	  args[i].regex = "/";
	  split@StringUtils(args[i])(operation);

		if(#operation.result == 3 && (int(operation.result[0]) == 2 || int(operation.result[0]) == 3)) {
			buffer[j].code = int(operation.result[0]);
			buffer[j].itemName = operation.result[1];
			buffer[j].itemQnt = int(operation.result[2])
		} else {
			println@Console("Incorrect operation for args[" + i + "]")();
			j-- // non aggiungo alla lista un elemento con formato non corretto
		}
	};

	random@Math()(rand);
	global.serverPos = int((rand*100 ) % 5); // inizio con un server random
	stop = false;
	iter = 0; // iteratore del buffer di elementi da immettere

	for(i = 0, i < 5, i++) {
		servers[i].isDown = false;
		servers[i].isFollower = false
	}

}

main {
	while(!stop) {
		scope(A) {
			install( IOException => {
				servers[0].isDown = true;
				println@Console("\nServer 1 not available, trying to connect to another server...\n")();

				break = false;
				for(i = 0, i < 5 && !break, i++) {
					if(!servers[i].isDown && !servers[i].isFollower) {
						global.serverPos = i; // Imposto il collegamento con il successivo in lista non down e non follower
						break = true
					}
				};

				if(!break) { // Se nessun server ha questi requisiti esco
					stop = true;
					println@Console("Sorry but RaftShop is down.. Try later")()
				}
			});

			install( WrongLeaderException => {
				servers[0].isFollower = true;
				global.serverPos = WrongLeaderException.serverPos;
				undef(WrongLeaderException.serverPos)
			});

			if (global.serverPos == 0) {
				ServerPort.location = "socket://localhost:10001";
				println@Console("Connecting to port: " + ServerPort.location + "\n")();

				admin
			}
		} |
		scope(B) {
			install( IOException => {
				servers[1].isDown = true;
				println@Console("\nServer 2 not available, trying to connect to another server...\n")();

				break = false;
				for(i = 0, i < 5 && !break, i++) {
					if(!servers[i].isDown && !servers[i].isFollower) {
						global.serverPos = i; // Imposto il collegamento con il successivo in lista non down e non follower
						break = true
					}
				};

				if(!break) { // Se nessun server ha questi requisiti esco
					stop = true;
					println@Console("Sorry but RaftShop is down.. Try later")()
				}
			});

			install( WrongLeaderException => {
				servers[1].isFollower = true;
				global.serverPos = WrongLeaderException.serverPos;
				undef(WrongLeaderException.serverPos)
			});

			if (global.serverPos == 1) {
				ServerPort.location = "socket://localhost:10002";
				println@Console("Connecting to port: " + ServerPort.location + "\n")();

				admin
			}
		} |
		scope(C) {
			install( IOException => {
				servers[2].isDown = true;
				println@Console("\nServer 3 not available, trying to connect to another server...\n")();

				break = false;
				for(i = 0, i < 5 && !break, i++) {
					if(!servers[i].isDown && !servers[i].isFollower) {
						global.serverPos = i; // Imposto il collegamento con il successivo in lista non down e non follower
						break = true
					}
				};

				if(!break) { // Se nessun server ha questi requisiti esco
					stop = true;
					println@Console("Sorry but RaftShop is down.. Try later")()
				}
			});

			install( WrongLeaderException => {
				servers[2].isFollower = true;
				global.serverPos = WrongLeaderException.serverPos;
				undef(WrongLeaderException.serverPos)
			});

			if (global.serverPos == 2) {
				ServerPort.location = "socket://localhost:10003";
				println@Console("Connecting to port: " + ServerPort.location + "\n")();

				admin
			}
		} |
		scope(D) {
			install( IOException => {
				servers[3].isDown = true;
				println@Console("\nServer 4 not available, trying to connect to another server...\n")();

				break = false;
				for(i = 0, i < 5 && !break, i++) {
					if(!servers[i].isDown && !servers[i].isFollower) {
						global.serverPos = i; // Imposto il collegamento con il successivo in lista non down e non follower
						break = true
					}
				};

				if(!break) { // Se nessun server ha questi requisiti esco
					stop = true;
					println@Console("Sorry but RaftShop is down.. Try later")()
				}
			});

			install( WrongLeaderException => {
				servers[3].isFollower = true;
				global.serverPos = WrongLeaderException.serverPos;
				undef(WrongLeaderException.serverPos)
			});

			if (global.serverPos == 3) {
				ServerPort.location = "socket://localhost:10004";
				println@Console("Connecting to port: " + ServerPort.location + "\n")();

				admin
			}
		} |
		scope(E) {
			install( IOException => {
				servers[4].isDown = true;
				println@Console("\nServer 5 not available, trying to connect to another server...\n")();

				break = false;
				for(i = 0, i < 5 && !break, i++) {
					if(!servers[i].isDown && !servers[i].isFollower) {
						global.serverPos = i; // Imposto il collegamento con il successivo in lista non down e non follower
						break = true
					}
				};

				if(!break) { // Se nessun server ha questi requisiti esco
					stop = true;
					println@Console("Sorry but RaftShop is down.. Try later")()
				}
			});

			install( WrongLeaderException => {
				servers[4].isFollower = true;
				global.serverPos = WrongLeaderException.serverPos;
				undef(WrongLeaderException.serverPos)
			});

			if (global.serverPos == 4) {
				ServerPort.location = "socket://localhost:10005";
				println@Console("Connecting to port: " + ServerPort.location + "\n")();

				admin
			}
		}
	}
}

include "console.iol"
include "math.iol"
include "string_utils.iol"
include "maininterface.iol"

outputPort ServerPort {
	Protocol: http
  Interfaces: ClientInterface
}

execution { single }

define client {
	stop = true; // Evita che se si preme solo invio senza niente faccia un ciclo infinito di connessione
	quit = false;

  while(!quit) {

		if(!is_defined(choice)) {
			println@Console("Execution codes:")();
	    println@Console("0. Exit")();
	    println@Console("1. Items List")();
	    println@Console("2. New cart")();
	    println@Console("3. Buy cart")();
	    println@Console("4. Delete cart")();
	    println@Console("5. Show items in cart")();
	    println@Console("6. Add item to cart")();
	    println@Console("7. Remove item from cart")();

			print@Console("$ ")();
	    registerForInput@Console()();
	  	in(choice);
			choice = int(choice)
		};

		if (choice == 0) { // Quit
			stop = true | quit = true
    } else if (choice == 1) { // Items list
			stop = false;

			undef(request);
			undef(response);
			request.code = choice;
			request.data = void;

			ClientRequest@ServerPort(request)(response);

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
    } else if(choice == 2) { // New Cart
			stop = false;

			if(!is_defined(reqNewCart)) { // Se l'ho già impostato non lo richiedo finchè non viene esaudita la richiesta
				print@Console("Cart name: ")();
				registerForInput@Console()();
		    in(reqNewCart.name)
			};

			// Tolgo gli spazi
			name = reqNewCart.name;
			name.replacement = "";
			name.regex = " ";
			replaceAll@StringUtils(name)(noSpaces);
			reqNewCart.name = noSpaces;

			// Deve essere presente almeno un carattere
			length@StringUtils(reqNewCart.name)(len);

			if(len > 0) { // Non accetto stringhe vuote
				undef(request);
				undef(response);
				request.code = choice;
				request.data << reqNewCart;

				ClientRequest@ServerPort(request)(response);

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
					undef(reqNewCart);
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
				println@Console( "Cart name cannot be empty.\n" )();
				undef(reqNewCart)
			}
    } else if(choice == 3) { // Buy Cart
			stop = false;

			if(!is_defined(reqBuyCart)) {
				print@Console("Cart name: ")();
				registerForInput@Console()();
		    in(reqBuyCart.name);

				length@StringUtils(reqBuyCart.name)(len)
			};

			if(len > 0) { // Non accetto stringhe vuote
				undef(request);
				undef(response);
				request.code = choice;
				request.data << reqBuyCart;

				ClientRequest@ServerPort(request)(response);

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
					undef(reqBuyCart);
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
				println@Console( "Cart name cannot be empty.\n" )();
				undef(reqBuyCart)
			}
		} else if(choice == 4) { // Delete Cart
			stop = false;

			if(!is_defined(reqDelCart)) {
				print@Console("Cart name: ")();
				registerForInput@Console()();
		    in(reqDelCart.name);

				length@StringUtils(reqDelCart.name)(len)
			};

			if(len > 0) { // Non accetto stringhe vuote
				undef(request);
				undef(response);
				request.code = choice;
				request.data << reqDelCart;

				ClientRequest@ServerPort(request)(response);

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
					undef(reqDelCart);
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
				println@Console( "Cart name cannot be empty.\n" )();
				undef(reqDelCart)
			}
		} else if(choice == 5) { // Show Items in Cart
			stop = false;

			if(!is_defined(reqItemsCart)) {
				print@Console("Cart name: ")();
				registerForInput@Console()();
		    in(reqItemsCart.name);

				length@StringUtils(reqItemsCart.name)(len)
			};

			if(len > 0) { // Non accetto stringhe vuote
				undef(request);
				undef(response);
				request.code = choice;
				request.data << reqItemsCart;

				ClientRequest@ServerPort(request)(response);

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
					undef(reqItemsCart);
					for(i = 0, i < 5, i++) { // Ho trovato il leader e in caso di down o follower si ricomincia a cercare da capo
						servers[i].isDown = false;
						servers[i].isFollower = false
					};

					if(is_defined( response ))
						foreach ( cartItem : response )
							println@Console( "> " + response.(cartItem).name + "/" + response.(cartItem).quantity )()
					else
						println@Console("No items available or cart does not exists.")()
				};

				println@Console()()
			} else {
				println@Console( "Cart name cannot be empty.\n" )();
				undef(reqItemsCart)
			}
		} else if(choice == 6) { // Add Item to Cart
			stop = false;

			if(!is_defined(reqItemToCart) || !is_defined(addQnt)) {
				print@Console("Cart name: ")();
				registerForInput@Console()();
		    in(reqItemToCart.cartName);
				length@StringUtils(reqItemToCart.cartName)(len1);

				print@Console("Item name: ")();
				registerForInput@Console()();
		    in(reqItemToCart.itemName);
				length@StringUtils(reqItemToCart.itemName)(len2);

				print@Console("Quantity: ")();
				registerForInput@Console()();
				in(addQnt);
				length@StringUtils(addQnt)(len3)
			};

			if(len1 < 1)
				println@Console( "Cart name cannot be empty.\n" )();
			if(len2 < 1)
				println@Console( "Item name cannot be empty.\n" )();
			if(len3 < 1)
				println@Console( "Quantity cannot be empty.\n" )();

			if(len1 > 0 && len2 > 0 && len3 > 0) {
				if(int(addQnt) > 0) { // Con questo sappiamo che è un intero e maggiore di 0
	        reqItemToCart.itemQnt = int(addQnt);

					undef(request);
					undef(response);
					request.code = choice;
					request.data << reqItemToCart;

					ClientRequest@ServerPort(request)(response);

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
						undef(reqItemToCart);
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
					println@Console("Quantity must be and integer greater than zero.\n")();
					undef(reqItemToCart); // Invalido la richiesta
					undef(addQnt)
				}
			} else {
				undef(reqItemToCart); // Invalido la richiesta
				undef(addQnt)
			}
		} else if(choice == 7) { // Remove Item from Cart
			stop = false;

			if(!is_defined(reqRmvItem) || !is_defined(rmvQnt)) {
				print@Console("Cart name: ")();
				registerForInput@Console()();
		    in(reqRmvItem.cartName);
				length@StringUtils(reqRmvItem.cartName)(len1);

				print@Console("Item name: ")();
				registerForInput@Console()();
		    in(reqRmvItem.itemName);
				length@StringUtils(reqRmvItem.itemName)(len2);

				print@Console("Quantity: ")();
				registerForInput@Console()();
		    in(rmvQnt);
				length@StringUtils(rmvQnt)(len3)
			};

			if(len1 < 1)
				println@Console( "Cart name cannot be empty.\n" )();
			if(len2 < 1)
				println@Console( "Item name cannot be empty.\n" )();
			if(len3 < 1)
				println@Console( "Quantity cannot be empty.\n" )();

			if(len1 > 0 && len2 > 0 && len3 > 0) {
				if(int(rmvQnt) > 0) { // Con questo sappiamo che è un intero e maggiore di 0
	        reqRmvItem.itemQnt = int(rmvQnt);

					undef(request);
					undef(response);
					request.code = choice;
					request.data << reqRmvItem;

					ClientRequest@ServerPort(request)(response);

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
					println@Console("Quantity must be and integer greater than zero.\n")();
					undef(reqRmvItem); // Invalido la richiesta
					undef(rmvQnt)
				}
			} else {
				undef(reqRmvItem); // Invalido la richiesta
				undef(rmvQnt)
			}
		} else if (choice < 0 || choice > 7)
			println@Console("Command not found.")();

		undef(choice)
  }
}

init {
	random@Math()(rand);
	global.serverPos = int((rand*100 ) % 5); // inizio con un server random
	stop = false;

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
				ServerPort.location = "socket://localhost:9001";
				println@Console("Connecting to port: " + ServerPort.location + "\n")();

				client
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
				ServerPort.location = "socket://localhost:9002";
				println@Console("Connecting to port: " + ServerPort.location + "\n")();

				client
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
				ServerPort.location = "socket://localhost:9003";
				println@Console("Connecting to port: " + ServerPort.location + "\n")();

				client
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
				ServerPort.location = "socket://localhost:9004";
				println@Console("Connecting to port: " + ServerPort.location + "\n")();

				client
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
				ServerPort.location = "socket://localhost:9005";
				println@Console("Connecting to port: " + ServerPort.location + "\n")();

				client
			}
		}
	}
}

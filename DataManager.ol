include "console.iol"
include "semaphore_utils.iol"
include "maininterface.iol"

inputPort In {
	Location: "local"
	Interfaces: ClientActionInterface, AdminActionInterface, VisualizerActionInterface
}

execution { concurrent }

init {
	with( wrtItemsSemaphore ) {
		.name = "wrtItems";
		.permits = 1
	};
	release@SemaphoreUtils(wrtItemsSemaphore)(resp);
	global.readcountItems = 0;

	with( wrtCartsSemaphore ) {
		.name = "wrtCarts";
		.permits = 1
	};
	release@SemaphoreUtils(wrtCartsSemaphore)(resp);
	global.readcountCarts = 0
}

main {

	[ClientAction(request)(response) {
		if(request.code == 1) { // Lista elementi
			synchronized(mutexItems) {
				global.readcountItems++;
				if(global.readcountItems == 1)
					acquire@SemaphoreUtils(wrtItemsSemaphore)(resp)
			};
			response << global.items;
			synchronized(mutexItems) {
				global.readcountItems--;
				if(global.readcountItems == 0)
					release@SemaphoreUtils(wrtItemsSemaphore)(resp)
			}
		} else if(request.code == 2) { // Creazione carrello
			acquire@SemaphoreUtils(wrtCartsSemaphore)(resp);
			if(!is_defined(global.carts.(request.data.name))) { // Se non esiste lo creo
				global.carts.(request.data.name).name = request.data.name;
				global.carts.(request.data.name).status = 0; // status 0: creato

				println@Console("> Created Cart: " + request.data.name)();
				response.result = true;
				response.msg = "Cart created successfully."
			}
			else {
				response.result = false;
				response.msg = "Cart " + request.data.name + " already exists."
			};
			release@SemaphoreUtils(wrtCartsSemaphore)(resp)
		} else if(request.code == 3) { // Acquisto carrello
			acquire@SemaphoreUtils(wrtCartsSemaphore)(resp);
			if(is_defined(global.carts.(request.data.name)) && global.carts.(request.data.name).status != 1) {
				isEmpty = true; // Controllo se il carrello non ha elementi
				foreach ( cartItem : global.carts.(request.data.name).items )
					isEmpty = false;
				if(!isEmpty) { // Se c'è almeno un elemento posso comprare il carrello, altrimenti no
					global.carts.(request.data.name).status = 1; // status 1: comprato

					println@Console("> Bought Cart: " + request.data.name)();
					response.result = true;
					response.msg = "Cart bought successfully."
				} else {
					response.result = false;
					response.msg = "Cannot buy empty cart."
				}
			}
			else {
				response.result = false;
				response.msg = "Cart " + request.data.name + " does not exists or already bought."
			};
			release@SemaphoreUtils(wrtCartsSemaphore)(resp)
		} else if(request.code == 4) { // Eliminazione carrello
			acquire@SemaphoreUtils(wrtCartsSemaphore)(resp);
			if(is_defined(global.carts.(request.data.name)) && global.carts.(request.data.name).status != 1) { // Una volta comprato un carrello non si può cancellare
				acquire@SemaphoreUtils(wrtItemsSemaphore)(resp);
				foreach ( cartItem : global.carts.(request.data.name).items ) { // Rendo gli item del carrello di nuovo disponibili
					if(is_defined(global.items.(cartItem))) { // Se l'elemento esiste, aggiungo gli elementi del carrello
						global.items.(cartItem).quantity += global.carts.(request.data.name).items.(cartItem).quantity
					} else { // Se non esiste più lo ricreo
						global.items.(cartItem).name = global.carts.(request.data.name).items.(cartItem).name;
						global.items.(cartItem).quantity = global.carts.(request.data.name).items.(cartItem).quantity
					}
				};
				release@SemaphoreUtils(wrtItemsSemaphore)(resp);
				undef(global.carts.(request.data.name));
				println@Console("> Deleted Cart: " + request.data.name)();
				response.result = true;
				response.msg = "Cart deleted successfully."
			} else {
				response.result = false;
				response.msg = "Cart " + request.data.name + " does not exist or already bought."
			};
			release@SemaphoreUtils(wrtCartsSemaphore)(resp)
		} else if(request.code == 5) { // Elementi dentro a un carrello
			synchronized(mutexCarts) {
				global.readcountCarts++;
				if(global.readcountCarts == 1)
					acquire@SemaphoreUtils(wrtCartsSemaphore)(resp)
			};
			response << global.carts.(request.data.name).items;
			synchronized(mutexCarts) {
				global.readcountCarts--;
				if(global.readcountCarts == 0)
					release@SemaphoreUtils(wrtCartsSemaphore)(resp)
			}
		} else if(request.code == 6) { // Inserimento elementi in un carrello
			request.data.itemQnt = int(request.data.itemQnt);
			acquire@SemaphoreUtils(wrtCartsSemaphore)(resp);
			if(is_defined(global.carts.(request.data.cartName)) && global.carts.(request.data.cartName).status != 1) {
				acquire@SemaphoreUtils(wrtItemsSemaphore)(resp);
				if(is_defined(global.items.(request.data.itemName)) && global.items.(request.data.itemName).quantity >= request.data.itemQnt) { // L'item esiste e la quantità è sufficiente per coprire la richiesta
					scope(addItemToCart) {
						if(is_defined( global.carts.(request.data.cartName).items.(request.data.itemName) )) // Se l'elemento è già nel carrello aumento la quantità
							global.carts.(request.data.cartName).items.(request.data.itemName).quantity += request.data.itemQnt
						else {
							global.carts.(request.data.cartName).items.(request.data.itemName).name = request.data.itemName |
							global.carts.(request.data.cartName).items.(request.data.itemName).quantity = request.data.itemQnt
						}
					} |
					scope(decreaseQuantity) {
						if(global.items.(request.data.itemName).quantity == request.data.itemQnt) // Se la quantità che si vuole prendere finisce la disponibilità dell'elemento, lo tolgo
							undef(global.items.(request.data.itemName))
						else
							global.items.(request.data.itemName).quantity -= request.data.itemQnt
					};
					println@Console("> Added/Increased Item: " + request.data.itemName + " - in Cart: " + request.data.cartName)();
					response.result = true;
					response.msg = "Added item to cart."
				} else {
					response.result = false;
					response.msg = "Item or quantity not available."
				};
				release@SemaphoreUtils(wrtItemsSemaphore)(resp)
			} else {
				response.result = false;
				response.msg = "Cart " + request.data.cartName + " does not exist or already bought."
			};
			release@SemaphoreUtils(wrtCartsSemaphore)(resp)
		} else if(request.code == 7) { // Eliminazione elementi in un carrello
			request.data.itemQnt = int(request.data.itemQnt);
			acquire@SemaphoreUtils(wrtCartsSemaphore)(resp);
			if(is_defined(global.carts.(request.data.cartName)) && global.carts.(request.data.cartName).status != 1) {
				if(is_defined(global.carts.(request.data.cartName).items.(request.data.itemName))) { // L'item esiste nel carrello
					acquire@SemaphoreUtils(wrtItemsSemaphore)(resp);
					if(!is_defined(global.items.(request.data.itemName))) // Se l'elemento era stato rimosso, lo ricreo
						global.items.(request.data.itemName).name = request.data.itemName;
						
					if(global.carts.(request.data.cartName).items.(request.data.itemName).quantity <= request.data.itemQnt) { // Se la quantità da togliere uguaglia o eccede quella presente, elimino l'item dal carrello
						// Se si vuole togliere di più di quello che c'è, aggiungo negli item disponibli solo quello che relmente c'è
						global.items.(request.data.itemName).quantity += global.carts.(request.data.cartName).items.(request.data.itemName).quantity;
						undef(global.carts.(request.data.cartName).items.(request.data.itemName))
					} else {
						global.items.(request.data.itemName).quantity += request.data.itemQnt |
						global.carts.(request.data.cartName).items.(request.data.itemName).quantity -= request.data.itemQnt
					};
					release@SemaphoreUtils(wrtItemsSemaphore)(resp);

					println@Console("> Removed/Decreased Item: " + request.data.itemName + " - in Cart: " + request.data.cartName)();
					response.result = true;
					response.msg = "Removed/Decreased item from cart."
				} else {
					response.result = false;
					response.msg = "Item not in cart."
				}
			} else {
				response.result = false;
				response.msg = "Cart " + request.data.cartName + " does not exist or already bought."
			};
			release@SemaphoreUtils(wrtCartsSemaphore)(resp)
		} else {
			response.result = false;
			response.msg = "Error in the execution code."
		}
	}] {nullProcess}

  [AdminAction(request)(response) {
    if(request.code == 1) {
			synchronized(mutexItems) {
				global.readcountItems++;
				if(global.readcountItems == 1)
					acquire@SemaphoreUtils(wrtItemsSemaphore)(resp)
			};
			response << global.items;
			synchronized(mutexItems) {
				global.readcountItems--;
				if(global.readcountItems == 0)
					release@SemaphoreUtils(wrtItemsSemaphore)(resp)
			}
    } else if(request.code == 2) {
      request.data.itemQnt = int(request.data.itemQnt);
			acquire@SemaphoreUtils(wrtItemsSemaphore)(resp);
      if(is_defined(global.items.(request.data.itemName))) { // Se l'elemento esiste già incremento la quantità, altrimenti lo creo
        global.items.(request.data.itemName).quantity += request.data.itemQnt;
        response.result = true;
        response.msg = "Increased quantity of item " + request.data.itemName
      }
      else {
        global.items.(request.data.itemName).name = request.data.itemName;
        global.items.(request.data.itemName).quantity = request.data.itemQnt;
        response.result = true;
        response.msg = "Added item " + request.data.itemName + "/" + request.data.itemQnt
      };
			release@SemaphoreUtils(wrtItemsSemaphore)(resp);
      println@Console("> Added/Increased Item: " + request.data.itemName + "/" + request.data.itemQnt)()
    } else if(request.code == 3) {
      request.data.itemQnt = int(request.data.itemQnt);
			acquire@SemaphoreUtils(wrtItemsSemaphore)(resp);
      if(is_defined(global.items.(request.data.itemName))) { // Se l'elemento esiste decremento, altrimenti errore
        if(request.data.itemQnt >= global.items.(request.data.itemName).quantity) { // Se la quantità presente è minore o uguale di quella da togliere, elimino l'elemento
          undef(global.items.(request.data.itemName));
          response.result = true;
          response.msg = "Removed item " + request.data.itemName
        } else {
          global.items.(request.data.itemName).quantity -= request.data.itemQnt;
          response.result = true;
          response.msg = "Decreased item " + request.data.itemName
        }
      }
      else {
        response.result = false;
        response.msg = "Item not in the list."
      };
			release@SemaphoreUtils(wrtItemsSemaphore)(resp);
      println@Console("> Removed/Decreased Item: " + request.data.itemName + "/" + request.data.itemQnt)()
    } else {
      response.result = false;
      response.msg = "Error in the execution code."
    }
	}] {nullProcess}

	[GetShopStatus()(visualizer) {
		install( IOException => println@Console("NetworkVisualizer DOWN")() );

		acquire@SemaphoreUtils(wrtCartsSemaphore)(resp);
		acquire@SemaphoreUtils(wrtItemsSemaphore)(resp);

		visualizer.items << global.items;
		visualizer.carts << global.carts;

		release@SemaphoreUtils(wrtItemsSemaphore)(resp);
		release@SemaphoreUtils(wrtCartsSemaphore)(resp)
	}] {nullProcess}

}

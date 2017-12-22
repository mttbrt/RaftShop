include "console.iol"
include "maininterface.iol"

inputPort ListenerPort {
  Location: "socket://localhost:12000"
	Protocol: sodep
  Interfaces: VisualizerInterface
}

execution { concurrent }

main {

  [GlobalStatus(visualizer)] {

    scope (leader) {
      println@Console("LEADER: " + visualizer.leader.id + " at port: " + visualizer.leader.port)()
    };

    scope (servers) {
      for ( i = 0, i < #visualizer.servers.status, i++ )
        if (visualizer.servers.status[i])
          println@Console("Server" + i + ": UP")()
        else
          println@Console("Server" + i + ": DOWN")()
    };

    scope (items) {
      println@Console("Items:")();
      foreach (item : visualizer.items)
        println@Console("- " + visualizer.items.(item).name + " / " + visualizer.items.(item).quantity)()
    };

    scope (carts) {
      println@Console("Carts:")();
      foreach (cart : visualizer.carts) {
        if(visualizer.carts.(cart).status == 1)
          println@Console("> " + visualizer.carts.(cart).name + " (bought)")()
        else
          println@Console("> " + visualizer.carts.(cart).name + " (open)")();
        foreach (item : visualizer.carts.(cart).items)
          println@Console("  |_ " + visualizer.carts.(cart).items.(item).name + " / " + visualizer.carts.(cart).items.(item).quantity)()
      }
    };

    println@Console()()

  }

}

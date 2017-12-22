include "console.iol"
include "time.iol"
include "../maininterface.iol"

inputPort In {
	Location: "local"
	Interfaces: TimerInterface
}

outputPort Out {
	Protocol: sodep
	Interfaces: TimerInterface
}

execution { concurrent }

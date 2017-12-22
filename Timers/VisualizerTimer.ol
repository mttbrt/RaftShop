include "Static/timerHeader.iol"

main {
	[SetVisualizerTimer(request)] {
		millis.message = request.port;
		millis = request;
		setNextTimeout@Time(millis)
	}

	[timeout(msg)] {
		Out.location = "socket://localhost:" + msg;
		VisualizerTimeout@Out()
	}
}

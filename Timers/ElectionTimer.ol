include "Static/timerHeader.iol"

main {
	[SetElectionTimer(request)] {
		millis.message = request.port;
		millis = request;
		setNextTimeout@Time(millis)
	}

	[timeout(msg)] {
		Out.location = ("socket://localhost:" + msg);
		ElectionTimeout@Out()
	}
}

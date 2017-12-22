include "Static/timerHeader.iol"

main {
	[SetHeartbeatTimer(request)] {
		millis.message = request.port;
		millis = request;
		setNextTimeout@Time(millis)
	}

	[timeout(msg)] {
		Out.location = "socket://localhost:" + msg;
		HeartbeatTimeoutB@Out()
	}
}

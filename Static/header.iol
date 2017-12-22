include "console.iol"
include "file.iol"
include "math.iol"
include "string_utils.iol"
include "time.iol"
include "semaphore_utils.iol"
include "maininterface.iol"

// Servizio Jolie embeddato che lavora sui dati
outputPort DataManager {
  Interfaces: ClientActionInterface, AdminActionInterface, VisualizerActionInterface
}

// Microservizi che gestiscono più timer in parallelo
outputPort VisualizerTimer {
  Interfaces: TimerInterface
}

outputPort HeartbeatTimerA {
  Interfaces: TimerInterface
}

outputPort HeartbeatTimerB {
  Interfaces: TimerInterface
}

outputPort HeartbeatTimerC {
  Interfaces: TimerInterface
}

outputPort HeartbeatTimerD {
  Interfaces: TimerInterface
}

outputPort ElectionTimer {
  Interfaces: TimerInterface
}

// Embedding
embedded {
  Jolie: "DataManager.ol" in DataManager
  Jolie: "Timers/VisualizerTimer.ol" in VisualizerTimer
  Jolie: "Timers/HeartbeatTimerA.ol" in HeartbeatTimerA
  Jolie: "Timers/HeartbeatTimerB.ol" in HeartbeatTimerB
  Jolie: "Timers/HeartbeatTimerC.ol" in HeartbeatTimerC
  Jolie: "Timers/HeartbeatTimerD.ol" in HeartbeatTimerD
  Jolie: "Timers/ElectionTimer.ol" in ElectionTimer
}

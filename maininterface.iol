// Timers

type TimerRequest: int {
  .port: string
}

interface TimerInterface {
	OneWay: timeout(undefined),

          SetVisualizerTimer(TimerRequest),
					VisualizerTimeout(void),

          SetHeartbeatTimer(TimerRequest),
					HeartbeatTimeoutA(void),
					HeartbeatTimeoutB(void),
					HeartbeatTimeoutC(void),
					HeartbeatTimeoutD(void),

          SetElectionTimer(TimerRequest),
					ElectionTimeout(void),
}

// Election

type RRRequestVoteType : void{
  .term : int
  .candidateID : int
  .lastLogIndex : int
  .lastLogTerm : int
}

type RRVoteType : void {
  .VoteGranted: bool
  .Term: int
}

type HeartbeatType : void{
  .result : bool
  .leaderID : string
}

interface ElectionInterface {
  RequestResponse: RequestVote(RRRequestVoteType)(RRVoteType)
  OneWay: Heartbeat(HeartbeatType)
}

// AppendEntries

type LogEntry: void {
  .entry: RequestType | void
  .adminAction: bool
  .term: int
}

type AppendEntriesType: void {
  .term: int //termine del leader in quel momento
  .leaderID: int //l'identificativo del server che ha mandato (presumibilmente il leader)
  .prevLogIndex: int // indice della voce del log immediatamente precedente le nuove voci da aggiungere
  .prevLogTerm: int | void //il termine della voce del log indicata da prevLogIndex
  .entries*: LogEntry | void // le voci del log da includere (se è un hertbeat sarà vuoto)
  .leaderCommit: int //commitIndex del Leader
}

type AckType: void {
  .term: int
  .success: bool
  .senderID: int
  .lastIndex: int // Per aggiornare il nexIndices del leader con l'ultimo elemento del log del server
  .isHeartbeat: bool
  .replicatedIndex?: int
  .replicatedTerm?: int
  .conflictingIndex?: int
}

interface ServerInterface {
  OneWay: AppendEntries(AppendEntriesType),
          Ack(AckType)
}

// NetworkVisualizer

type LeaderType: void {
  .id: int
  .port: string
}

type ServersStatusType: void {
  .status*: bool
}

type VisualizerType: void {
  .leader: LeaderType
  .servers: ServersStatusType
  .items: undefined
  .carts: undefined
}

interface VisualizerInterface {
  OneWay: GlobalStatus(VisualizerType)
}

// Admin/Client Interface

type EditCartType:void {
  .name:string
}

type EditItemInCartType:void {
  .cartName:string
  .itemName:string
  .itemQnt:undefined
}

type EditItemInListType:void {
  .itemName:string
  .itemQnt:undefined
}

type BasicResponse:void {
  .result:bool
  .msg:string
}

type LeaderAddress: void {
  .address:string
}

type RequestType: void {
  .code: int
  .data: EditItemInCartType | EditItemInListType | EditCartType | void | string // String è per l'integrazione html, che non può trasferire void
}

type ResponseType: LeaderAddress | BasicResponse | undefined

// > Admin/Client to Server

interface ClientInterface {
  RequestResponse: ClientRequest(RequestType)(ResponseType),
                   ClientHTTPDefault(undefined)(undefined)
}

interface AdminInterface {
  RequestResponse: AdminRequest(RequestType)(ResponseType),
                   AdminHTTPDefault(undefined)(undefined)
}

// > Server to Micro-Service

interface ClientActionInterface {
  RequestResponse: ClientAction(RequestType)(ResponseType)
}

interface AdminActionInterface {
  RequestResponse: AdminAction(RequestType)(ResponseType)
}

interface VisualizerActionInterface {
  RequestResponse: GetShopStatus(void)(undefined)
}

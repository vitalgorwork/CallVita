enum CallFlowEvent {
    case incomingCall
    case startOutgoingCall

    case acceptTapped
    case declineTapped

    case connectionEstablished
    case connectionFailed

    case endTapped
    case reset
}

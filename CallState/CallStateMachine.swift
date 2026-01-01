struct CallStateMachine {

    static func nextState(
        from current: CallFlowState,
        event: CallFlowEvent
    ) -> CallFlowState? {

        switch (current, event) {

        case (.idle, .incomingCall),
             (.idle, .startOutgoingCall):
            return .ringing

        case (.ringing, .acceptTapped):
            return .connecting

        case (.ringing, .declineTapped):
            return .ended

        case (.connecting, .connectionEstablished):
            return .connected

        case (.connecting, .connectionFailed):
            return .ended

        case (.connected, .endTapped):
            return .ended

        case (.ended, .reset):
            return .idle

        default:
            return nil
        }
    }
}

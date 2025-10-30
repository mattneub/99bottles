/// A state is merely a class that knows how to generate the next state.
/// (This simplicity is possible because our states go in a fixed cycle.)
protocol StateType: AnyObject {
    func nextState() -> (any StateType)?
}

/// A state machine is a class that has a state and can proceed to the next state by asking
/// its state to generate the next state and making _that_ its state.
protocol StateMachineType: AnyObject {
    var currentState: (any StateType)? { get set }
    func proceedToNextState()
}

extension StateMachineType {
    func proceedToNextState() {
        currentState = currentState?.nextState()
    }
}

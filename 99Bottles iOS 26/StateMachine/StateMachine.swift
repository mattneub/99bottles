
/// A state machine is a class that has a state and can proceed to the next state by asking
/// its state to generate the next state and making _that_ its state. That's all it does, and
/// all it needs to do; the client "drives" the succession of states by calling
/// `proceedToNextState`, and the states themselves know what state comes next.
protocol StateMachineType: AnyObject {
    var currentState: (any StateType)? { get set }
    func proceedToNextState() -> (any StateType)?
}

final class StateMachine: StateMachineType {
    var currentState: (any StateType)?

    /// Private in order to force the client to use the StateMachineFactory to make a state machine.
    /// This is so that we can test the client's interaction with the state machine by injecting
    /// a mock.
    fileprivate init(bottleNumber: Int, interactive: Bool) {
        self.currentState = Preparer(bottleNumber: bottleNumber, interactive: interactive)
    }

    func proceedToNextState() -> (any StateType)? {
        currentState = currentState?.nextState()
        return currentState
    }
}

/// A state machine factory is a simple object that makes a state machine. We use this architecture
/// so that we can inject our own state machine mock for testing purposes.
protocol StateMachineFactoryType {
    func makeStateMachine(bottleNumber: Int, interactive: Bool) -> any StateMachineType
}

struct StateMachineFactory: StateMachineFactoryType {
    func makeStateMachine(bottleNumber: Int, interactive: Bool) -> any StateMachineType {
        StateMachine(bottleNumber: bottleNumber, interactive: interactive)
    }
}

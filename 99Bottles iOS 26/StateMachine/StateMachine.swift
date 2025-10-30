final class StateMachine: StateMachineType {
    var currentState: (any StateType)?

    init(bottleNumber: Int, interactive: Bool = false) {
        self.currentState = Preparer(bottleNumber: bottleNumber, interactive: interactive)
    }
}

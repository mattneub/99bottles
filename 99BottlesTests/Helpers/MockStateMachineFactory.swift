@testable import Bottles

final class MockStateMachineFactory: StateMachineFactoryType {
    var stateMachineToMake = MockStateMachine() // placeholder; client should inject replacement

    func makeStateMachine(bottleNumber: Int, interactive: Bool) -> any StateMachineType {
        stateMachineToMake.bottleNumber = bottleNumber
        stateMachineToMake.interactive = interactive
        return stateMachineToMake
    }
}

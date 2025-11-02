@testable import Bottles

final class MockStateMachineFactory: StateMachineFactoryType {
    var stateMachineToMake = MockStateMachine() // placeholder; client should inject replacement

    func makeStateMachine(howManyBottles: Int, interactive: Bool) -> any StateMachineType {
        stateMachineToMake.howManyBottles = howManyBottles
        stateMachineToMake.interactive = interactive
        return stateMachineToMake
    }
}

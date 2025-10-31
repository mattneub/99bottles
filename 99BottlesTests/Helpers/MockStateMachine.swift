@testable import Bottles

final class MockStateMachine: StateMachineType {
    var methodsCalled = [String]()
    var statesToReturn = [(any StateType)?]()
    var currentState: (any StateType)?
    var bottleNumber: Int?
    var interactive: Bool?

    func proceedToNextState() -> (any StateType)? {
        methodsCalled.append(#function)
        return statesToReturn.removeFirst()
    }
}

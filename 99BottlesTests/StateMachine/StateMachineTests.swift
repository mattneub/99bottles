@testable import Bottles
import Testing
import Foundation

struct StateMachineTests {
    @Test("initialize: makes a Preparer as the current state")
    func initialize() throws {
        let subject = StateMachineFactory().makeStateMachine(bottleNumber: 42, interactive: true)
        let preparer = try #require(subject.currentState as? Preparer)
        #expect(preparer.interactive == true)
        #expect(preparer.bottleNumber == 42)
    }

    @Test("proceedToNextState: asks current state for next state, makes that next state, returns it")
    func proceed() {
        let subject = StateMachineFactory().makeStateMachine(bottleNumber: 42, interactive: true)
        subject.currentState = Manny()
        var previousCurrentState = subject.currentState
        let result1 = subject.proceedToNextState()
        #expect((previousCurrentState as? Manny)?.methodsCalled == ["nextState()"])
        #expect(result1 is Moe)
        #expect(subject.currentState is Moe)
        previousCurrentState = subject.currentState
        let result2 = subject.proceedToNextState()
        #expect((previousCurrentState as? Moe)?.methodsCalled == ["nextState()"])
        #expect(result2 is Jack)
        #expect(subject.currentState is Jack)
        previousCurrentState = subject.currentState
        let result3 = subject.proceedToNextState()
        #expect((previousCurrentState as? Jack)?.methodsCalled == ["nextState()"])
        #expect(result3 == nil)
        #expect(subject.currentState == nil)
    }
}

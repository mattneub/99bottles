@testable import Bottles
import Testing
import Foundation

struct StateMachineTests {
    @Test("initialize: makes a Preparer as the current state")
    func initialize() throws {
        let subject = StateMachine(bottleNumber: 42, interactive: true)
        let preparer = try #require(subject.currentState as? Preparer)
        #expect(preparer.interactive == true)
        #expect(preparer.bottleNumber == 42)
    }
}

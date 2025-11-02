@testable import Bottles
import Testing
import Foundation

struct WaitingForTapTests {
    @Test("nextStage gives Singer with same specifications")
    func nextStage() throws {
        let subject = WaitingForTap(howManyBottles: 99, interactive: true, verse: [.init(sound: "howdy")])
        let nextState = try #require(subject.nextState() as? Singer)
        #expect(nextState.howManyBottles == 99)
        #expect(nextState.interactive == true)
        #expect(nextState.verse == subject.verse)
    }
}

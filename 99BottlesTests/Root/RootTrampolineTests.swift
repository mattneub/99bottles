@testable import Bottles
import Testing

struct RootTrampolineTests {
    @Test("startOver: sends `.initialLayout` to processor")
    func startOver() async {
        let processor = MockReceiver<RootAction>()
        let subject = RootTrampoline(processor: processor)
        await subject.startOver()
        #expect(processor.thingsReceived == [.initialLayout])
    }
}

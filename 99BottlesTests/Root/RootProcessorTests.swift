@testable import Bottles
import Testing
import Foundation

struct RootProcessorTests {
    let subject = RootProcessor()
    let presenter = MockReceiverPresenter<RootEffect, RootState>()

    init() {
        subject.presenter = presenter
    }

    @Test("initialLayout: sends startOver")
    func initialLayout() async {
        await subject.receive(.initialLayout)
        #expect(presenter.thingsReceived == [.startOver])
    }
}

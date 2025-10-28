import Foundation
@testable import Bottles
import Testing

struct PreferencesProcessorTests {
    let subject = PreferencesProcessor()
    let presenter = MockReceiverPresenter<Void, PreferencesState>()
    let coordinator = MockRootCoordinator()
    let persistence = MockPersistence()

    init() {
        subject.presenter = presenter
        subject.coordinator = coordinator
        services.persistence = persistence
    }

    @Test("cancel: calls dismiss")
    func cancel() async {
        await subject.receive(.cancel)
        #expect(coordinator.methodsCalled == ["dismiss()"])
    }

    @Test("done: sets persistence, calls dismiss")
    func done() async {
        await subject.receive(.done(21, false))
        #expect(persistence.methodsCalled == ["setLayoutNumber(_:)", "setInteractive(_:)"])
        #expect(persistence.layout == 21)
        #expect(persistence.isInteractive == true) // false autoplay means true interactive
    }

    @Test("initialData: configures state, presents it")
    func initialData() async {
        persistence.interactiveToReturn = true
        persistence.layoutToReturn = 21
        await subject.receive(.initialData)
        #expect(subject.state.layoutNumber == 21)
        #expect(subject.state.autoplay == false) // true interactive means false autoplay
        #expect(presenter.statesPresented == [subject.state])
    }
}

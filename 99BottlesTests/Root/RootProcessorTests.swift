@testable import Bottles
import Testing
import Foundation

struct RootProcessorTests {
    let subject = RootProcessor()
    let presenter = MockReceiverPresenter<RootEffect, RootState>()
    let coordinator = MockRootCoordinator()
    let persistence = MockPersistence()

    init() {
        subject.presenter = presenter
        subject.coordinator = coordinator
        services.persistence = persistence
    }

    @Test("initialLayout: get layout number from persistence, sends startOver")
    func initialLayout() async {
        persistence.layoutToReturn = 4
        await subject.receive(.initialLayout)
        #expect(persistence.methodsCalled == ["layoutNumber()"])
        #expect(presenter.thingsReceived == [.startOver(BottleLayout.layouts[4])])
    }

    @Test("tapped: constructs and sends coordinator showActionSheet")
    func tapped() async {
        coordinator.actionToReturn = nil
        await subject.receive(.tapped)
        #expect(coordinator.methodsCalled == ["showActionSheet(title:titles:userInfos:)"])
        #expect(coordinator.title == nil)
        #expect(coordinator.titles == ["Resume", "Start Over", "Preferences"])
        #expect(coordinator.userInfos.elementsEqual(
            [
                ["result": RootProcessor.TapAction.resume],
                ["result": RootProcessor.TapAction.startOver],
                ["result": RootProcessor.TapAction.preferences],
            ], by: { dictionary1, dictionary2 in
                dictionary1 as? [String: RootProcessor.TapAction] == dictionary2
            }
        ))
    }

    @Test("tapped: if result is .preferences, call coordinator showPreferences")
    func tappedPreferences() async {
        coordinator.actionToReturn = MyAlertAction().applying {
            $0.userInfo = ["result": RootProcessor.TapAction.preferences]
        }
        await subject.receive(.tapped)
        #expect(coordinator.methodsCalled == ["showActionSheet(title:titles:userInfos:)", "showPreferences()"])
    }

    @Test("done: get layout number from persistence, sends startOver")
    func done() async {
        persistence.layoutToReturn = 4
        await subject.done()
        #expect(persistence.methodsCalled == ["layoutNumber()"])
        #expect(presenter.thingsReceived == [.startOver(BottleLayout.layouts[4])])
    }
}

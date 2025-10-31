@testable import Bottles
import Testing
import Foundation
import CoreGraphics
import WaitWhile

struct RootProcessorTests {
    let subject = RootProcessor()
    let presenter = MockReceiverPresenter<RootEffect, RootState>()
    let coordinator = MockRootCoordinator()
    let persistence = MockPersistence()
    let stateMachine = MockStateMachine()
    let stateMachineFactory = MockStateMachineFactory()

    init() {
        subject.presenter = presenter
        subject.coordinator = coordinator
        services.persistence = persistence
        stateMachineFactory.stateMachineToMake = stateMachine
        services.stateMachineFactory = stateMachineFactory
    }

    @Test("initialLayout: get layout number from persistence, sends startOver and proposeBottle")
    func initialLayout() async {
        persistence.layoutToReturn = 4
        await subject.receive(.initialLayout)
        #expect(persistence.methodsCalled == ["layoutNumber()"])
        #expect(presenter.thingsReceived == [.startOver(BottleLayout.layouts[4]), .proposeBottle])
    }

    @Test("proposeBottle: sets state, creates state machine, calls its proceed, ends with presenter updateLabel and proposeBottle")
    func proposeBottle() async throws {
        stateMachine.statesToReturn = [nil]
        let bottleLayer = BottleLayer.init(bottleNumber: 2, scale: 2, screenBounds: .zero)
        await subject.receive(.proposeBottle(bottleLayer, count: 4))
        #expect(stateMachine.bottleNumber == 4)
        #expect(stateMachine.interactive == false)
        #expect(stateMachine.methodsCalled == ["proceedToNextState()"])
        #expect(subject.state.currentBottle === bottleLayer)
        #expect(subject.state.count == 4)
        #expect(presenter.thingsReceived == [.updateLabel, .proposeBottle])
    }

    @Test("proposeBottle: makes state machine interactive if persistence interactive")
    func proposeBottleInteractive() async throws {
        persistence.interactiveToReturn = true // *
        stateMachine.statesToReturn = [nil]
        let bottleLayer = BottleLayer.init(bottleNumber: 2, scale: 2, screenBounds: .zero)
        await subject.receive(.proposeBottle(bottleLayer, count: 4))
        #expect(stateMachine.bottleNumber == 4)
        #expect(stateMachine.interactive == true) // *
        #expect(stateMachine.methodsCalled == ["proceedToNextState()"])
        #expect(subject.state.currentBottle === bottleLayer)
        #expect(subject.state.count == 4)
        #expect(presenter.thingsReceived == [.updateLabel, .proposeBottle])
    }

    @Test("proposeBottle: cycles through `proceed` results until nil, calls `sing` on any singers")
    func proposeBottleSeries() async throws {
        let manny = Manny(), moe = Moe(), jack = Jack()
        stateMachine.statesToReturn = [manny, moe, jack, nil]
        let bottleLayer = BottleLayer.init(bottleNumber: 2, scale: 2, screenBounds: .zero)
        await subject.receive(.proposeBottle(bottleLayer, count: 4))
        #expect(stateMachine.bottleNumber == 4)
        #expect(stateMachine.interactive == false)
        #expect(stateMachine.methodsCalled == ["proceedToNextState()", "proceedToNextState()", "proceedToNextState()", "proceedToNextState()"])
        #expect(subject.state.currentBottle === bottleLayer)
        #expect(subject.state.count == 4)
        #expect(presenter.thingsReceived == [.updateLabel, .proposeBottle])
        #expect(manny.methodsCalled == [])
        #expect(moe.methodsCalled == ["sing(bottleLayer:)"]) // Moe is a SingerType
        #expect(moe.bottleLayer == bottleLayer)
        #expect(jack.methodsCalled == [])
    }

    @Test("proposeBottle: stops cycling if WaitingForTap state is encountered")
    func proposeBottleSeriesWaitingForTap() async throws {
        let manny = Manny(), moe = WaitingForTap(bottleNumber: 7, interactive: false, verse: []), jack = Jack()
        stateMachine.statesToReturn = [manny, moe, jack, nil]
        let bottleLayer = BottleLayer.init(bottleNumber: 2, scale: 2, screenBounds: .zero)
        await subject.receive(.proposeBottle(bottleLayer, count: 4))
        #expect(stateMachine.bottleNumber == 4)
        #expect(stateMachine.interactive == false)
        #expect(stateMachine.methodsCalled == ["proceedToNextState()", "proceedToNextState()"]) // and stops
        #expect(subject.state.currentBottle === bottleLayer)
        #expect(subject.state.count == 4)
        #expect(presenter.thingsReceived == [])
        #expect(manny.methodsCalled == [])
    }

    @Test("tapped: constructs and sends coordinator showActionSheet")
    func tapped() async {
        coordinator.actionToReturn = nil
        await subject.receive(.tapped(nil))
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

    @Test("tapped: with bottle layer but state machine state is not WaitingForTap, still shows action sheet")
    func tappedBottle() async {
        coordinator.actionToReturn = nil
        stateMachine.currentState = Singer(bottleNumber: 1, interactive: false, verse: [.init(sound: "howdy")])
        subject.stateMachine = stateMachine
        await subject.receive(.tapped(BottleLayer(bottleNumber: 2, scale: 2, screenBounds: .zero)))
        #expect(coordinator.methodsCalled == ["showActionSheet(title:titles:userInfos:)"])
    }

    @Test("tapped: with no bottle layer and state machine state is WaitingForTap, still shows action sheet")
    func tappedWaiting() async {
        coordinator.actionToReturn = nil
        stateMachine.currentState = WaitingForTap(bottleNumber: 2, interactive: false, verse: [.init(sound: "howdy")])
        subject.stateMachine = stateMachine
        await subject.receive(.tapped(nil))
        #expect(coordinator.methodsCalled == ["showActionSheet(title:titles:userInfos:)"])
    }

    @Test("tapped: with bottle layer and state machine state is WaitingForTap, configures state, proceeds and behaves like proposeBottle")
    func tappedBottleWaiting() async {
        let manny = Manny(), moe = Moe(), jack = Jack()
        stateMachine.statesToReturn = [manny, moe, jack, nil]
        stateMachine.currentState = WaitingForTap(bottleNumber: 3, interactive: false, verse: [.init(sound: "howdy")])
        stateMachine.bottleNumber = 4
        stateMachine.interactive = false
        subject.state = .init(count: 4, currentBottle: .init(bottleNumber: 3, scale: 2, screenBounds: .zero))
        subject.stateMachine = stateMachine
        let bottleLayer = BottleLayer.init(bottleNumber: 2, scale: 2, screenBounds: .zero)
        await subject.receive(.tapped(bottleLayer))
        // the real point of the test is to show that the new bottle layer has been substituted
        #expect(stateMachine.bottleNumber == 4)
        #expect(stateMachine.interactive == false)
        #expect(stateMachine.methodsCalled == ["proceedToNextState()", "proceedToNextState()", "proceedToNextState()", "proceedToNextState()"])
        #expect(subject.state.currentBottle === bottleLayer) // *
        #expect(subject.state.count == 4)
        #expect(presenter.thingsReceived == [.updateLabel, .proposeBottle])
        #expect(manny.methodsCalled == [])
        #expect(moe.methodsCalled == ["sing(bottleLayer:)"]) // Moe is a SingerType
        #expect(moe.bottleLayer == bottleLayer) // *
        #expect(jack.methodsCalled == [])
    }

    @Test("tapped: if result is .preferences, call coordinator showPreferences")
    func tappedPreferences() async {
        coordinator.actionToReturn = MyAlertAction().applying {
            $0.userInfo = ["result": RootProcessor.TapAction.preferences]
        }
        await subject.receive(.tapped(nil))
        #expect(coordinator.methodsCalled == ["showActionSheet(title:titles:userInfos:)", "showPreferences()"])
    }

    @Test("done: exactly like .initialLayout")
    func done() async {
        persistence.layoutToReturn = 4
        await subject.done()
        #expect(persistence.methodsCalled == ["layoutNumber()"])
        #expect(presenter.thingsReceived == [.startOver(BottleLayout.layouts[4]), .proposeBottle])
    }
}

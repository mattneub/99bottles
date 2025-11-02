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
    let trampoline = MockRootTrampoline(processor: nil)

    init() {
        subject.presenter = presenter
        subject.coordinator = coordinator
        subject.trampoline = trampoline
        services.persistence = persistence
        stateMachineFactory.stateMachineToMake = stateMachine
        services.stateMachineFactory = stateMachineFactory
    }

    @Test("deactivate: stop looping, singing, animating")
    func deactivate() async {
        subject.loopingTask = Task { try? await Task.sleep(for: .seconds(4)) }
        subject.stateMachine = stateMachine
        let singer = Moe()
        stateMachine.currentState = singer
        await subject.receive(.deactivate)
        #expect(subject.loopingTask?.isCancelled == true)
        #expect(singer.methodsCalled == ["stop()"])
        #expect(presenter.thingsReceived == [.cancelAnimations])
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
        subject.loopingTask = nil
        stateMachine.statesToReturn = [nil]
        let bottleLayer = BottleLayer.init(bottleNumber: 2, scale: 2, screenBounds: .zero)
        await subject.receive(.proposeBottle(bottleLayer, count: 4))
        #expect(subject.loopingTask != nil)
        let taskResult = await subject.loopingTask!.result
        #expect(try taskResult.get() == ())
        #expect(stateMachine.howManyBottles == 4)
        #expect(stateMachine.interactive == false)
        #expect(stateMachine.methodsCalled == ["proceedToNextState()"])
        #expect(subject.state.currentBottle === bottleLayer)
        #expect(subject.state.count == 4)
        await #while(presenter.thingsReceived.count < 2)
        #expect(presenter.thingsReceived == [.updateLabel, .proposeBottle])
    }

    @Test("proposeBottle: makes state machine interactive if persistence interactive")
    func proposeBottleInteractive() async throws {
        subject.loopingTask = nil
        persistence.interactiveToReturn = true // *
        stateMachine.statesToReturn = [nil]
        let bottleLayer = BottleLayer.init(bottleNumber: 2, scale: 2, screenBounds: .zero)
        await subject.receive(.proposeBottle(bottleLayer, count: 4))
        #expect(subject.loopingTask != nil)
        let taskResult = await subject.loopingTask!.result
        #expect(try taskResult.get() == ())
        #expect(stateMachine.howManyBottles == 4)
        #expect(stateMachine.interactive == true) // *
        #expect(stateMachine.methodsCalled == ["proceedToNextState()"])
        #expect(subject.state.currentBottle === bottleLayer)
        #expect(subject.state.count == 4)
        await #while(presenter.thingsReceived.count < 2)
        #expect(presenter.thingsReceived == [.updateLabel, .proposeBottle])
    }

    @Test("proposeBottle: cycles through `proceed` results until nil, calls `sing` on any singers")
    func proposeBottleSeries() async throws {
        subject.loopingTask = nil
        let manny = Manny(), moe = Moe(), jack = Jack()
        stateMachine.statesToReturn = [manny, moe, jack, nil]
        let bottleLayer = BottleLayer.init(bottleNumber: 2, scale: 2, screenBounds: .zero)
        await subject.receive(.proposeBottle(bottleLayer, count: 4))
        #expect(subject.loopingTask != nil)
        let taskResult = await subject.loopingTask!.result
        #expect(try taskResult.get() == ())
        #expect(stateMachine.howManyBottles == 4)
        #expect(stateMachine.interactive == false)
        #expect(stateMachine.methodsCalled == ["proceedToNextState()", "proceedToNextState()", "proceedToNextState()", "proceedToNextState()"])
        #expect(subject.state.currentBottle === bottleLayer)
        #expect(subject.state.count == 4)
        #expect(manny.methodsCalled == [])
        #expect(moe.methodsCalled == ["sing(bottleLayer:)"]) // Moe is a SingerType
        #expect(moe.bottleLayer == bottleLayer)
        #expect(jack.methodsCalled == [])
        await #while(presenter.thingsReceived.count < 2)
        #expect(presenter.thingsReceived == [.updateLabel, .proposeBottle])
    }

    @Test("proposeBottle: stops cycling if WaitingForTap state is encountered")
    func proposeBottleSeriesWaitingForTap() async throws {
        subject.loopingTask = nil
        let manny = Manny(), moe = WaitingForTap(howManyBottles: 7, interactive: false, verse: []), jack = Jack()
        stateMachine.statesToReturn = [manny, moe, jack, nil]
        let bottleLayer = BottleLayer.init(bottleNumber: 2, scale: 2, screenBounds: .zero)
        await subject.receive(.proposeBottle(bottleLayer, count: 4))
        #expect(subject.loopingTask != nil)
        let taskResult = await subject.loopingTask!.result
        #expect(throws: RootProcessor.Exit.exit) {
            try taskResult.get()
        }
        #expect(stateMachine.howManyBottles == 4)
        #expect(stateMachine.interactive == false)
        #expect(stateMachine.methodsCalled == ["proceedToNextState()", "proceedToNextState()"]) // and stops
        #expect(subject.state.currentBottle === bottleLayer)
        #expect(subject.state.count == 4)
        #expect(presenter.thingsReceived == [])
        #expect(manny.methodsCalled == [])
    }

    @Test("tapped: cancels looping task, stops singing, cancels animation, constructs and sends coordinator showActionSheet")
    func tapped() async {
        coordinator.actionToReturn = nil
        subject.loopingTask = Task { try await Task.sleep(for: .seconds(1)) }
        subject.stateMachine = stateMachine
        let singer = Moe()
        stateMachine.currentState = singer
        await subject.receive(.tapped(nil))
        #expect(subject.loopingTask?.isCancelled == true)
        #expect(singer.methodsCalled == ["stop()"])
        #expect(presenter.thingsReceived == [.cancelAnimations])
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
        stateMachine.currentState = Singer(howManyBottles: 1, interactive: false, verse: [.init(sound: "howdy")])
        subject.stateMachine = stateMachine
        subject.loopingTask = Task { try await Task.sleep(for: .seconds(1)) }
        subject.stateMachine = stateMachine
        let singer = Moe()
        stateMachine.currentState = singer
        await subject.receive(.tapped(BottleLayer(bottleNumber: 2, scale: 2, screenBounds: .zero)))
        #expect(subject.loopingTask?.isCancelled == true)
        #expect(singer.methodsCalled == ["stop()"])
        #expect(presenter.thingsReceived == [.cancelAnimations])
        #expect(coordinator.methodsCalled == ["showActionSheet(title:titles:userInfos:)"])
    }

    @Test("tapped: with no bottle layer and state machine state is WaitingForTap, still shows action sheet")
    func tappedWaiting() async {
        coordinator.actionToReturn = nil
        stateMachine.currentState = WaitingForTap(howManyBottles: 2, interactive: false, verse: [.init(sound: "howdy")])
        subject.stateMachine = stateMachine
        subject.loopingTask = Task { try await Task.sleep(for: .seconds(1)) }
        subject.stateMachine = stateMachine
        let singer = Moe()
        stateMachine.currentState = singer
        await subject.receive(.tapped(nil))
        #expect(subject.loopingTask?.isCancelled == true)
        #expect(singer.methodsCalled == ["stop()"])
        #expect(presenter.thingsReceived == [.cancelAnimations])
        #expect(coordinator.methodsCalled == ["showActionSheet(title:titles:userInfos:)"])
    }

    @Test("tapped: with bottle layer and state machine state is WaitingForTap, configures state, proceeds and behaves like proposeBottle")
    func tappedBottleWaiting() async {
        let manny = Manny(), moe = Moe(), jack = Jack()
        stateMachine.statesToReturn = [manny, moe, jack, nil]
        stateMachine.currentState = WaitingForTap(howManyBottles: 3, interactive: false, verse: [.init(sound: "howdy")])
        stateMachine.howManyBottles = 4
        stateMachine.interactive = false
        subject.state = .init(count: 4, currentBottle: .init(bottleNumber: 3, scale: 2, screenBounds: .zero))
        subject.stateMachine = stateMachine
        let fakeTask = Task { try await Task.sleep(for: .seconds(1)) }
        subject.loopingTask = fakeTask
        let bottleLayer = BottleLayer.init(bottleNumber: 2, scale: 2, screenBounds: .zero)
        await subject.receive(.tapped(bottleLayer))
        #expect(subject.loopingTask != nil)
        #expect(subject.loopingTask != fakeTask)
        // the real point of the test is to show that the new bottle layer has been substituted
        #expect(stateMachine.howManyBottles == 4)
        #expect(stateMachine.interactive == false)
        #expect(stateMachine.methodsCalled == ["proceedToNextState()", "proceedToNextState()", "proceedToNextState()", "proceedToNextState()"])
        #expect(subject.state.currentBottle === bottleLayer) // *
        #expect(subject.state.count == 4)
        #expect(manny.methodsCalled == [])
        #expect(moe.methodsCalled == ["sing(bottleLayer:)"]) // Moe is a SingerType
        #expect(moe.bottleLayer == bottleLayer) // *
        #expect(jack.methodsCalled == [])
        await #while(presenter.thingsReceived.count < 2)
        #expect(presenter.thingsReceived == [.updateLabel, .proposeBottle])
    }

    @Test("tapped: if result is .resume, send .updateLabel and .proposeBottle")
    func tappedResume() async {
        coordinator.actionToReturn = MyAlertAction().applying {
            $0.userInfo = ["result": RootProcessor.TapAction.resume]
        }
        await subject.receive(.tapped(nil))
        #expect(presenter.thingsReceived == [.cancelAnimations, .updateLabel, .proposeBottle])
    }

    @Test("tapped: if result is start over, sends trampoline startOver")
    func tappedStartOver() async {
        coordinator.actionToReturn = MyAlertAction().applying {
            $0.userInfo = ["result": RootProcessor.TapAction.startOver]
        }
        await subject.receive(.tapped(nil))
        #expect(trampoline.methodsCalled == ["startOver()"])
    }

    @Test("tapped: if result is .preferences, call coordinator showPreferences")
    func tappedPreferences() async {
        coordinator.actionToReturn = MyAlertAction().applying {
            $0.userInfo = ["result": RootProcessor.TapAction.preferences]
        }
        await subject.receive(.tapped(nil))
        #expect(coordinator.methodsCalled == ["showActionSheet(title:titles:userInfos:)", "showPreferences()"])
    }

    @Test("done: calls trampoline startOver")
    func done() async {
        await subject.done()
        #expect(trampoline.methodsCalled == ["startOver()"])
    }
}

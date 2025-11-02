import Foundation

/// Logic of the Root module.
final class RootProcessor: Processor {
    /// Reference to the coordinator, set by coordinator at module creation time.
    weak var coordinator: (any RootCoordinatorType)?

    /// Reference to the presenter, set by coordinator at module creation time.
    weak var presenter: (any ReceiverPresenter<RootEffect, RootState>)?

    /// Trampoline so we can send actions to ourself.
    lazy var trampoline: any RootTrampolineType = RootTrampoline(processor: self)

    /// State to be presented for display, but in fact we use it only as a scratchpad.
    var state = RootState()

    /// State machine that drives the progress of each verse of the song.
    var stateMachine: (any StateMachineType)?

    /// Task that loops to drive the state machine. It is exposed here so that we can cancel it,
    /// e.g., when the user taps on the screen and we show the action sheet, or when the app
    /// deactivates.
    var loopingTask: (Task<(), any Error>)?

    func receive(_ action: RootAction) async {
        switch action {
        case .deactivate:
            await stopEverything()
        case .initialLayout:
            let layoutIndex = services.persistence.layoutNumber()
            let layout = BottleLayout.layouts[layoutIndex]
            await presenter?.receive(.startOver(layout))
            await presenter?.receive(.proposeBottle)
        case .proposeBottle(let bottle, let count):
            state.currentBottle = bottle
            state.count = count
            await startSinging()
        case .tapped(let bottle):
            await tapped(bottle)
        }
    }

    /// The user has tapped the background. Display the action sheet and do what the user chooses.
    /// But if this happened while we were paused waiting for the user to pick a bottle,
    /// then instead, resume singing, with this bottle as our bottle (replacing the originally
    /// proposed bottle).
    func tapped(_ bottle: BottleLayer?) async {
        if stateMachine?.currentState is WaitingForTap, let bottle = bottle {
            // resume singing
            state.currentBottle = bottle
            let newState = stateMachine?.proceedToNextState()
            await driveStateMachine(state: newState)
            return
        }
        // stop everything you're doing...
        await stopEverything()
        // ... and show the action sheet
        let result = await coordinator?.showActionSheet(
            title: nil,
            titles: [
                "Resume",
                "Start Over",
                "Preferences"
            ],
            userInfos: [
                ["result": TapAction.resume],
                ["result": TapAction.startOver],
                ["result": TapAction.preferences]
            ]
        )
        // respond to the action sheet
        if let result = result as? MyAlertAction, let action = result.userInfo?["result"] as? TapAction {
            switch action {
            case .resume:
                // start this verse from the top
                await presenter?.receive(.updateLabel)
                await presenter?.receive(.proposeBottle)
            case .startOver:
                // start the whole song from the top
                await trampoline.startOver()
            case .preferences:
                coordinator?.showPreferences()
            }
        }
    }

    /// Called by .proposeBottle. We have a bottle and the number of bottles. Start the verse.
    func startSinging() async {
        stateMachine = services.stateMachineFactory.makeStateMachine(
            howManyBottles: state.count,
            interactive: services.persistence.interactive()
        )
        let firstState = stateMachine?.proceedToNextState()
        try? await unlessTesting {
            try? await Task.sleep(for: .seconds(0.5))
        }
        await driveStateMachine(state: firstState)
    }

    /// Called by `startSinging` and also by `tapped`. Cycle through the successive
    /// states of the state machine, singing as we go. When we reach a nil state, this means
    /// we have finished one verse of the song: we have sung about one bottle, and the states
    /// have _removed_ that bottle. So update the interface and ask for a new bottle to sing about.
    func driveStateMachine(state stateMachineState: (any StateType)?) async {
        let task = Task {
            var stateMachineState = stateMachineState
            while stateMachineState != nil {
                try await (stateMachineState as? SingerType)?.sing(bottleLayer: self.state.currentBottle)
                stateMachineState = stateMachine?.proceedToNextState()
                if stateMachineState is WaitingForTap {
                    throw Exit.exit // stop! it's up to the user to set us going again
                }
                try Task.checkCancellation()
            }
        }
        self.loopingTask = task // expose the task to make it cancellable from outside
        let result = await task.result
        if case .failure = result {
            return // task threw, bow out
        }
        // the verse has completed in good order; start the next verse (unless we're out of bottles)
        await presenter?.receive(.updateLabel)
        if self.state.count > 1 {
            Task { // break the chain! otherwise we'd build up a huge recursive call stack
                await presenter?.receive(.proposeBottle)
            }
        }
    }

    /// Stop driving the state machine, stop singing, stop animating a bottle.
    /// Basically bring the entire app to a halt.
    func stopEverything() async {
        loopingTask?.cancel()
        (stateMachine?.currentState as? SingerType)?.stop()
        await presenter?.receive(.cancelAnimations)
    }

    /// Actions of the action sheet.
    enum TapAction {
        case resume
        case startOver
        case preferences
    }

    /// Error enum, so we can cancel the looping task from within.
    enum Exit: Error {
        case exit
    }
}

/// The Preferences have been dismissed. Respond.
extension RootProcessor: PreferencesDelegate {
    func cancel() async {}

    func done() async {
        await trampoline.startOver()
    }
}

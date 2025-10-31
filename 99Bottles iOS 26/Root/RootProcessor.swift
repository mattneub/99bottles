import Foundation

/// Logic of the Root module.
final class RootProcessor: Processor {
    /// Reference to the coordinator, set by coordinator at module creation time.
    weak var coordinator: (any RootCoordinatorType)?

    /// Reference to the presenter, set by coordinator at module creation time.
    weak var presenter: (any ReceiverPresenter<RootEffect, RootState>)?

    /// State to be presented for display, but in fact we use it only as a scratchpad.
    var state = RootState()

    /// State machine that drives the progress of the app's behavior.
    var stateMachine: (any StateMachineType)?

    func receive(_ action: RootAction) async {
        switch action {
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
    /// then resume singing, with this bottle as our bottle (replacing the originally
    /// proposed bottle).
    func tapped(_ bottle: BottleLayer?) async {
        if stateMachine?.currentState is WaitingForTap, let bottle = bottle {
            state.currentBottle = bottle
            let newState = stateMachine?.proceedToNextState()
            try? await driveStateMachine(state: newState)
            return
        }
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
        if let result = result as? MyAlertAction, let action = result.userInfo?["result"] as? TapAction {
            switch action {
            case .resume: break
            case .startOver: break
            case .preferences:
                coordinator?.showPreferences()
            }
        }
    }

    /// Called by .proposeBottle. We have a bottle and a number of bottles. Start the verse.
    func startSinging() async {
        stateMachine = services.stateMachineFactory.makeStateMachine(
            bottleNumber: state.count,
            interactive: services.persistence.interactive()
        )
        let firstState = stateMachine?.proceedToNextState()
        try? await unlessTesting {
            try? await Task.sleep(for: .seconds(0.5))
        }
        try? await driveStateMachine(state: firstState)
    }

    /// Called by `startSinging` and also by `tapped`. Cycle through the successive
    /// states of the state machine, singing as we go. When we reach the last state, this means
    /// we have finished one verse of the song: we have sung about one bottle, and the states
    /// have _removed_ that bottle. So update the interface and ask for a new bottle to sing about.
    func driveStateMachine(state stateMachineState: (any StateType)?) async throws {
        var stateMachineState = stateMachineState
        while stateMachineState != nil {
            try await (stateMachineState as? SingerType)?.sing(bottleLayer: self.state.currentBottle)
            stateMachineState = stateMachine?.proceedToNextState()
            if stateMachineState is WaitingForTap {
                return // stop! it's up to the user to set us going again
            }
        }
        // ok, state machine state is nil, the verse is over! start the next verse
        await presenter?.receive(.updateLabel)
        if self.state.count > 1 {
            await presenter?.receive(.proposeBottle)
        }
    }

    /// Actions of the action sheet.
    enum TapAction {
        case resume
        case startOver
        case preferences
    }
}

/// The Preferences have been dismissed. Respond.
extension RootProcessor: PreferencesDelegate {
    func cancel() async {}

    func done() async {
        await receive(.initialLayout)
    }
}

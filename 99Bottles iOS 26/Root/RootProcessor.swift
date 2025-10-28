import Foundation

final class RootProcessor: Processor {
    weak var coordinator: (any RootCoordinatorType)?

    weak var presenter: (any ReceiverPresenter<RootEffect, RootState>)?

    var state = RootState()

    func receive(_ action: RootAction) async {
        switch action {
        case .initialLayout:
            await presenter?.receive(.startOver)
        case .tapped:
            await tapped()
        }
    }

    func tapped() async {
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

    enum TapAction {
        case resume
        case startOver
        case preferences
    }

}

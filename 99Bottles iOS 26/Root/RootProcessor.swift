import Foundation

final class RootProcessor: Processor {
    weak var coordinator: (any RootCoordinatorType)?

    weak var presenter: (any ReceiverPresenter<RootEffect, RootState>)?

    var state = RootState()

    func receive(_ action: RootAction) async {
        switch action {
        case .initialLayout:
            await presenter?.receive(.startOver)
        }
    }
}

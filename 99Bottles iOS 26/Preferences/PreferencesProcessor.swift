import Foundation

final class PreferencesProcessor: Processor {
    weak var coordinator: (any RootCoordinatorType)?

    weak var presenter: (any ReceiverPresenter<Void, PreferencesState>)?

    var state = PreferencesState()

    func receive(_ action: PreferencesAction) async {
        switch action {
        case .cancel: break
        case .done(let layout, let autoplay): break
        }
    }
}

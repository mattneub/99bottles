import Foundation

final class PreferencesProcessor: Processor {
    weak var coordinator: (any RootCoordinatorType)?

    weak var presenter: (any ReceiverPresenter<Void, PreferencesState>)?

    weak var delegate: (any PreferencesDelegate)?

    var state = PreferencesState()

    func receive(_ action: PreferencesAction) async {
        switch action {
        case .cancel:
            await coordinator?.dismiss()
            await delegate?.cancel()
        case .done(let layout, let autoplay):
            services.persistence.setLayoutNumber(layout)
            services.persistence.setInteractive(!autoplay)
            await coordinator?.dismiss()
            await delegate?.done()
        case .initialData:
            state.layoutNumber = services.persistence.layoutNumber()
            state.autoplay = !services.persistence.interactive()
            await presenter?.present(state)
        }
    }
}

protocol PreferencesDelegate: AnyObject {
    func cancel() async
    func done() async
}

import Foundation

final class PreferencesProcessor: Processor {
    weak var coordinator: (any RootCoordinatorType)?

    weak var presenter: (any ReceiverPresenter<Void, PreferencesState>)?

    var state = PreferencesState()

    func receive(_ action: PreferencesAction) async {
        switch action {
        case .cancel:
            await coordinator?.dismiss()
        case .done(let layout, let autoplay):
            services.persistence.setLayoutNumber(layout)
            services.persistence.setInteractive(!autoplay)
            await coordinator?.dismiss()
        case .initialData:
            state.layoutNumber = services.persistence.layoutNumber()
            state.autoplay = !services.persistence.interactive()
            await presenter?.present(state)
        }
    }
}

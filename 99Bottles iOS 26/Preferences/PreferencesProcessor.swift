import Foundation

/// Logic of the Preferences module.
final class PreferencesProcessor: Processor {
    /// Reference to the coordinator, set by coordinator at module creation time.
    weak var coordinator: (any RootCoordinatorType)?

    /// Reference to the presenter, set by coordinator at module creation time.
    weak var presenter: (any ReceiverPresenter<Void, PreferencesState>)?

    /// Reference to the delegate, set by coordinator at module creation time.
    weak var delegate: (any PreferencesDelegate)?

    /// State sent to the presenter for display to the user.
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

/// Delegate is told that the view controller was dismissed, and how.
protocol PreferencesDelegate: AnyObject {
    func cancel() async
    func done() async
}

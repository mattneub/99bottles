import UIKit

protocol RootCoordinatorType: AnyObject {
    func createInterface(window: UIWindow)
    func showPreferences()
    func showActionSheet(title: String?, titles: [String], userInfos: [[String: Any]]) async -> UIAlertAction?
    func dismiss() async
}

final class RootCoordinator: RootCoordinatorType {
    weak var rootViewController: UIViewController?

    var rootProcessor: (any Processor<RootAction, RootState, RootEffect>)?
    var preferencesProcessor: (any Processor<PreferencesAction, PreferencesState, Void>)?

    func createInterface(window: UIWindow) {
        let processor = RootProcessor()
        self.rootProcessor = processor
        let viewController = RootViewController()
        self.rootViewController = viewController
        processor.presenter = viewController
        processor.coordinator = self
        viewController.processor = processor
        window.rootViewController = viewController
        window.backgroundColor = .systemBackground
    }

    func showPreferences() {
        let processor = PreferencesProcessor()
        self.preferencesProcessor = processor
        let viewController = PreferencesViewController(nibName: "Preferences", bundle: nil)
        processor.presenter = viewController
        processor.coordinator = self
        viewController.processor = processor
        let navigationController = UINavigationController(rootViewController: viewController)
        rootViewController?.present(navigationController, animated: unlessTesting(true))
    }

    var actionSheetContinuation: CheckedContinuation<UIAlertAction?, Never>?

    func showActionSheet(title: String?, titles: [String], userInfos: [[String: Any]]) async -> UIAlertAction? {
        await withCheckedContinuation { continuation in
            self.actionSheetContinuation = continuation
            let alert = UIAlertController(title: title, message: nil, preferredStyle: .actionSheet)
            for (title, info) in zip(titles, userInfos) {
                let action = MyAlertAction(title: title, style: .default, handler: { action in
                    continuation.resume(returning: action)
                    self.actionSheetContinuation = nil
                })
                action.userInfo = info
                alert.addAction(action)
            }
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
                continuation.resume(returning: nil)
                self.actionSheetContinuation = nil
            }))
            rootViewController?.present(alert, animated: unlessTesting(true))
        }
    }

    func dismiss() async {
        guard rootViewController?.presentedViewController != nil else {
            return
        }
        await withCheckedContinuation { continuation in
            rootViewController?.dismiss(animated: unlessTesting(true)) {
                continuation.resume(returning: ())
            }
        }
    }

}

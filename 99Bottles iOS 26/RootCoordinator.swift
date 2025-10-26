import UIKit

protocol RootCoordinatorType: AnyObject {
    func createInterface(window: UIWindow)
}

final class RootCoordinator: RootCoordinatorType {
    weak var rootViewController: UIViewController?

    var rootProcessor: (any Processor<RootAction, RootState, RootEffect>)?

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

}

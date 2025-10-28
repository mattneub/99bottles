@testable import Bottles
import Testing
import UIKit

final class MockRootCoordinator: RootCoordinatorType {

    var methodsCalled = [String]()
    var window: UIWindow?
    var title: String?
    var titles = [String]()
    var userInfos = [[String: Any]]()
    var actionToReturn: UIAlertAction?

    func createInterface(window: UIWindow) {
        methodsCalled.append(#function)
        self.window = window
    }

    func showPreferences() {
        methodsCalled.append(#function)
    }

    func showActionSheet(
        title: String?,
        titles: [String],
        userInfos: [[String: Any]]
    ) async -> UIAlertAction? {
        methodsCalled.append(#function)
        self.title = title
        self.titles = titles
        self.userInfos = userInfos
        return actionToReturn
    }

    func dismiss() async {
        methodsCalled.append(#function)
    }
}


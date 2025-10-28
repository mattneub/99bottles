@testable import Bottles
import Testing
import UIKit
import WaitWhile

struct RootCoordinatorTests {
    let subject = RootCoordinator()

    @Test("createInterface: sets up root module")
    func createInterface() throws {
        let window = UIWindow()
        subject.createInterface(window: window)
        let processor = try #require(subject.rootProcessor as? RootProcessor)
        #expect(processor.coordinator === subject)
        let viewController = try #require(processor.presenter as? RootViewController)
        #expect(viewController.processor === processor)
        #expect(subject.rootViewController === viewController)
        #expect(window.rootViewController === viewController)
        #expect(window.backgroundColor == .systemBackground)
    }

    @Test("showPreferences: sets up preferences module, presents")
    func showPreferences() async throws {
        let rootViewController = UIViewController()
        makeWindow(viewController: rootViewController)
        subject.rootViewController = rootViewController
        subject.showPreferences()
        let processor = try #require(subject.preferencesProcessor as? PreferencesProcessor)
        #expect(processor.coordinator === subject)
        let viewController = try #require(processor.presenter as? PreferencesViewController)
        #expect(viewController.processor === processor)
        await #while(rootViewController.presentedViewController == nil)
        let navigationController = try #require(rootViewController.presentedViewController as? UINavigationController)
        #expect(navigationController.viewControllers.first === viewController)
    }

    @Test("showActionSheet: presents action sheet")
    func showActionSheet() async throws {
        let viewController = UIViewController()
        makeWindow(viewController: viewController)
        subject.rootViewController = viewController
        var result: UIAlertAction?
        Task {
            result = await subject.showActionSheet(
                title: "title",
                titles: ["hey", "ho"],
                userInfos: [["hi": 1], ["ha": 2]]
            )
        }
        await #while(viewController.presentedViewController == nil)
        await #while(viewController.presentedViewController == nil)
        let alert = try #require(viewController.presentedViewController as? UIAlertController)
        #expect(subject.actionSheetContinuation != nil)
        #expect(alert.title == "title")
        #expect(alert.actions[0].title == "hey")
        #expect(alert.actions[0].style == .default)
        #expect((alert.actions[0] as? MyAlertAction)?.userInfo as? [String: Int] == ["hi": 1])
        #expect(alert.actions[1].title == "ho")
        #expect(alert.actions[1].style == .default)
        #expect((alert.actions[1] as? MyAlertAction)?.userInfo as? [String: Int] == ["ha": 2])
        #expect(alert.actions[2].title == "Cancel")
        #expect(alert.actions[2].style == .cancel)
        alert.tapButton(atIndex: 1)
        await #while(result == nil)
        let myAction = try #require(result as? MyAlertAction)
        #expect(myAction.userInfo as? [String: Int] == ["ha": 2])
        #expect(subject.actionSheetContinuation == nil)
    }
}

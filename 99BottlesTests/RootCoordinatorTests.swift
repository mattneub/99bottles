@testable import Bottles
import Testing
import UIKit

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
}

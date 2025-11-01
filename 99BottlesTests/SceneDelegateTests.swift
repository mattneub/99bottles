@testable import Bottles
import Testing
import UIKit

struct SceneDelegateTests {
    @Test("bootstrap behaves correctly")
    func bootstrap() throws {
        let scene = try #require(UIApplication.shared.connectedScenes.first as? UIWindowScene)
        let subject = SceneDelegate()
        let mockRootCoordinator = MockRootCoordinator()
        subject.coordinator = mockRootCoordinator
        let session = MockAudioSessionWrapper()
        services.audioSessionWrapper = session
        subject.bootstrap(scene: scene)
        #expect(mockRootCoordinator.methodsCalled == ["createInterface(window:)"])
        #expect(mockRootCoordinator.window === subject.window)
        #expect(session.methodsCalled == ["configure()"])
    }

    @Test("sceneDidBecomeActive behaves correctly")
    func didBecomeActive() throws {
        let scene = try #require(UIApplication.shared.connectedScenes.first as? UIWindowScene)
        let subject = SceneDelegate()
        let session = MockAudioSessionWrapper()
        services.audioSessionWrapper = session
        subject.sceneDidBecomeActive(scene)
        #expect(session.methodsCalled == ["activate()"])
    }

}

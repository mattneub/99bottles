@testable import Bottles
import AVFoundation

final class MockAudioSessionWrapper: AudioSessionWrapperType {
    var methodsCalled = [String]()
    func configure() {
        methodsCalled.append(#function)
    }
    func activate() {
        methodsCalled.append(#function)
    }
}

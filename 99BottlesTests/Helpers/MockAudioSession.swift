@testable import Bottles
import AVFoundation

final class MockAudioSession: AudioSessionType {
    var category: AVAudioSession.Category?
    var mode: AVAudioSession.Mode?
    var categoryOptions: AVAudioSession.CategoryOptions?
    var activeOptions: AVAudioSession.SetActiveOptions?
    var active: Bool?
    var methodsCalled = [String]()
    func setCategory(
        _ category: AVAudioSession.Category,
        mode: AVAudioSession.Mode,
        options: AVAudioSession.CategoryOptions
    ) throws {
        methodsCalled.append(#function)
        self.category = category
        self.mode = mode
        self.categoryOptions = options
    }
    func setActive(
        _ active: Bool,
        options: AVAudioSession.SetActiveOptions
    ) throws {
        methodsCalled.append(#function)
        self.active = active
        self.activeOptions = options
    }

}

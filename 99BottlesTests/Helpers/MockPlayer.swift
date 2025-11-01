import AVFoundation
@testable import Bottles

final class MockPlayer: NSObject, PlayerType {
    var methodsCalled = [String]()
    var soundFile: URL

    init(soundFile: URL) throws {
        self.soundFile = soundFile
    }
    
    func playAsync() async {
        methodsCalled.append(#function)
    }

    func stop() {
        methodsCalled.append(#function)
    }

}

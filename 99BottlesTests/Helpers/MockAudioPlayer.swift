@testable import Bottles
import UIKit
import AVFoundation

final class MockAudioPlayer: NSObject, AudioPlayerType {
    var delegate: (any AVAudioPlayerDelegate)?
    var url: URL?
    var hint: String?
    var methodsCalled = [String]()

    init(contentsOf url: URL, fileTypeHint hint: String?) throws {
        self.url = url
        self.hint = hint
    }

    @discardableResult func prepareToPlay() -> Bool {
        methodsCalled.append(#function)
        return true
    }

    @discardableResult func play() -> Bool {
        methodsCalled.append(#function)
        return true
    }

}

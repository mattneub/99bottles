import Foundation
import AVFoundation

/// Protocol expressing the public face of AVAudioPlayer, so we can mock it for testing.
protocol AudioPlayerType: AnyObject {
    var delegate: (any AVAudioPlayerDelegate)? { get set }
    init(contentsOf: URL, fileTypeHint: String?) throws
    @discardableResult func prepareToPlay() -> Bool
    @discardableResult func play() -> Bool
}

extension AVAudioPlayer: AudioPlayerType {}

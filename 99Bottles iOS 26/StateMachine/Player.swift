import AVFoundation

/// Protocol expressing the public face of our Player type, so we can mock it for testing.
protocol PlayerType: NSObject, AVAudioPlayerDelegate {
    init(soundFile: URL) throws
    func playAsync() async
}

/// Object that plays a sound file in a way that you can wait for with async/await.
final class Player: NSObject, @MainActor PlayerType {
    let audioPlayer: AudioPlayerType

    var continuation: CheckedContinuation<Void, Never>?

    init(soundFile: URL) throws {
        self.audioPlayer = try services.audioPlayerType.init(
            contentsOf: soundFile,
            fileTypeHint: UTType.aiff.identifier
        )
        super.init()
        audioPlayer.prepareToPlay()
        audioPlayer.delegate = self
    }

    func playAsync() async {
        await withCheckedContinuation { continuation in
            self.continuation = continuation
            audioPlayer.play()
        }
    }
}

extension Player: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        continuation?.resume(returning: ())
        continuation = nil
    }
}

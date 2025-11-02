import AVFoundation

/// Protocol expressing the public face of our Player type, so we can mock it for testing.
protocol PlayerType: NSObject, AVAudioPlayerDelegate {
    init(soundFile: URL) throws
    func playAsync() async
    func stop()
}

/// Object that plays a sound file in a way that you can wait for with async/await.
final class Player: NSObject, @MainActor PlayerType {
    /// Ostensibly, an AVAudioPlayer.
    let audioPlayer: AudioPlayerType

    /// Exposed continuation so that playing is async/await.
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

    /// Play the sound, and return when done.
    func playAsync() async {
        await withCheckedContinuation { continuation in
            self.continuation = continuation
            audioPlayer.play()
        }
    }

    /// Interrupt the sound, if any.
    func stop() {
        audioPlayer.stop()
        continuation?.resume(returning: ())
        continuation = nil
    }
}

extension Player: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        continuation?.resume(returning: ())
        continuation = nil
    }
}

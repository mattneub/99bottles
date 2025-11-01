import AVFoundation

/// Protocol describing the public face of AudioSessionWrapper, so we can mock it for testing.
protocol AudioSessionWrapperType {
    func configure()
    func activate()
}

/// Protocol describing our interaction with AVAudioSession, so we can mock _it_ for testing.
protocol AudioSessionType {
    func setCategory(
        _ category: AVAudioSession.Category,
        mode: AVAudioSession.Mode,
        options: AVAudioSession.CategoryOptions
    ) throws
    func setActive(
        _ active: Bool,
        options: AVAudioSession.SetActiveOptions
    ) throws
}

extension AVAudioSession: AudioSessionType {}

/// Service that mediates with AVAudioSession.
final class AudioSessionWrapper: AudioSessionWrapperType {
    /// Function that returns the session, so that we are not hanging on to an instance.
    var audioSessionProvider: () -> any AudioSessionType = { AVAudioSession.sharedInstance() }

    func configure() {
        let playback = AVAudioSession.Category.playback
        try? audioSessionProvider().setCategory(playback, mode: .default, options: [])
    }

    func activate() {
        try? audioSessionProvider().setActive(true, options: [])
    }
}

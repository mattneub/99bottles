import Foundation

/// A Singer is a State plus a `sing` method (and a `stop` method).
protocol SingerType: StateType {
    func sing(bottleLayer: BottleLayer?) async throws
    func stop()
}

extension SingerType {
    func sing() async throws {
        try await sing(bottleLayer: nil)
    }
}

/// Stage two! This is the object that knows how to sing one phrase —
/// namely, the first phrase in its `verse`.
final class Singer: SingerType {
    let bottleNumber: Int
    let interactive: Bool
    var verse: [Phrase]
    var player: (any PlayerType)?
    var pauseAfterwards: Bool = false

    init(bottleNumber: Int, interactive: Bool, verse: [Phrase]) {
        self.bottleNumber = bottleNumber
        self.interactive = interactive
        self.verse = verse
    }

    func sing(bottleLayer: BottleLayer? = nil) async throws {
        guard verse.count > 0 else {
            return // shouldn't happen, but we would crash if it did
        }
        let phrase = verse.removeFirst()
        self.pauseAfterwards = phrase.pauseAfterwards
        guard let url = services.bundle.url(
            forResource: phrase.sound,
            withExtension: "aif",
            subdirectory: "Sounds"
        ) else {
            return // shouldn't happen
        }
        if let bottleLayer {
            phrase.action?(bottleLayer)
        }
        self.player = try services.playerType.init(soundFile: url)
        await player?.playAsync()
    }

    func stop() {
        player?.stop()
    }

    func nextState() -> (any StateType)? {
        guard verse.count > 0 else {
            return nil // the verse is over!
        }
        if pauseAfterwards {
            return WaitingForTap(bottleNumber: bottleNumber, interactive: interactive, verse: verse)
        }
        return Singer(bottleNumber: bottleNumber, interactive: interactive, verse: verse)
    }
}

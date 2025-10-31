import Foundation

/// A Singer is a State plus a `sing` method.
protocol SingerType: StateType {
    func sing(bottleLayer: BottleLayer?) async throws
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
        guard let url = services.bundle.url(
            forResource: phrase.sound,
            withExtension: "aif",
            subdirectory: "Sounds"
        ) else {
            return
        }
        self.player = try services.playerType.init(soundFile: url)
        if let bottleLayer {
            phrase.action?(bottleLayer)
        }
        await player?.playAsync()
    }

    func nextState() -> (any StateType)? {
        guard verse.count > 0 else {
            return nil
        }
        return Singer(bottleNumber: bottleNumber, interactive: interactive, verse: verse)
    }
}

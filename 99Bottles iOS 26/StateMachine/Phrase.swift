/// A single phrase of a song, possibly accompanied by an action upon a bottle.
struct Phrase: Equatable {
    /// Name of the sound.
    let sound: String

    /// What to do during this phrase, if anything.
    let action: ((BottleLayer) -> ())?

    /// Whether to pause afterwards.
    let pauseAfterwards: Bool

    init(sound: String, pauseAfterwards: Bool = false, action: ((BottleLayer) -> ())? = nil) {
        self.sound = sound
        self.action = action
        self.pauseAfterwards = pauseAfterwards
    }

    static func ==(lhs: Phrase, rhs: Phrase) -> Bool {
        lhs.sound == rhs.sound && lhs.pauseAfterwards == rhs.pauseAfterwards
    }
}


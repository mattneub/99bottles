/// State that signifies that we are paused and waiting for the user to pick a bottle.
/// This, tautologically, happens only if the app is in its interactive state.
final class WaitingForTap: StateType {
    let bottleNumber: Int
    let interactive: Bool
    var verse: [Phrase]

    init(bottleNumber: Int, interactive: Bool, verse: [Phrase]) {
        self.bottleNumber = bottleNumber
        self.interactive = interactive
        self.verse = verse
    }

    func nextState() -> (any StateType)? {
        return Singer(bottleNumber: bottleNumber, interactive: interactive, verse: verse)
    }
}

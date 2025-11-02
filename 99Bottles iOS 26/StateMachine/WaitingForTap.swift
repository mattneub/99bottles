/// State that signifies that we are paused and waiting for the user to pick a bottle.
/// This, tautologically, happens only if the app is in its interactive state.
final class WaitingForTap: StateType {
    let howManyBottles: Int
    let interactive: Bool
    var verse: [Phrase]

    init(howManyBottles: Int, interactive: Bool, verse: [Phrase]) {
        self.howManyBottles = howManyBottles
        self.interactive = interactive
        self.verse = verse
    }

    func nextState() -> (any StateType)? {
        return Singer(howManyBottles: howManyBottles, interactive: interactive, verse: verse)
    }
}

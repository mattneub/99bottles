/// Stage one! This is the object that, given a number, knows how assemble all the phrases
/// for singing and dancing about that number into a verse.
final class Preparer: StateType {
    let howManyBottles: Int
    let interactive: Bool
    var verse = [Phrase]()

    init(howManyBottles: Int, interactive: Bool = false) {
        self.howManyBottles = howManyBottles
        self.interactive = interactive
        buildVerse(interactive: interactive)
    }

    /// This is really the heart of the entire app! Prepare a verse about our bottle number.
    func buildVerse(interactive: Bool) {
        // special rules for last verse
        if howManyBottles == 1 {
            // one bottle of beer on the wall, one bottle of beer
            verse += [Phrase(sound: "onefinal2")]
            // take it down, pass it around
            verse += [Phrase(sound: "onefinal3") { $0.jiggle() }]
            // no more bottles of beer on the wall
            verse += [Phrase(sound: "onefinal4") { $0.flyAway() }]
        } else {
            // e.g. ninety-nine
            verse += Numeral.numeral(howManyBottles).map { Phrase(sound: $0 + "1") }
            // bottles of beer on the wall
            verse += [Phrase(sound: "bottles1")]
            // e.g. ninety-nine, higher
            verse += Numeral.numeral(howManyBottles).map { Phrase(sound: $0 + "2") }
            // bottles of beer: and are we to pause after this?
            verse += [Phrase(sound: "bottles2", pauseAfterwards: interactive)]
            // take one down, pass it around
            verse += [Phrase(sound: "take") { $0.jiggle() }]

            // e.g. ninety-eight, lower
            verse += Numeral.numeral(howManyBottles-1).map { Phrase(sound: $0 + "3") }
            // bottles of beer on the wall
            verse += [Phrase(sound: "bottles3") { $0.flyAway() }]
            // special rules in case we are doing "2"
            if howManyBottles == 2 {
                verse.removeLast()
                verse.removeLast()
                // one bottle of beer on the wall
                verse += [Phrase(sound: "onefinal1") { $0.flyAway() }]
            }
        }
    }

    func nextState() -> (any StateType)? {
        return Singer(howManyBottles: howManyBottles, interactive: interactive, verse: verse)
    }
}

/// Transient messages sent from processor to presenter.
enum RootEffect: Equatable {

    /// Stop animating any bottles.
    case cancelAnimations

    /// I need you to pick a bottle and tell me how many bottles there are.
    case proposeBottle

    /// Here's the new layout; remove all existing bottles and make new bottles using this number
    /// of rows and columns.
    case startOver(BottleLayout)

    /// Ensure that your number display matches how many bottles there are.
    case updateLabel
}

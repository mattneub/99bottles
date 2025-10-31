/// Messages from the presenter to the processor.
enum RootAction: Equatable {

    /// Ready for initial layout.
    case initialLayout

    /// Please use this bottle to take down and pass around. Count is how many bottles exist.
    /// This is how the processor knows how to configure the state machine.
    case proposeBottle(BottleLayer, count: Int)

    /// The user tapped the background.
    case tapped
}

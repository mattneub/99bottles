/// Protocol that describes our trampoline, so we can mock it for testing.
protocol RootTrampolineType<ActionType> {
    associatedtype ActionType
    init(processor: (any Receiver<ActionType>)?)
    func startOver() async
}

/// Object that intervenes when the RootProcessor sends an action to itself, to make testing
/// simpler.
struct RootTrampoline: RootTrampolineType {

    /// Reference to the processor. Set by the processor.
    weak var processor: (any Receiver<RootAction>)?

    init(processor: (any Receiver<RootAction>)?) {
        self.processor = processor
    }

    func startOver() async {
        await processor?.receive(.initialLayout)
    }
}

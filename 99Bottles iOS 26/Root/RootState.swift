/// State to be handed by the processor to the presenter for presentation to the user; but in fact
/// we never use it for that, it's just a place where we keep some scratch values so we know what
/// the current state of things _is_.
struct RootState {
    var count: Int = 99
    var currentBottle: BottleLayer?
}

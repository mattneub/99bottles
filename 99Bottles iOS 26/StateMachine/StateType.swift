/// A state is merely a class that knows how to generate the next state.
/// (This simplicity is possible because our states go in a fixed cycle,
/// where each state object can know, based on its own contents, what the next
/// state is.)
protocol StateType: AnyObject {
    func nextState() -> (any StateType)?
}

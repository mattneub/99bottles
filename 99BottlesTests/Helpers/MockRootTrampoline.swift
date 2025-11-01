@testable import Bottles
import Testing

final class MockRootTrampoline: RootTrampolineType {
    var methodsCalled = [String]()

    init(processor: (any Receiver<RootAction>)?) {}

    func startOver() async {
        methodsCalled.append(#function)
    }
}

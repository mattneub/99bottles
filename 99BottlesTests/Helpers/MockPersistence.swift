@testable import Bottles

final class MockPersistence: PersistenceType {
    var methodsCalled = [String]()
    var layout: Int?
    var layoutToReturn = 0
    var isInteractive: Bool?
    var interactiveToReturn = false

    func setLayoutNumber(_ layout: Int) {
        methodsCalled.append(#function)
        self.layout = layout
    }

    func layoutNumber() -> Int {
        methodsCalled.append(#function)
        return layoutToReturn
    }

    func setInteractive(_ interactive: Bool) {
        methodsCalled.append(#function)
        self.isInteractive = interactive
    }

    func interactive() -> Bool {
        methodsCalled.append(#function)
        return interactiveToReturn
    }

}

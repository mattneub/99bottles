import Foundation
@testable import Bottles

final class Manny: StateType {
    var methodsCalled = [String]()
    func nextState() -> (any StateType)? {
        methodsCalled.append(#function)
        return Moe()
    }
}

final class Moe: @MainActor SingerType {
    var methodsCalled = [String]()
    var bottleLayer: BottleLayer?
    func nextState() -> (any StateType)? {
        methodsCalled.append(#function)
        return Jack()
    }
    func sing(bottleLayer: BottleLayer?) async throws {
        methodsCalled.append(#function)
        self.bottleLayer = bottleLayer
    }
    func stop() {
        methodsCalled.append(#function)
    }
}

final class Jack: StateType {
    var methodsCalled = [String]()
    func nextState() -> (any StateType)? {
        methodsCalled.append(#function)
        return nil
    }
}

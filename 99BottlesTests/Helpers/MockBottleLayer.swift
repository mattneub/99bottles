@testable import Bottles
import UIKit

final class MockBottleLayer: BottleLayer {
    var methodsCalled = [String]()

    override func jiggle() {
        methodsCalled.append(#function)
    }

    override func flyAway() {
        methodsCalled.append(#function)
    }

    override func removeAllAnimations() {
        methodsCalled.append(#function)
    }
}

@testable import Bottles
import Testing
import UIKit
import SnapshotTesting
import WaitWhile

struct BottleLayerTests {
    @Test("Bottle 1 looks correct")
    func bottle1() {
        let layer = BottleLayer(bottleNumber: 1, scale: 2, screenBounds: .zero)
        #expect(layer.bottleNumber == 1)
        #expect(layer.contentsScale == 2)
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 150))
        layer.frame = view.bounds
        let viewController = UIViewController()
        makeWindow(viewController: viewController)
        viewController.view.addSubview(view)
        view.layer.addSublayer(layer)
        layer.setNeedsDisplay()
        layer.displayIfNeeded()
        assertSnapshot(of: view, as: .image)
    }

    @Test("Bottle 2 looks correct")
    func bottle2() {
        let layer = BottleLayer(bottleNumber: 2, scale: 2, screenBounds: .zero)
        #expect(layer.bottleNumber == 2)
        #expect(layer.contentsScale == 2)
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 150))
        layer.frame = view.bounds
        let viewController = UIViewController()
        makeWindow(viewController: viewController)
        viewController.view.addSubview(view)
        view.layer.addSublayer(layer)
        layer.setNeedsDisplay()
        layer.displayIfNeeded()
        assertSnapshot(of: view, as: .image)
    }

    @Test("Bottle 3 looks correct")
    func bottle3() {
        let layer = BottleLayer(bottleNumber: 3, scale: 2, screenBounds: .zero)
        #expect(layer.bottleNumber == 3)
        #expect(layer.contentsScale == 2)
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 150))
        layer.frame = view.bounds
        let viewController = UIViewController()
        makeWindow(viewController: viewController)
        viewController.view.addSubview(view)
        view.layer.addSublayer(layer)
        layer.setNeedsDisplay()
        layer.displayIfNeeded()
        assertSnapshot(of: view, as: .image)
    }

    @Test("Bottle 4 looks correct")
    func bottle4() {
        let layer = BottleLayer(bottleNumber: 4, scale: 2, screenBounds: .zero)
        #expect(layer.bottleNumber == 4)
        #expect(layer.contentsScale == 2)
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 150))
        layer.frame = view.bounds
        let viewController = UIViewController()
        makeWindow(viewController: viewController)
        viewController.view.addSubview(view)
        view.layer.addSublayer(layer)
        layer.setNeedsDisplay()
        layer.displayIfNeeded()
        assertSnapshot(of: view, as: .image)
    }

    @Test("Bottle 5 looks correct")
    func bottle5() {
        let layer = BottleLayer(bottleNumber: 5, scale: 2, screenBounds: .zero)
        #expect(layer.bottleNumber == 5)
        #expect(layer.contentsScale == 2)
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 150))
        layer.frame = view.bounds
        let viewController = UIViewController()
        makeWindow(viewController: viewController)
        viewController.view.addSubview(view)
        view.layer.addSublayer(layer)
        layer.setNeedsDisplay()
        layer.displayIfNeeded()
        assertSnapshot(of: view, as: .image)
    }

    @Test("init(layer:) makes a correct copy")
    func initLayer() {
        let layer = BottleLayer(bottleNumber: 5, scale: 2, screenBounds: .zero)
        layer.flown = true
        let layer2 = BottleLayer(layer: layer)
        #expect(layer2.bottleNumber == 5)
        #expect(layer2.contentsScale == 2)
        #expect(layer2.screenBounds == .zero)
        #expect(layer2.flown == true)
    }

    @Test("jiggle: adds an animation")
    func jiggle() throws {
        let layer = BottleLayer(bottleNumber: 5, scale: 2, screenBounds: .zero)
        layer.jiggle()
        let animation = try #require(layer.animation(forKey: "jiggle") as? CAAnimationGroup)
        let animations = try #require(animation.animations as? [CABasicAnimation])
        #expect(animations.count == 2)
        #expect(animations[0].keyPath == "transform")
        #expect(animations[1].keyPath == "transform")
    }

    @Test("flyAway: adds an animation, eventually removes layer from superlayer")
    func flyAway() async throws {
        let layer = BottleLayer(bottleNumber: 5, scale: 2, screenBounds: CGRect(x: 10, y: 10, width: 10, height: 10))
        layer.frame = CGRect(x: 10, y: 10, width: 10, height: 10)
        let superlayer = CALayer()
        superlayer.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        superlayer.addSublayer(layer)
        layer.flyAway()
        #expect(layer.superlayer != nil)
        let animation = try #require(layer.animation(forKey: "flyAway") as? CABasicAnimation)
        #expect(animation.value(forKey: "flyAway") != nil)
        await #while(layer.superlayer == superlayer)
        #expect(layer.superlayer == nil)
    }
}

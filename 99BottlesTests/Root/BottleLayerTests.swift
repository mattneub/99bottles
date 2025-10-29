@testable import Bottles
import Testing
import UIKit
import SnapshotTesting

struct BottleLayerTests {
    @Test("Bottle 1 looks correct")
    func bottle1() {
        let layer = BottleLayer(bottleNumber: 1, scale: 2)
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
        let layer = BottleLayer(bottleNumber: 2, scale: 2)
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
        let layer = BottleLayer(bottleNumber: 3, scale: 2)
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
        let layer = BottleLayer(bottleNumber: 4, scale: 2)
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
        let layer = BottleLayer(bottleNumber: 5, scale: 2)
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
        let layer = BottleLayer(bottleNumber: 5, scale: 2)
        let layer2 = BottleLayer(layer: layer)
        #expect(layer2.bottleNumber == 5)
        #expect(layer2.contentsScale == 2)
    }
}

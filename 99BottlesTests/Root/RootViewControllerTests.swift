@testable import Bottles
import Testing
import UIKit

struct RootViewControllerTests {
    let subject = RootViewController()
    let processor = MockProcessor<RootAction, RootState, RootEffect>()

    init() {
        subject.processor = processor
        services.viewType = MockUIView.self
        MockUIView.reset()
    }

    @Test("bottles: returns wall view bottle layers")
    func bottles() {
        let bottle1 = BottleLayer(bottleNumber: 1, scale: 2, screenBounds: .zero)
        let bottle2 = BottleLayer(bottleNumber: 12, scale: 2, screenBounds: .zero)
        let wallView = subject.wallView
        wallView.layer.addSublayer(bottle1)
        wallView.layer.addSublayer(bottle2)
        wallView.layer.addSublayer(CALayer())
        let result = subject.bottles
        #expect(result == [bottle1, bottle2])
    }

    @Test("imageView is correctly constructed")
    func imageView() {
        let imageView = subject.imageView
        #expect(imageView.translatesAutoresizingMaskIntoConstraints == false)
        #expect(imageView.image == UIImage(named: "marbleTrimmed.jpg")!)
        #expect(imageView.contentMode == .scaleToFill)
    }

    @Test("wallView is correctly constructed")
    func wallView() {
        let wallView = subject.wallView
        #expect(wallView.translatesAutoresizingMaskIntoConstraints == false)
    }

    @Test("numberDisplay is correctly constructed")
    func numberDisplay() {
        let numberDisplay = subject.numberDisplay
        #expect(numberDisplay.translatesAutoresizingMaskIntoConstraints == false)
        #expect(numberDisplay.text == "")
        #expect(numberDisplay.font == UIFont(name: "Helvetica", size: 144)!)
        #expect(numberDisplay.textColor == UIColor(red: 0.757, green: 0.396, blue: 0.673, alpha: 1))
        #expect(numberDisplay.shadowOffset == CGSize(width: 5, height: 4))
        #expect(numberDisplay.shadowColor == UIColor(red: 0.434, green: 0.335, blue: 0.330, alpha: 0.41))
    }

    @Test("viewDidLoad: lays out subviews correctly, adds tap gesture recognizer")
    func viewDidLoad() throws {
        makeWindow(viewController: subject)
        subject.loadViewIfNeeded()
        subject.view.layoutIfNeeded()
        print(subject.view.bounds)
        print(subject.wallView.frame)
        #expect(subject.imageView.superview === subject.view)
        #expect(subject.imageView.frame == subject.view.bounds)
        #expect(subject.wallView.superview === subject.view)
        let statusHeight = subject.view.safeAreaInsets.top
        #expect(subject.wallView.frame == subject.view.bounds.inset(by: UIEdgeInsets(top: statusHeight, left: 0, bottom: 0, right: 0)))
        #expect(subject.numberDisplay.superview === subject.wallView)
        #expect(subject.numberDisplay.center == CGPoint(x: subject.wallView.bounds.midX, y: subject.wallView.bounds.midY))
        let tapper = try #require(subject.view.gestureRecognizers?.first as? MyTapGestureRecognizer)
        #expect(tapper.target === subject)
        #expect(tapper.action == #selector(subject.tapped))
    }

    @Test("viewDidLoad: sets up notification observer")
    func viewDidLoadNotification() throws {
        subject.loadViewIfNeeded()
        let scene = try #require(UIApplication.shared.connectedScenes.first as? UIWindowScene)
        NotificationCenter.default.post(UIScene.WillDeactivateMessage(scene: scene), subject: scene)
        #expect(processor.thingsReceived == [.deactivate])
    }

    @Test("viewDidLayoutSubviews: sends initialLayout, first time only")
    func didLayout() {
        subject.viewDidLayoutSubviews()
        #expect(processor.thingsReceived == [.initialLayout])
        subject.viewDidLayoutSubviews()
        #expect(processor.thingsReceived == [.initialLayout])
    }

    @Test("receive cancelAnimations: sends removeAllAnimations to all bottles")
    func cancelAnimations() async {
        let bottle1 = MockBottleLayer(bottleNumber: 1, scale: 2, screenBounds: .zero)
        let bottle2 = MockBottleLayer(bottleNumber: 12, scale: 2, screenBounds: .zero)
        let wallView = subject.wallView
        wallView.layer.addSublayer(bottle1)
        wallView.layer.addSublayer(bottle2)
        await subject.receive(.cancelAnimations)
        #expect(bottle1.methodsCalled == ["removeAllAnimations()"])
        #expect(bottle2.methodsCalled == ["removeAllAnimations()"])
    }

    @Test("receive proposeBottle: picks a bottle layer at random, returns it with bottle count")
    func proposeBottle() async {
        let bottle1 = BottleLayer(bottleNumber: 1, scale: 2, screenBounds: .zero)
        let bottle2 = BottleLayer(bottleNumber: 12, scale: 2, screenBounds: .zero)
        let wallView = subject.wallView
        wallView.layer.addSublayer(bottle1)
        wallView.layer.addSublayer(bottle2)
        await subject.receive(.proposeBottle)
        let possibles: [[RootAction]] = [
            [.proposeBottle(bottle1, count: 2)],
            [.proposeBottle(bottle2, count: 2)],
        ]
        #expect(possibles.contains(processor.thingsReceived))
    }

    @Test("receive proposeBottle: if no bottles, does nothing")
    func proposeBottleNoBottles() async {
        await subject.receive(.proposeBottle)
        #expect(processor.thingsReceived.isEmpty)
    }

    @Test("receive startOver: removes all bottle layers, creates new bottle layout as specified")
    func startOver() async throws {
        makeWindow(viewController: subject)
        subject.loadViewIfNeeded()
        subject.view.layoutIfNeeded()
        subject.wallView.layer.addSublayer(BottleLayer(bottleNumber: 1, scale: 2, screenBounds: .zero))
        subject.wallView.layer.addSublayer(BottleLayer(bottleNumber: 1, scale: 2, screenBounds: .zero))
        await subject.receive(.startOver(BottleLayout.layouts[4]))
        let bottles = try #require(subject.wallView.layer.sublayers?.compactMap { $0 as? BottleLayer })
        #expect(bottles.count == BottleLayout.layouts[4].count)
        #expect(bottles[0].frame.origin == CGPoint(x: 2, y: 2))
        #expect(bottles[0].frame.integral.size == CGSize(width: 45, height: 65)) // close enough
        #expect(subject.numberDisplay.text == String(bottles.count))
        // I can prove there was an animation, but I can't prove what it was
        #expect(MockUIView.methodsCalled.first == "animateAsync(withDuration:delay:options:animations:)")
        #expect(MockUIView.duration == 0.25)
    }

    @Test("receive updateLabel: uses bottle count to update numberDisplay label with animation")
    func updateLabel() async {
        subject.loadViewIfNeeded()
        let bottle1 = BottleLayer(bottleNumber: 1, scale: 2, screenBounds: .zero)
        let bottle2 = BottleLayer(bottleNumber: 12, scale: 2, screenBounds: .zero)
        let wallView = subject.wallView
        wallView.layer.addSublayer(bottle1)
        wallView.layer.addSublayer(bottle2)
        await subject.receive(.updateLabel)
        #expect(subject.numberDisplay.text == "2")
        #expect(MockUIView.methodsCalled.first == "transitionAsync(with:duration:options:animations:)")
        #expect(MockUIView.view === subject.numberDisplay)
        #expect(MockUIView.duration == 0.4)
        #expect(MockUIView.options == .transitionFlipFromTop)
    }

    @Test("receive updateLabel: if bottle count matches numberDisplay label, does nothing")
    func updateLabelNoChange() async {
        subject.loadViewIfNeeded()
        let bottle1 = BottleLayer(bottleNumber: 1, scale: 2, screenBounds: .zero)
        let bottle2 = BottleLayer(bottleNumber: 12, scale: 2, screenBounds: .zero)
        let wallView = subject.wallView
        wallView.layer.addSublayer(bottle1)
        wallView.layer.addSublayer(bottle2)
        subject.numberDisplay.text = "2"
        await subject.receive(.updateLabel)
        #expect(subject.numberDisplay.text == "2")
        #expect(MockUIView.methodsCalled.isEmpty)
    }

    @Test("tapped: sends tapped")
    func tapped() {
        let gestureRecognizer = UITapGestureRecognizer()
        subject.tapped(gestureRecognizer)
        #expect(processor.thingsReceived == [.tapped(nil)])
    }

    @Test("tapped: if location is in a bottle layer, sends tapped with bottle layer")
    func tappedBottle() async {
        makeWindow(viewController: subject)
        subject.loadViewIfNeeded()
        subject.view.layoutIfNeeded()
        subject.wallView.layer.addSublayer(BottleLayer(bottleNumber: 1, scale: 2, screenBounds: .zero))
        subject.wallView.layer.addSublayer(BottleLayer(bottleNumber: 1, scale: 2, screenBounds: .zero))
        await subject.receive(.startOver(BottleLayout.layouts[BottleLayout.layouts.count - 1])) // one big bottle
        let bottle = subject.bottles[0]
        processor.thingsReceived = []
        // that was prep, here comes the test
        subject.tapped(MyGestureRecognizer()) // taps in middle of screen, where our one big bottle is
        #expect(processor.thingsReceived == [.tapped(bottle)])
    }
}

fileprivate final class MyGestureRecognizer: UITapGestureRecognizer {
    override func location(in view: UIView?) -> CGPoint {
        if let view {
            return CGPoint(x: view.bounds.midX, y: view.bounds.midY) // tee-hee
        }
        return .zero
    }
}

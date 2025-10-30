@testable import Bottles
import Testing
import UIKit
import WaitWhile

struct RootViewControllerTests {
    let subject = RootViewController()
    let processor = MockProcessor<RootAction, RootState, RootEffect>()

    init() {
        subject.processor = processor
        services.viewType = MockUIView.self
        MockUIView.reset()
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
        #expect(numberDisplay.text == "99")
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
        #expect(subject.imageView.superview === subject.view)
        #expect(subject.imageView.frame == subject.view.bounds)
        #expect(subject.wallView.superview === subject.view)
        #expect(subject.wallView.frame == subject.view.bounds.inset(by: UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)))
        #expect(subject.numberDisplay.superview === subject.wallView)
        #expect(subject.numberDisplay.center == CGPoint(x: subject.wallView.bounds.midX + 0.25, y: subject.wallView.bounds.midY))
        let tapper = try #require(subject.view.gestureRecognizers?.first as? MyTapGestureRecognizer)
        #expect(tapper.target === subject)
        #expect(tapper.action == #selector(subject.tapped))
    }

    @Test("viewDidLayoutSubviews: sends initialLayout, first time only")
    func didLayout() async {
        subject.viewDidLayoutSubviews()
        await #while(processor.thingsReceived.isEmpty)
        #expect(processor.thingsReceived == [.initialLayout])
        subject.viewDidLayoutSubviews()
        try? await Task.sleep(for: .seconds(0.1))
        #expect(processor.thingsReceived == [.initialLayout])
    }

    @Test("receive startOver: removes all bottle layers, creates new bottle layout as specified")
    func startOver() async throws {
        makeWindow(viewController: subject)
        subject.loadViewIfNeeded()
        subject.view.layoutIfNeeded()
        subject.wallView.layer.addSublayer(BottleLayer(bottleNumber: 1, scale: 2))
        subject.wallView.layer.addSublayer(BottleLayer(bottleNumber: 1, scale: 2))
        await subject.receive(.startOver(BottleLayout.layouts[4]))
        let bottles = try #require(subject.wallView.layer.sublayers?.compactMap { $0 as? BottleLayer })
        #expect(bottles.count == BottleLayout.layouts[4].count)
        #expect(bottles[0].frame.origin == CGPoint(x: 2, y: 2))
        #expect(bottles[0].frame.integral.size == CGSize(width: 45, height: 63)) // close enough
        #expect(subject.numberDisplay.text == String(bottles.count))
        // I can prove there was an animation, but I can't prove what it was
        #expect(MockUIView.methodsCalled.first == "animateAsync(withDuration:delay:options:animations:)")
        #expect(MockUIView.duration == 0.25)
    }

    @Test("tapped: sends tapped")
    func tapped() async {
        subject.tapped()
        await #while(processor.thingsReceived.isEmpty)
        #expect(processor.thingsReceived == [.tapped])
    }
}

import UIKit

/// View controller for the main screen.
final class RootViewController: UIViewController, ReceiverPresenter {
    /// Reference to the processor, set by coordinator at module creation time.
    weak var processor: (any Receiver<RootAction>)?

    override var prefersStatusBarHidden: Bool { true }

    /// Observer so that the processor can respond to scene deactivation.
    lazy var observer = NotificationCenter.default.addObserver(
        for: UIScene.WillDeactivateMessage.self
    ) { [weak self] _ in
        Task {
            await self?.processor?.receive(.deactivate)
        }
    }

    /// Background of the screen.
    lazy var imageView = UIImageView().applying {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.image = UIImage(named: "marbleTrimmed.jpg")
        $0.contentMode = .scaleToFill
    }

    /// Area in which bottles can appear.
    lazy var wallView = UIView().applying {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }

    /// Label that tells how many bottles there are currently.
    lazy var numberDisplay = UILabel().applying {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.text = ""
        $0.font = UIFont(name: "Helvetica", size: 144) ?? UIFont.systemFont(ofSize: 144)
        $0.textColor = UIColor(red: 0.757, green: 0.396, blue: 0.673, alpha: 1)
        $0.shadowOffset = CGSize(width: 5, height: 4)
        $0.shadowColor = UIColor(red: 0.434, green: 0.335, blue: 0.330, alpha: 0.41)
    }

    /// Computed property supplying all currently existing layers.
    var bottles: [BottleLayer] {
        wallView.layer.sublayers?.compactMap { $0 as? BottleLayer } ?? []
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])

        view.addSubview(wallView)
        NSLayoutConstraint.activate([
            wallView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            wallView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            wallView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            wallView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])

        wallView.addSubview(numberDisplay)
        NSLayoutConstraint.activate([
            numberDisplay.centerXAnchor.constraint(equalTo: wallView.centerXAnchor),
            numberDisplay.centerYAnchor.constraint(equalTo: wallView.centerYAnchor),
        ])

        let tapper = MyTapGestureRecognizer(target: self, action: #selector(tapped))
        view.addGestureRecognizer(tapper)

        let _ = observer // lazy instantiation
    }

    private var didInitialSetup = false
    override func viewDidLayoutSubviews() {
        if !self.didInitialSetup {
            self.didInitialSetup = true
            Task {
                await processor?.receive(.initialLayout)
            }
        }
    }

    func present(_ state: RootState) async {}

    func receive(_ effect: RootEffect) async {
        switch effect {
        case .cancelAnimations:
            self.bottles.forEach {
                $0.removeAllAnimations()
            }
        case .proposeBottle:
            let bottles = self.bottles
            guard bottles.count > 0 else {
                return
            }
            let layerNumber = Int.random(in: 0..<bottles.count)
            await processor?.receive(.proposeBottle(bottles[layerNumber], count: bottles.count))
        case .startOver(let layout):
            // wrap bottle creation in snapshot so bottles fade in rather than appearing abruptly
            var snapshotView: UIView?
            if view.window != nil {
                if let snapshot = view.snapshotView(afterScreenUpdates: true) {
                    snapshotView = snapshot
                    snapshot.frame = self.view.bounds
                    snapshot.layer.zPosition = 1000
                    self.view.addSubview(snapshot)
                }
            }
            await startOver(layout)
            if let snapshotView {
                await services.viewType.animateAsync(withDuration: 0.25, delay: 0, options: []) {
                    snapshotView.alpha = 0
                }
                snapshotView.removeFromSuperview()
            }
        case .updateLabel:
            let count = String(bottles.count)
            if numberDisplay.text != count {
                await services.viewType.transitionAsync(
                    with: numberDisplay,
                    duration: 0.4,
                    options: .transitionFlipFromTop,
                    animations: { [self] in
                        numberDisplay.text = count
                    }
                )
            }
        }
    }

    /// Workhorse subroutine of receiving `.startOver`. Make bottles in the arrangement
    /// described by the layout object.
    func startOver(_ bottleLayout: BottleLayout) async {
        guard let scale: CGFloat = view.window?.windowScene?.screen.scale else {
            return
        }
        guard let screenBounds: CGRect = view.window?.windowScene?.screen.bounds else {
            return
        }
        numberDisplay.text = String(bottleLayout.count)
        // clear existing bottles but leave the label
        wallView.layer.sublayers = [self.numberDisplay.layer]
        // make new bottles
        let frameRect = wallView.bounds
        let (rows, cols) = (bottleLayout.rows, bottleLayout.cols)
        let frows = CGFloat(rows), fcols = CGFloat(cols)
        let separator: CGFloat = 2.0
        let size = CGSize(
            width: (frameRect.size.width - (separator * (fcols + 1))) / fcols,
            height: (frameRect.size.height - (separator * (frows + 1))) / frows
        )
        let intercellSpacing = CGSize(width: separator, height: separator)
        for row in 0..<rows {
            for col in 0..<cols {
                let cellframe = CGRect(
                    x: intercellSpacing.width + (size.width + intercellSpacing.width) * CGFloat(col),
                    y: intercellSpacing.height + (size.height + intercellSpacing.height) * CGFloat(row),
                    width: size.width,
                    height: size.height
                )
                let layer = BottleLayer(
                    bottleNumber: Int.random(in: 1...5),
                    scale: scale,
                    screenBounds: screenBounds
                )
                layer.frame = cellframe
                wallView.layer.addSublayer(layer)
                layer.setNeedsDisplay()
                layer.displayIfNeeded()
            }
        }
    }

    /// The user has tapped the background.
    @objc func tapped(_ gestureRecognizer: UIGestureRecognizer) {
        // User might or might not have tapped on a bottle, and we might or might not care
        // about this. So just in case, report the bottle and let the processor decide.
        let location = gestureRecognizer.location(in: view) // wallView's superview -> superLayer
        let bottleLayer = wallView.layer.hitTest(location) as? BottleLayer
        Task {
            await processor?.receive(.tapped(bottleLayer))
        }
    }
}

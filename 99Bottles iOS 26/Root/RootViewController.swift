import UIKit

final class RootViewController: UIViewController, ReceiverPresenter {
    weak var processor: (any Receiver<RootAction>)?

    lazy var imageView = UIImageView().applying {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.image = UIImage(named: "marbleTrimmed.jpg")
        $0.contentMode = .scaleToFill
    }

    lazy var wallView = UIView().applying {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }

    lazy var numberDisplay = UILabel().applying {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.text = "99"
        $0.font = UIFont(name: "Helvetica", size: 144) ?? UIFont.systemFont(ofSize: 144)
        $0.textColor = UIColor(red: 0.757, green: 0.396, blue: 0.673, alpha: 1)
        $0.shadowOffset = CGSize(width: 5, height: 4)
        $0.shadowColor = UIColor(red: 0.434, green: 0.335, blue: 0.330, alpha: 0.41)
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
        case .startOver(let layout):
            var snapshotView: UIView? // wrap bottle creation in snapshot so it seems to fade in
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
                await services.view.animateAsync(withDuration: 0.25, delay: 0, options: []) {
                    snapshotView.alpha = 0
                }
                snapshotView.removeFromSuperview()
            }
        }
    }

    func startOver(_ bottleLayout: BottleLayout) async {
        let scale: CGFloat = view.window?.windowScene?.screen.scale ?? 2
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
                let layer = BottleLayer(bottleNumber: Int.random(in: 1...5), scale: scale)
                layer.frame = cellframe
                wallView.layer.addSublayer(layer)
                layer.setNeedsDisplay()
                layer.displayIfNeeded()
            }
        }
    }

    @objc func tapped() {
        Task {
            await processor?.receive(.tapped)
        }
    }
}

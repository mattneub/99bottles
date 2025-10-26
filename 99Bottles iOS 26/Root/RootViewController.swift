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
    }

    func present(_ state: RootState) async {}

    func receive(_ effect: RootEffect) async {}
}

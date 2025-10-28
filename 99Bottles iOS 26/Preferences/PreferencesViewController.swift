import UIKit

final class PreferencesViewController: UIViewController, ReceiverPresenter {
    weak var processor: (any Receiver<PreferencesAction>)?

    @IBOutlet var autoplaySwitch: UISwitch!

    @IBOutlet var pickerView: UIPickerView!

    override func viewDidLoad() {
        navigationItem.title = "Preferences"
        let done = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        navigationItem.rightBarButtonItem = done
        let cancel = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
        navigationItem.leftBarButtonItem = cancel
        Task {
            await processor?.receive(.initialData)
        }
    }

    func present(_ state: PreferencesState) async {
        pickerView.selectRow(state.layoutNumber, inComponent: 0, animated: false)
        autoplaySwitch.isOn = state.autoplay
    }

    @objc func done() {
        let layout = pickerView.selectedRow(inComponent: 0)
        let autoplay = autoplaySwitch.isOn
        Task {
            await processor?.receive(.done(layout, autoplay))
        }
    }

    @objc func cancel() {
        Task {
            await processor?.receive(.cancel)
        }
    }
}

extension PreferencesViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return BottleLayout.layouts.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let count = BottleLayout.layouts[row].count
        return String(count) + " Bottle" + (count > 1 ? "s" : "")
    }
}

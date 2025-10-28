@testable import Bottles
import Testing
import UIKit
import WaitWhile

struct PreferencesViewControllerTests {
    let subject = PreferencesViewController(nibName: "Preferences", bundle: nil)
    let processor = MockProcessor<PreferencesAction, PreferencesState, Void>()

    init() {
        subject.processor = processor
    }

    @Test("viewDidLoad: configures navigation item")
    func viewDidLoad() throws {
        subject.loadViewIfNeeded()
        #expect(subject.navigationItem.title == "Preferences")
        let done = try #require(subject.navigationItem.rightBarButtonItem)
        #expect(done.target === subject)
        #expect(done.action == #selector(subject.done))
        let cancel = try #require(subject.navigationItem.leftBarButtonItem)
        #expect(cancel.target === subject)
        #expect(cancel.action == #selector(subject.cancel))
    }

    @Test("done: sends done, reporting state of interface")
    func done() async throws {
        subject.loadViewIfNeeded()
        subject.pickerView.selectRow(10, inComponent: 0, animated: false)
        subject.autoplaySwitch.isOn = false
        subject.done()
        await #while(processor.thingsReceived.isEmpty)
        #expect(processor.thingsReceived == [.done(10, false)])
    }

    @Test("cancel: sends cancel")
    func cancel() async throws {
        subject.cancel()
        await #while(processor.thingsReceived.isEmpty)
        #expect(processor.thingsReceived == [.cancel])
    }

    @Test("picker view has correct component count")
    func components() {
        let count = subject.numberOfComponents(in: UIPickerView())
        #expect(count == 1)
    }

    @Test("picker view has correct number of rows")
    func rows() {
        let count = subject.pickerView(UIPickerView(), numberOfRowsInComponent: 0)
        #expect(count == 32)
    }

    @Test("picker view has correct titles")
    func titles() {
        do {
            let title = subject.pickerView(UIPickerView(), titleForRow: 0, forComponent: 0)
            #expect(title == "99 Bottles")
        }
        do {
            let title = subject.pickerView(UIPickerView(), titleForRow: 30, forComponent: 0)
            #expect(title == "2 Bottles")
        }
        do {
            let title = subject.pickerView(UIPickerView(), titleForRow: 31, forComponent: 0)
            #expect(title == "1 Bottle")
        }
    }

}

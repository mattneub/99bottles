import UIKit
@testable import Bottles

final class MockPreferencesDelegate: @MainActor Processor, PreferencesDelegate {
    var presenter: (any ReceiverPresenter<RootEffect, RootState>)?
    typealias PresenterState = RootState
    typealias Effect = RootEffect
    func receive(_: RootAction) async {}

    var methodsCalled = [String]()

    func cancel() async {
        methodsCalled.append(#function)
    }
    func done() async {
        methodsCalled.append(#function)
    }
}

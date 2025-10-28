@testable import Bottles
import Testing
import Foundation

struct PersistenceTests {
    let subject = Persistence()
    let defaults = MockUserDefaults()

    init() {
        services.userDefaults = defaults
    }

    @Test("setLayoutNumber: sets value for layoutNumber key")
    func setLayoutNumber() {
        subject.setLayoutNumber(21)
        #expect(defaults.methodsCalled == ["set(_:forKey:)"])
        #expect(defaults.thingsSet["layoutNumber"] as? Int == 21)
    }

    @Test("layoutNumber fetches integer for layoutNumber key")
    func layoutNumber() {
        defaults.integerToReturn = 22
        let result = subject.layoutNumber()
        #expect(defaults.methodsCalled == ["integer(forKey:)"])
        #expect(defaults.keys == ["layoutNumber"])
        #expect(result == 22)
    }

    @Test("setInteractive: sets value for interactive key")
    func setInteractive() {
        subject.setInteractive(true)
        #expect(defaults.methodsCalled == ["set(_:forKey:)"])
        #expect(defaults.thingsSet["interactive"] as? Bool == true)
    }

    @Test("interactive: fetches bool for interactive key")
    func interactive() {
        defaults.boolToReturn = true
        let result = subject.interactive()
        #expect(defaults.methodsCalled == ["bool(forKey:)"])
        #expect(defaults.keys == ["interactive"])
        #expect(result == true)
    }
}

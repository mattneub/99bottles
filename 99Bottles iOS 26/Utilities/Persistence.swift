import UIKit

/// Keys used in user defaults.
struct Defaults {
    static let layoutNumber = "layoutNumber"
    static let interactive = "interactive"
}

/// Public fact of our Persistence object, so we can mock it for testing.
protocol PersistenceType {
    func setLayoutNumber(_: Int)
    func layoutNumber() -> Int
    func setInteractive(_: Bool)
    func interactive() -> Bool
}

/// Object that communicates with user defaults.
struct Persistence: PersistenceType {
    func setLayoutNumber(_ number: Int) {
        services.userDefaults.set(number, forKey: Defaults.layoutNumber)
    }

    func layoutNumber() -> Int {
        services.userDefaults.integer(forKey: Defaults.layoutNumber)
    }

    func setInteractive(_ bool: Bool) {
        services.userDefaults.set(bool, forKey: Defaults.interactive)
    }

    func interactive() -> Bool {
        services.userDefaults.bool(forKey: Defaults.interactive)
    }

}

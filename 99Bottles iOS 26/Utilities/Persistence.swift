import UIKit

struct Defaults {
    static let layoutNumber = "layoutNumber"
    static let interactive = "interactive"
}

protocol PersistenceType {
    func setLayoutNumber(_: Int)
    func layoutNumber() -> Int
    func setInteractive(_: Bool)
    func interactive() -> Bool
}

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

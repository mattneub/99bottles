import Foundation

/// Protocol expressing the public face of UserDefaults, so we can mock it for testing.
protocol UserDefaultsType {
    func integer(forKey: String) -> Int
    func bool(forKey: String) -> Bool
    func set(_: Any?, forKey: String)
}

extension UserDefaults: UserDefaultsType {}

import Foundation

protocol UserDefaultsType {
    func integer(forKey: String) -> Int
    func bool(forKey: String) -> Bool
    func set(_: Any?, forKey: String)
}

extension UserDefaults: UserDefaultsType {}

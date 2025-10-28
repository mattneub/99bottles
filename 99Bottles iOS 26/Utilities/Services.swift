import UIKit

final class Services {
    var persistence: PersistenceType = Persistence()
    var userDefaults: UserDefaultsType = UserDefaults.standard
    var view: UIView.Type = UIView.self
}

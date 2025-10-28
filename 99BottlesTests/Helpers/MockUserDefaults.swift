@testable import Bottles
import Foundation

final class MockUserDefaults: UserDefaultsType {
    var methodsCalled = [String]()
    var thingsSet = [String: Any?]()
    var integerToReturn = 0
    var boolToReturn = false
    var keys = [String]()

    func integer(forKey key: String) -> Int {
        methodsCalled.append(#function)
        keys.append(key)
        return integerToReturn
    }
    
    func bool(forKey key: String) -> Bool {
        methodsCalled.append(#function)
        keys.append(key)
        return boolToReturn
    }
    
    func set(_ value: Any?, forKey key: String) {
        methodsCalled.append(#function)
        thingsSet[key] = value
    }
    

}

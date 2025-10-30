import Foundation
@testable import Bottles

final class MockBundle: BundleType {
    var methodsCalled = [String]()
    var resource: String?
    var ext: String?
    var subdirectory: String?
    var urlToReturn: URL?

    func url(forResource resource: String?, withExtension ext: String?, subdirectory: String?) -> URL? {
        methodsCalled.append(#function)
        self.resource = resource
        self.ext = ext
        self.subdirectory = subdirectory
        return urlToReturn
    }
}

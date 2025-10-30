import Foundation

protocol BundleType {
    func url(forResource: String?, withExtension: String?, subdirectory: String?) -> URL?
}

extension Bundle: BundleType {}

import Foundation

/// Protocol expressing the public face of Bundle, so we can mock it for testing.
protocol BundleType {
    func url(forResource: String?, withExtension: String?, subdirectory: String?) -> URL?
}

extension Bundle: BundleType {}

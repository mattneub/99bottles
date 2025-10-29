import UIKit

/// Layer that knows how to draw a bottle and how to animate itself.
nonisolated
class BottleLayer: CALayer, CAAnimationDelegate {
    /// Number of the bottle to draw.
    let bottleNumber: Int

    /// Initialize the layer.
    /// - Parameters:
    ///   - bottleNumber: The number of the bottle image to use, in the range `1...5`.
    ///   - scale: The contents scale to use for drawing, namely the scale of the screen.
    init(bottleNumber: Int, scale: CGFloat) {
        self.bottleNumber = bottleNumber
        super.init()
        self.contentsScale = scale
    }

    override init(layer other: Any) {
        guard let other = other as? BottleLayer else {
            fatalError("Tried to init(layer:) with wrong kind of layer")
        }
        self.bottleNumber = other.bottleNumber
        super.init()
        self.contentsScale = other.contentsScale
    }

    required init(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }

    override func draw(in context: CGContext) {
        let imageName = "bottle\(bottleNumber).png"
        if let image = UIImage(named: "Bottles/\(imageName)") {
            UIGraphicsPushContext(context)
            image.draw(in: self.bounds)
            UIGraphicsPopContext()
        }
    }

    func jiggle() {}

    func flyAway() {}
}

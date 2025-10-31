import UIKit

/// Layer that knows how to draw a bottle and how to animate itself.
nonisolated
class BottleLayer: CALayer, CAAnimationDelegate {
    /// Number of the bottle to draw.
    let bottleNumber: Int
    let screenBounds: CGRect
    var flown = false

    /// Initialize the layer.
    /// - Parameters:
    ///   - bottleNumber: The number of the bottle image to use, in the range `1...5`.
    ///   - scale: The contents scale to use for drawing, namely the scale of the screen.
    init(bottleNumber: Int, scale: CGFloat, screenBounds: CGRect) {
        self.bottleNumber = bottleNumber
        self.screenBounds = screenBounds
        super.init()
        self.contentsScale = scale
    }

    override init(layer other: Any) {
        guard let other = other as? BottleLayer else {
            fatalError("Tried to init(layer:) with wrong kind of layer")
        }
        self.bottleNumber = other.bottleNumber
        self.screenBounds = other.screenBounds
        super.init()
        self.contentsScale = other.contentsScale
        self.flown = other.flown
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

    /// Jiggle the layer, to indicate that this is the selected layer to be taken down (and passed around).
    func jiggle() {
        func randomRotation() -> CATransform3D {
            let result = CATransform3DMakeRotation(
                CGFloat.random(in:(-1.0)...(1.0)), 0.0, 0.0, 1.0)
            return result
        }
        let animation = CABasicAnimation(keyPath: "transform")
        animation.toValue = CATransform3DConcat(randomRotation(), CATransform3DMakeScale(1.2, 1.2, 1))
        let transform2 = CATransform3DConcat(randomRotation(), CATransform3DMakeScale(1.5, 1.5, 1))
        animation.fromValue = transform2
        animation.repeatCount = .infinity
        animation.duration = 0.35
        animation.autoreverses = true
        let grow = CABasicAnimation(keyPath: "transform")
        grow.toValue = transform2
        grow.fromValue = CATransform3DIdentity
        grow.duration = 0.1
        animation.beginTime = grow.duration
        let group = CAAnimationGroup()
        group.animations = [grow, animation]
        group.duration = 100 // not really, because `flyAway` will take over
        self.add(group, forKey: "jiggle")
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        self.zPosition = 1
        CATransaction.commit()
    }

    /// Take down (and pass around) this layer.
    func flyAway() {
        self.flown = true
        // imagine a circle centered in the center of the screen, and quite a bit larger than the screen
        // then its radius r is:
        let radius = screenBounds.height / 2.0 + 50
        // randomly pick an angle alpha (integer degrees but that's fine)
        let angle : Int = Int.random(in: 0..<360)
        let radians = CGFloat(Double(angle) * .pi / 180.0)
        // then that point on that circle is r cos alpha, r sin alpha...
        // ...offset by the center of the screen
        let targetPoint = CGPoint(
            x: screenBounds.midX + radius * cos(radians),
            y: screenBounds.midY + radius * sin(radians)
        )
        // apply an animation of ourself to that point
        let animation = CABasicAnimation(keyPath: #keyPath(CALayer.position))
        animation.fromValue = self.position
        animation.toValue = targetPoint
        animation.timingFunction = CAMediaTimingFunction(name: .easeIn)
        animation.duration = 0.5
        animation.delegate = self
        animation.setValue(true, forKey: "flyAway")
        self.add(animation, forKey: "flyAway")
        // also set the actual position to the new position, without animation
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        self.position = targetPoint
        CATransaction.commit()
    }

    /// After taking down (and passing around), we are done with this layer. Remove from interface.
    func animationDidStop(_ animation: CAAnimation, finished flag: Bool) {
        if animation.value(forKey: "flyAway") != nil {
            self.removeFromSuperlayer()
        }
    }
}

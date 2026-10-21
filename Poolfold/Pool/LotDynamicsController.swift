import UIKit

/// UIKit Dynamics rail for the remaining cent lot. Snap, collision, and attachment live here.
@MainActor
final class LotDynamicsController: NSObject {
    private var animator: UIDynamicAnimator?
    private var token: UIView?
    private var attachment: UIAttachmentBehavior?
    private let wells = NSMapTable<UIView, NSString>.weakToStrongObjects()
    var onSnap: ((UUID) -> Void)?
    var reduceMotion = false

    func install(in host: UIView, centsLabel: String) {
        animator?.removeAllBehaviors()
        token?.removeFromSuperview()
        let chip = UIView(frame: CGRect(x: 16, y: 16, width: 88, height: 56))
        chip.backgroundColor = UIColor(red: 0.847, green: 0.392, blue: 0.545, alpha: 0.92)
        chip.layer.cornerRadius = 2
        chip.layer.borderWidth = 2
        chip.layer.borderColor = UIColor(white: 0.98, alpha: 0.9).cgColor
        chip.accessibilityLabel = "Remaining lot"
        let label = UILabel(frame: chip.bounds.insetBy(dx: 4, dy: 4))
        label.text = centsLabel
        label.textAlignment = .center
        label.textColor = UIColor(white: 0.98, alpha: 1)
        label.font = UIFont(name: "Georgia", size: 13)
        label.adjustsFontSizeToFitWidth = true
        label.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        chip.addSubview(label)
        host.addSubview(chip)
        token = chip
        let pan = UIPanGestureRecognizer(target: self, action: #selector(drag(_:)))
        chip.addGestureRecognizer(pan)
        chip.isAccessibilityElement = true
        let dynamics = UIDynamicAnimator(referenceView: host)
        let collision = UICollisionBehavior(items: [chip])
        collision.translatesReferenceBoundsIntoBoundary = true
        dynamics.addBehavior(collision)
        animator = dynamics
    }

    func registerWell(_ view: UIView, stationID: UUID) {
        wells.setObject(stationID.uuidString as NSString, forKey: view)
    }

    func clearWells() {
        wells.removeAllObjects()
    }

    @objc private func drag(_ gesture: UIPanGestureRecognizer) {
        guard let chip = token, let host = chip.superview, let animator else { return }
        let point = gesture.location(in: host)
        switch gesture.state {
        case .began:
            attachment.map { animator.removeBehavior($0) }
            let pin = UIAttachmentBehavior(item: chip, attachedToAnchor: point)
            pin.damping = 0.8
            pin.frequency = 4
            animator.addBehavior(pin)
            attachment = pin
        case .changed:
            attachment?.anchorPoint = point
        case .ended, .cancelled:
            if let attachment {
                animator.removeBehavior(attachment)
            }
            attachment = nil
            if let hit = well(at: point, in: host), let raw = wells.object(forKey: hit), let id = UUID(uuidString: raw as String) {
                let center = host.convert(hit.center, from: hit.superview)
                if reduceMotion {
                    UIView.animate(withDuration: 0.16) {
                        chip.center = center
                        chip.alpha = 1
                    }
                } else {
                    let snap = UISnapBehavior(item: chip, snapTo: center)
                    snap.damping = 0.7
                    animator.addBehavior(snap)
                }
                onSnap?(id)
            }
        default:
            break
        }
    }

    private func well(at point: CGPoint, in host: UIView) -> UIView? {
        let enumerator = wells.keyEnumerator()
        var best: UIView?
        var bestDistance = CGFloat.greatestFiniteMagnitude
        while let view = enumerator.nextObject() as? UIView {
            let center = host.convert(view.center, from: view.superview)
            let distance = hypot(center.x - point.x, center.y - point.y)
            if distance < 72, distance < bestDistance {
                best = view
                bestDistance = distance
            }
        }
        return best
    }
}

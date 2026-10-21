import SwiftUI
import UIKit

/// Hero surface. Isometric station pods plus the dynamics lot. The only custom-drawn screen.
struct IsometricFloorCanvas: UIViewRepresentable {
    var stations: [Station]
    var selectedID: UUID?
    var remainingLabel: String
    var reduceMotion: Bool
    var onSelect: (UUID) -> Void
    var onSnap: (UUID) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(onSelect: onSelect, onSnap: onSnap)
    }

    func makeUIView(context: Context) -> FloorBoardView {
        let view = FloorBoardView()
        view.coordinator = context.coordinator
        return view
    }

    func updateUIView(_ uiView: FloorBoardView, context: Context) {
        context.coordinator.onSelect = onSelect
        context.coordinator.onSnap = onSnap
        uiView.coordinator = context.coordinator
        uiView.apply(stations: stations, selectedID: selectedID, remainingLabel: remainingLabel, reduceMotion: reduceMotion)
    }

    final class Coordinator {
        var onSelect: (UUID) -> Void
        var onSnap: (UUID) -> Void
        init(onSelect: @escaping (UUID) -> Void, onSnap: @escaping (UUID) -> Void) {
            self.onSelect = onSelect
            self.onSnap = onSnap
        }
    }
}

@MainActor
final class FloorBoardView: UIView {
    var coordinator: IsometricFloorCanvas.Coordinator?
    private let dynamics = LotDynamicsController()
    private var podViews: [UUID: StationPodView] = [:]
    private var lastSignature = ""

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        isOpaque = false
        dynamics.onSnap = { [weak self] id in
            self?.coordinator?.onSnap(id)
        }
    }

    required init?(coder: NSCoder) {
        return nil
    }

    func apply(stations: [Station], selectedID: UUID?, remainingLabel: String, reduceMotion: Bool) {
        dynamics.reduceMotion = reduceMotion
        let signature = stations.map { "\($0.id.uuidString):\($0.lotCents):\($0.name)" }.joined(separator: "|") + remainingLabel
        if signature != lastSignature {
            lastSignature = signature
            podViews.values.forEach { $0.removeFromSuperview() }
            podViews.removeAll()
            dynamics.clearWells()
            dynamics.install(in: self, centsLabel: remainingLabel)
            for station in stations {
                let pod = StationPodView(station: station)
                pod.addTarget(self, action: #selector(tapPod(_:)), for: .touchUpInside)
                addSubview(pod)
                podViews[station.id] = pod
                dynamics.registerWell(pod.well, stationID: station.id)
            }
        }
        for station in stations {
            podViews[station.id]?.refresh(station: station, selected: station.id == selectedID)
        }
        setNeedsLayout()
    }

    @objc private func tapPod(_ sender: StationPodView) {
        coordinator?.onSelect(sender.stationID)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let pods = podViews.values.sorted { $0.stationName < $1.stationName }
        let columns = 2
        let width = bounds.width
        let height = bounds.height
        guard width > 1, height > 1 else { return }
        let cellW = width / CGFloat(columns)
        let cellH = max(88, (height - 72) / CGFloat(max(1, Int(ceil(Double(pods.count) / Double(columns))))))
        for (index, pod) in pods.enumerated() {
            let column = index % columns
            let row = index / columns
            let x = CGFloat(column) * cellW + 12
            let y = 78 + CGFloat(row) * cellH
            pod.frame = CGRect(x: x, y: y, width: cellW - 24, height: min(120, cellH - 8))
        }
    }
}

@MainActor
final class StationPodView: UIControl {
    let stationID: UUID
    let stationName: String
    let well = UIView()
    private let plate = UILabel()
    private let health = UILabel()
    private var lotCents = 0
    private var healthValue = 0

    init(station: Station) {
        stationID = station.id
        stationName = station.name
        super.init(frame: .zero)
        backgroundColor = .clear
        well.isUserInteractionEnabled = false
        addSubview(well)
        plate.font = UIFont(name: "Georgia", size: 15)
        plate.textColor = UIColor(white: 0.98, alpha: 1)
        plate.adjustsFontForContentSizeCategory = true
        health.font = UIFont(name: "Georgia", size: 12)
        health.textColor = UIColor(white: 0.70, alpha: 1)
        health.adjustsFontForContentSizeCategory = true
        addSubview(plate)
        addSubview(health)
        refresh(station: station, selected: false)
        accessibilityTraits = .button
    }

    required init?(coder: NSCoder) {
        return nil
    }

    func refresh(station: Station, selected: Bool) {
        lotCents = station.lotCents
        healthValue = StationHealthCalculator.health(of: station)
        plate.text = station.name
        let lot = PoolFormat.cents(station.lotCents)
        health.text = "Health \(PoolFormat.count(healthValue)). Cash \(lot)"
        accessibilityLabel = "\(station.name). Health \(healthValue). Cash \(lot)"
        layer.borderWidth = selected ? 2 : 0
        layer.borderColor = UIColor(red: 0.847, green: 0.392, blue: 0.545, alpha: 1).cgColor
        layer.cornerRadius = 4
        setNeedsDisplay()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        well.frame = CGRect(x: bounds.midX - 18, y: 18, width: 36, height: 22)
        plate.frame = CGRect(x: 8, y: bounds.height - 40, width: bounds.width - 16, height: 20)
        health.frame = CGRect(x: 8, y: bounds.height - 20, width: bounds.width - 16, height: 16)
    }

    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        let top = UIColor(red: 0.847, green: 0.392, blue: 0.545, alpha: lotCents > 0 ? 1 : 0.45)
        let left = UIColor(white: 0.18, alpha: 1)
        let right = UIColor(white: 0.12, alpha: 1)
        let midX = rect.midX
        let topY: CGFloat = 8
        let path = UIBezierPath()
        path.move(to: CGPoint(x: midX, y: topY))
        path.addLine(to: CGPoint(x: midX + 46, y: topY + 22))
        path.addLine(to: CGPoint(x: midX, y: topY + 44))
        path.addLine(to: CGPoint(x: midX - 46, y: topY + 22))
        path.close()
        top.setFill()
        path.fill()
        context.setStrokeColor(UIColor(white: 0.98, alpha: 0.85).cgColor)
        context.setLineWidth(2)
        path.stroke()
        let leftFace = UIBezierPath()
        leftFace.move(to: CGPoint(x: midX - 46, y: topY + 22))
        leftFace.addLine(to: CGPoint(x: midX, y: topY + 44))
        leftFace.addLine(to: CGPoint(x: midX, y: topY + 70))
        leftFace.addLine(to: CGPoint(x: midX - 46, y: topY + 48))
        leftFace.close()
        left.setFill()
        leftFace.fill()
        let rightFace = UIBezierPath()
        rightFace.move(to: CGPoint(x: midX + 46, y: topY + 22))
        rightFace.addLine(to: CGPoint(x: midX, y: topY + 44))
        rightFace.addLine(to: CGPoint(x: midX, y: topY + 70))
        rightFace.addLine(to: CGPoint(x: midX + 46, y: topY + 48))
        rightFace.close()
        right.setFill()
        rightFace.fill()
        _ = healthValue
    }
}

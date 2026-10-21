import Foundation

/// Disk plus UserDefaults seam. UI never reads the file. Debounced after each mark, flushed on background.
@MainActor
final class FloorStore: ObservableObject {
    @Published private(set) var chart: FloorChart
    @Published private(set) var loadFailed = false

    private let defaults: UserDefaults
    private let directory: URL
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    private var saveTask: Task<Void, Never>?
    private let fileName = "pfd.floor.v1.json"
    nonisolated static let defaultsKey = "pfd.floor.v1"
    nonisolated static let demoKey = "pfd.demo.v1"

    init(defaults: UserDefaults = .standard, directory: URL? = nil, seedDemo: Bool = true) {
        self.defaults = defaults
        let base = directory ?? FloorStore.supportDirectory()
        self.directory = base
        encoder.outputFormatting = [.sortedKeys]
        chart = .empty
        let loaded = Self.readChart(directory: base, fileName: fileName, defaults: defaults, decoder: decoder)
        if let loaded {
            chart = loaded.chart
            loadFailed = loaded.failed
        }
        if seedDemo {
            SimulatorSeed.applyIfNeeded(to: &chart, defaults: defaults)
            if defaults.bool(forKey: Self.demoKey) {
                scheduleSave()
            }
        }
    }

    func reload() {
        if let loaded = Self.readChart(directory: directory, fileName: fileName, defaults: defaults, decoder: decoder) {
            chart = loaded.chart
            loadFailed = loaded.failed
        } else {
            loadFailed = false
            var next = chart
            next.loadNote = nil
            chart = next
        }
    }

    func replace(_ chart: FloorChart) {
        self.chart = chart
        scheduleSave()
    }

    func apply(_ outcome: FloorFoldEngine.Outcome) {
        chart = outcome.chart
        scheduleSave()
    }

    func finishOnboarding(skip: Bool) {
        var next = chart
        if next.stations.isEmpty {
            let seeded = SimulatorSeed.freshHouse()
            next.stations = seeded.stations
            next.staff = seeded.staff
            next.bout = seeded.bout
            next.openingPoolCents = seeded.openingPoolCents
            next.walkInCents = seeded.walkInCents
            next.shifts = []
            next.marks = []
            next.floatCents = 0
            next.bracketSeeded = false
            for index in next.stations.indices {
                next.stations[index].lotCents = 0
            }
        }
        let clocked = FloorFoldEngine.clock(chart: next, staffID: next.staff.first?.id)
        next = clocked.chart
        next.onboardingDone = true
        if skip {
            next.loadNote = nil
        }
        chart = next
        scheduleSave()
    }

    func resetAllData() {
        saveTask?.cancel()
        chart = .empty
        chart.onboardingDone = false
        loadFailed = false
        defaults.removeObject(forKey: Self.defaultsKey)
        defaults.removeObject(forKey: Self.demoKey)
        let url = directory.appendingPathComponent(fileName)
        try? FileManager.default.removeItem(at: url)
        try? FileManager.default.removeItem(at: url.appendingPathExtension("backup"))
        scheduleSave()
    }

    func setOpeningPool(_ cents: Int) {
        guard cents > 0, chart.allocatedCents == 0 else { return }
        chart.openingPoolCents = cents
        scheduleSave()
    }

    func scheduleSave() {
        saveTask?.cancel()
        guard let data = try? encoder.encode(chart) else { return }
        defaults.set(data, forKey: Self.defaultsKey)
        let directory = directory
        let fileName = fileName
        saveTask = Task {
            try? await Task.sleep(nanoseconds: 300_000_000)
            if Task.isCancelled { return }
            await FloorDisk.write(data, directory: directory, fileName: fileName)
        }
    }

    func flush() async {
        saveTask?.cancel()
        saveTask = nil
        guard let data = try? encoder.encode(chart) else { return }
        defaults.set(data, forKey: Self.defaultsKey)
        await FloorDisk.write(data, directory: directory, fileName: fileName)
    }

    private static func supportDirectory() -> URL {
        let root = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? FileManager.default.temporaryDirectory
        return root.appendingPathComponent("Avialobik", isDirectory: true)
    }

    private static func readChart(
        directory: URL,
        fileName: String,
        defaults: UserDefaults,
        decoder: JSONDecoder
    ) -> (chart: FloorChart, failed: Bool)? {
        let url = directory.appendingPathComponent(fileName)
        if let data = try? Data(contentsOf: url), let chart = decode(data, decoder: decoder) {
            return (chart, false)
        }
        if FileManager.default.fileExists(atPath: url.path) {
            let backup = url.appendingPathExtension("backup")
            try? FileManager.default.removeItem(at: backup)
            try? FileManager.default.copyItem(at: url, to: backup)
        }
        let backup = url.appendingPathExtension("backup")
        if let data = try? Data(contentsOf: backup), var chart = decode(data, decoder: decoder) {
            chart.loadNote = "Saved floor was unreadable. Restored the previous copy."
            return (chart, true)
        }
        if let data = defaults.data(forKey: defaultsKey), var chart = decode(data, decoder: decoder) {
            chart.loadNote = nil
            return (chart, false)
        }
        if FileManager.default.fileExists(atPath: url.path) {
            var chart = FloorChart.empty
            chart.loadNote = "Saved floor was unreadable. Started empty."
            return (chart, true)
        }
        return nil
    }

    private static func decode(_ data: Data, decoder: JSONDecoder) -> FloorChart? {
        guard let chart = try? decoder.decode(FloorChart.self, from: data) else { return nil }
        guard chart.schemaVersion == 1 else { return nil }
        return chart
    }
}

enum FloorDisk {
    static func write(
        _ data: Data,
        directory: URL,
        fileName: String
    ) async {
        let folder = directory
        let destination = folder.appendingPathComponent(fileName)
        await Task.detached(priority: .utility) {
            try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
            let temporary = folder.appendingPathComponent(fileName + ".tmp")
            do {
                try data.write(to: temporary, options: .atomic)
                if FileManager.default.fileExists(atPath: destination.path) {
                    _ = try FileManager.default.replaceItemAt(destination, withItemAt: temporary)
                } else {
                    try FileManager.default.moveItem(at: temporary, to: destination)
                }
                var values = URLResourceValues()
                values.isExcludedFromBackup = false
                var mutable = destination
                try? mutable.setResourceValues(values)
            } catch {
                try? FileManager.default.removeItem(at: temporary)
            }
        }.value
    }
}

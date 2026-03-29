import Foundation
import UIKit

@Observable
final class JournalStore {
    private(set) var entries: [JournalEntry] = []
    private(set) var currentStreak: Int = 0

    private let dataURL: URL
    private let imagesDirectory: URL

    // App Group suite for widget data sharing.
    // Enable the "App Groups" capability (group.Sagar.Journal) in both
    // the Journal and JournalWidget targets for this to work.
    static let appGroupSuite = "group.Sagar.Journal"

    init() {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        dataURL = docs.appendingPathComponent("entries.json")
        imagesDirectory = docs.appendingPathComponent("images", isDirectory: true)
        try? FileManager.default.createDirectory(at: imagesDirectory, withIntermediateDirectories: true)
        load()
        calculateStreak()
    }

    // MARK: - Computed

    var hasJournaledToday: Bool {
        entries.contains { Calendar.current.isDateInToday($0.date) }
    }

    // MARK: - CRUD

    func add(_ entry: JournalEntry) {
        entries.append(entry)
        entries.sort { $0.date > $1.date }
        save()
        calculateStreak()
        syncWidgetData()
    }

    func update(_ entry: JournalEntry) {
        guard let idx = entries.firstIndex(where: { $0.id == entry.id }) else { return }
        entries[idx] = entry
        entries.sort { $0.date > $1.date }
        save()
    }

    func delete(_ entry: JournalEntry) {
        for name in entry.imageFileNames { deleteImage(named: name) }
        entries.removeAll { $0.id == entry.id }
        save()
        calculateStreak()
        syncWidgetData()
    }

    // MARK: - Image helpers

    func saveImage(_ image: UIImage) -> String? {
        let name = UUID().uuidString + ".jpg"
        guard let data = image.jpegData(compressionQuality: 0.8) else { return nil }
        try? data.write(to: imageURL(for: name), options: .atomic)
        return name
    }

    func loadImage(named name: String) -> UIImage? {
        UIImage(contentsOfFile: imageURL(for: name).path)
    }

    func deleteImage(named name: String) {
        try? FileManager.default.removeItem(at: imageURL(for: name))
    }

    private func imageURL(for name: String) -> URL {
        imagesDirectory.appendingPathComponent(name)
    }

    // MARK: - Streak

    private func calculateStreak() {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        let yesterday = cal.date(byAdding: .day, value: -1, to: today)!

        let uniqueDays = Set(entries.map { cal.startOfDay(for: $0.date) }).sorted(by: >)

        guard let latest = uniqueDays.first,
              latest == today || latest == yesterday else {
            currentStreak = 0
            return
        }

        var streak = 1
        var pivot = latest
        for day in uniqueDays.dropFirst() {
            let expected = cal.date(byAdding: .day, value: -1, to: pivot)!
            guard day == expected else { break }
            streak += 1
            pivot = day
        }
        currentStreak = streak
    }

    // MARK: - Widget sync

    private func syncWidgetData() {
        let defaults = UserDefaults(suiteName: Self.appGroupSuite) ?? .standard
        defaults.set(currentStreak, forKey: "daylog_streak")
        defaults.set(hasJournaledToday, forKey: "daylog_journaledToday")
    }

    // MARK: - Persistence

    private func save() {
        let enc = JSONEncoder()
        enc.dateEncodingStrategy = .iso8601
        guard let data = try? enc.encode(entries) else { return }
        try? data.write(to: dataURL, options: .atomic)
    }

    private func load() {
        let dec = JSONDecoder()
        dec.dateDecodingStrategy = .iso8601
        guard
            let data = try? Data(contentsOf: dataURL),
            let decoded = try? dec.decode([JournalEntry].self, from: data)
        else { return }
        entries = decoded.sorted { $0.date > $1.date }
    }
}

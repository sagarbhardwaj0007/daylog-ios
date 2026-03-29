import Foundation

struct JournalEntry: Identifiable, Codable, Hashable {
    let id: UUID
    var date: Date
    var text: String
    var imageFileNames: [String]
    let createdAt: Date

    init(
        id: UUID = UUID(),
        date: Date = Date(),
        text: String = "",
        imageFileNames: [String] = [],
        createdAt: Date = Date()
    ) {
        self.id = id
        self.date = date
        self.text = text
        self.imageFileNames = imageFileNames
        self.createdAt = createdAt
    }

    var previewText: String {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return imageFileNames.isEmpty ? "" : "\(imageFileNames.count) photo\(imageFileNames.count == 1 ? "" : "s")" }
        return trimmed
    }

    var isEmpty: Bool {
        text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && imageFileNames.isEmpty
    }
}

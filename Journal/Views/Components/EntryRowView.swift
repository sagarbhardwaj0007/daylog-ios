import SwiftUI

struct EntryRowView: View {
    let entry: JournalEntry
    let store: JournalStore

    private var dateLabel: String {
        let cal = Calendar.current
        if cal.isDateInToday(entry.date) { return "Today" }
        if cal.isDateInYesterday(entry.date) { return "Yesterday" }
        let fmt = DateFormatter()
        fmt.dateFormat = "EEE, MMM d"
        return fmt.string(from: entry.date)
    }

    private var timeLabel: String {
        let fmt = DateFormatter()
        fmt.timeStyle = .short
        return fmt.string(from: entry.date)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(dateLabel)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                Text("·")
                    .foregroundStyle(.secondary)
                Text(timeLabel)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                if !entry.imageFileNames.isEmpty {
                    Label("\(entry.imageFileNames.count)", systemImage: "photo")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            if !entry.previewText.isEmpty {
                Text(entry.previewText)
                    .font(.body)
                    .lineLimit(2)
                    .foregroundStyle(.primary)
            }

            // Thumbnail strip
            if !entry.imageFileNames.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(entry.imageFileNames.prefix(4), id: \.self) { name in
                            if let img = store.loadImage(named: name) {
                                Image(uiImage: img)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 56, height: 56)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                        }
                    }
                }
            }
        }
        .padding(16)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 16))
    }
}

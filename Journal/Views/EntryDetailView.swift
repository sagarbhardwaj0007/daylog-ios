import SwiftUI

struct EntryDetailView: View {
    let entry: JournalEntry
    let store: JournalStore
    let onEdit: () -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var showDeleteConfirm = false

    private var formattedDate: String {
        let fmt = DateFormatter()
        fmt.dateStyle = .full
        fmt.timeStyle = .short
        return fmt.string(from: entry.date)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Date
                Text(formattedDate)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                // Body text
                if !entry.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    Text(entry.text)
                        .font(.body)
                        .lineSpacing(6)
                        .textSelection(.enabled)
                }

                // Images
                if !entry.imageFileNames.isEmpty {
                    let loaded = entry.imageFileNames.compactMap { store.loadImage(named: $0) }
                    ImageGridView(images: loaded)
                }
            }
            .padding(20)
        }
        .navigationTitle(relativeDate(entry.date))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button {
                    onEdit()
                    dismiss()
                } label: {
                    Label("Edit", systemImage: "pencil")
                }

                Button(role: .destructive) {
                    showDeleteConfirm = true
                } label: {
                    Label("Delete", systemImage: "trash")
                }
            }
        }
        .confirmationDialog("Delete this entry?", isPresented: $showDeleteConfirm, titleVisibility: .visible) {
            Button("Delete", role: .destructive) {
                store.delete(entry)
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        }
    }

    private func relativeDate(_ date: Date) -> String {
        let cal = Calendar.current
        if cal.isDateInToday(date) { return "Today" }
        if cal.isDateInYesterday(date) { return "Yesterday" }
        let fmt = DateFormatter()
        fmt.dateFormat = "EEE, MMM d"
        return fmt.string(from: date)
    }
}

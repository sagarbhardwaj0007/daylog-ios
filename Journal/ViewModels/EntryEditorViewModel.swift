import Foundation
import UIKit

@Observable
final class EntryEditorViewModel {

    var text: String = ""
    var images: [UIImage] = []

    let speech = SpeechRecognizer()
    private let store: JournalStore
    private(set) var existingEntry: JournalEntry?

    init(store: JournalStore, entry: JournalEntry? = nil) {
        self.store = store
        self.existingEntry = entry
        if let entry {
            text = entry.text
            images = entry.imageFileNames.compactMap { store.loadImage(named: $0) }
        }
    }

    var canSave: Bool {
        !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || !images.isEmpty
    }

    // MARK: - Voice

    func toggleRecording() async {
        if speech.isRecording {
            speech.stopRecording()
            let t = speech.transcript.trimmingCharacters(in: .whitespacesAndNewlines)
            if !t.isEmpty {
                if !text.isEmpty, !text.hasSuffix("\n") { text += "\n" }
                text += t
            }
        } else {
            let granted = await speech.requestPermissions()
            if granted { speech.startRecording() }
        }
    }

    // MARK: - Images

    func addImage(_ image: UIImage) {
        images.append(image)
    }

    func removeImage(at index: Int) {
        guard images.indices.contains(index) else { return }
        images.remove(at: index)
    }

    // MARK: - Save

    func save() {
        guard canSave else { return }
        if speech.isRecording { speech.stopRecording() }

        let savedNames = images.compactMap { store.saveImage($0) }

        if var existing = existingEntry {
            // Remove old images before replacing
            for name in existing.imageFileNames { store.deleteImage(named: name) }
            existing.text = text
            existing.imageFileNames = savedNames
            store.update(existing)
        } else {
            store.add(JournalEntry(text: text, imageFileNames: savedNames))
        }
    }
}

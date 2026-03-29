import SwiftUI
import PhotosUI

struct EntryEditorView: View {
    @State private var viewModel: EntryEditorViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var photoPickerItems: [PhotosPickerItem] = []
    @State private var showSourcePicker = false
    @State private var showCamera = false
    @State private var showPermissionAlert = false
    @FocusState private var editorFocused: Bool

    init(store: JournalStore, entry: JournalEntry? = nil) {
        _viewModel = State(initialValue: EntryEditorViewModel(store: store, entry: entry))
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Date header
                HStack {
                    Text(viewModel.existingEntry?.date ?? Date(), style: .date)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.secondary)
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)

                Divider()

                // Main text editor
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        TextEditor(text: $viewModel.text)
                            .font(.body)
                            .frame(minHeight: 220)
                            .scrollContentBackground(.hidden)
                            .focused($editorFocused)
                            .overlay(alignment: .topLeading) {
                                if viewModel.text.isEmpty {
                                    Text("What's on your mind?")
                                        .font(.body)
                                        .foregroundStyle(.tertiary)
                                        .padding(.top, 8)
                                        .padding(.leading, 5)
                                        .allowsHitTesting(false)
                                }
                            }
                            .padding(.horizontal, 16)

                        // Image grid
                        if !viewModel.images.isEmpty {
                            ImageGridView(images: viewModel.images) { index in
                                viewModel.removeImage(at: index)
                            }
                            .padding(.horizontal, 16)
                        }
                    }
                    .padding(.vertical, 8)
                }

                // Live transcription banner
                if viewModel.speech.isRecording {
                    recordingBanner
                }

                Divider()

                // Toolbar
                editorToolbar
            }
            .navigationTitle(viewModel.existingEntry == nil ? "New Entry" : "Edit Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        if viewModel.speech.isRecording { viewModel.speech.stopRecording() }
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        viewModel.save()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .disabled(!viewModel.canSave)
                }
            }
            .photosPicker(
                isPresented: $showCamera,
                selection: $photoPickerItems,
                maxSelectionCount: 10,
                matching: .images,
                photoLibrary: .shared()
            )
            .onChange(of: photoPickerItems) { _, newItems in
                loadPhotos(from: newItems)
            }
            .alert("Microphone Access Needed", isPresented: $showPermissionAlert) {
                Button("Open Settings") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Please allow microphone and speech recognition access in Settings to use voice recording.")
            }
        }
        .onAppear { editorFocused = true }
    }

    // MARK: - Subviews

    private var recordingBanner: some View {
        HStack(spacing: 12) {
            // Pulsing mic indicator
            Circle()
                .fill(Color.red)
                .frame(width: 10, height: 10)
                .overlay(
                    Circle()
                        .stroke(Color.red.opacity(0.4), lineWidth: 1)
                        .scaleEffect(1.6)
                )

            Text(viewModel.speech.transcript.isEmpty ? "Listening…" : viewModel.speech.transcript)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(2)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(Color(.systemOrange).opacity(0.08))
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }

    private var editorToolbar: some View {
        HStack(spacing: 4) {
            // Voice button
            Button {
                Task { await toggleVoice() }
            } label: {
                Label(
                    viewModel.speech.isRecording ? "Stop" : "Record",
                    systemImage: viewModel.speech.isRecording ? "stop.circle.fill" : "mic.circle.fill"
                )
                .font(.subheadline.weight(.medium))
                .foregroundStyle(viewModel.speech.isRecording ? .red : .orange)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(
                    (viewModel.speech.isRecording ? Color.red : Color.orange).opacity(0.1),
                    in: Capsule()
                )
            }
            .symbolEffect(.pulse, isActive: viewModel.speech.isRecording)

            // Photo button
            PhotosPicker(
                selection: $photoPickerItems,
                maxSelectionCount: 10,
                matching: .images
            ) {
                Label("Photo", systemImage: "photo.circle.fill")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.orange)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color.orange.opacity(0.1), in: Capsule())
            }

            Spacer()

            // Word count
            if !viewModel.text.isEmpty {
                let wordCount = viewModel.text.split(separator: " ").count
                Text("\(wordCount)w")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                    .padding(.trailing, 4)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
    }

    // MARK: - Helpers

    private func toggleVoice() async {
        if viewModel.speech.permissionDenied {
            showPermissionAlert = true
            return
        }
        await viewModel.toggleRecording()
        if viewModel.speech.permissionDenied {
            showPermissionAlert = true
        }
    }

    private func loadPhotos(from items: [PhotosPickerItem]) {
        Task {
            for item in items {
                if let data = try? await item.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    viewModel.addImage(image)
                }
            }
            photoPickerItems = []
        }
    }
}

#Preview {
    EntryEditorView(store: JournalStore())
}

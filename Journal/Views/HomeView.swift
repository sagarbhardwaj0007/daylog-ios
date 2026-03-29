import SwiftUI

struct HomeView: View {
    @Environment(JournalStore.self) private var store
    @State private var showingEditor = false
    @State private var selectedEntry: JournalEntry? = nil
    @State private var entryToEdit: JournalEntry? = nil

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                ScrollView {
                    LazyVStack(spacing: 12, pinnedViews: []) {
                        // Streak banner
                        StreakView(streak: store.currentStreak, journaledToday: store.hasJournaledToday)
                            .padding(.bottom, 4)

                        // Entry list
                        if store.entries.isEmpty {
                            emptyState
                        } else {
                            ForEach(store.entries) { entry in
                                Button {
                                    selectedEntry = entry
                                } label: {
                                    EntryRowView(entry: entry, store: store)
                                }
                                .buttonStyle(.plain)
                                .contextMenu {
                                    Button {
                                        entryToEdit = entry
                                    } label: {
                                        Label("Edit", systemImage: "pencil")
                                    }
                                    Button(role: .destructive) {
                                        withAnimation { store.delete(entry) }
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .padding(.bottom, 100) // room for FAB
                }
                .scrollDismissesKeyboard(.interactively)

                // Floating action button
                Button {
                    showingEditor = true
                } label: {
                    Image(systemName: "plus")
                        .font(.title2.weight(.semibold))
                        .foregroundStyle(.white)
                        .frame(width: 60, height: 60)
                        .background(Color.orange, in: Circle())
                        .shadow(color: .orange.opacity(0.4), radius: 8, y: 4)
                }
                .padding(28)
            }
            .navigationTitle("Daylog")
            .navigationBarTitleDisplayMode(.large)
            .navigationDestination(item: $selectedEntry) { entry in
                EntryDetailView(entry: entry, store: store) {
                    entryToEdit = entry
                }
            }
        }
        .sheet(isPresented: $showingEditor) {
            EntryEditorView(store: store)
        }
        .sheet(item: $entryToEdit) { entry in
            EntryEditorView(store: store, entry: entry)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "book.pages")
                .font(.system(size: 48))
                .foregroundStyle(.secondary.opacity(0.6))
            Text("No entries yet")
                .font(.title3.weight(.medium))
                .foregroundStyle(.secondary)
            Text("Tap + to write your first entry")
                .font(.subheadline)
                .foregroundStyle(.secondary.opacity(0.8))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 64)
    }
}

#Preview {
    HomeView()
        .environment(JournalStore())
}

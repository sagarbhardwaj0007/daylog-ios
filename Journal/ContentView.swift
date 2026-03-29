import SwiftUI

// ContentView is kept for Xcode previews.
// The app entry point (JournalApp.swift) renders HomeView directly.
struct ContentView: View {
    var body: some View {
        HomeView()
            .environment(JournalStore())
    }
}

#Preview {
    ContentView()
}

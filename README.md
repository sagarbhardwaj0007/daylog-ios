# Daylog

A minimal, calm iOS journaling app built with SwiftUI. Log your day in under 30 seconds — type, speak, or attach a photo.

## Features

- **Write** — distraction-free text editor with word count
- **Speak** — tap mic, talk, get transcribed text instantly (Apple Speech framework)
- **Photos** — attach images from your camera or library
- **Streak tracking** — daily 🔥 streak to keep you consistent
- **Home Screen Widget** — small and medium widgets showing your streak and today's status
- **Entry detail** — tap any log to read it in full, edit, or delete

## Screenshots

> _Add screenshots here once you run the app on a device or simulator._

## Tech Stack

| What | How |
|---|---|
| UI | SwiftUI |
| Architecture | MVVM with `@Observable` |
| Speech-to-text | Apple Speech framework + AVFoundation |
| Image picker | PhotosUI `PhotosPicker` |
| Persistence | Local JSON + Documents directory |
| Widget | WidgetKit (small + medium) |
| Language | Swift 6 |
| Deployment target | iOS 26+ |

## Project Structure

```
Journal/
├── Models/
│   ├── JournalEntry.swift       # Codable data model
│   └── JournalStore.swift       # Persistence, streak logic, image storage
├── Speech/
│   └── SpeechRecognizer.swift   # Live voice-to-text wrapper
├── ViewModels/
│   └── EntryEditorViewModel.swift
└── Views/
    ├── HomeView.swift            # Streak banner, entry list, FAB
    ├── EntryEditorView.swift     # Write, record, attach photos
    ├── EntryDetailView.swift     # Read full entry
    └── Components/
        ├── StreakView.swift
        ├── EntryRowView.swift
        └── ImageGridView.swift
JournalWidget/
└── JournalWidget.swift          # WidgetKit small + medium widgets
```

## Getting Started

1. Clone the repo
   ```bash
   git clone https://github.com/YOUR_USERNAME/daylog-ios.git
   ```
2. Open `Journal.xcodeproj` in Xcode 26+
3. Select your target device or simulator
4. Press **⌘R** to build and run

> **Widget setup:** To activate the home screen widget, enable the **App Groups** capability (`group.Sagar.Journal`) on both the `Journal` and `JournalWidget` targets in Xcode → Signing & Capabilities.

## Design Philosophy

- No login. No cloud. No noise.
- Everything stored locally on device.
- Fast to open, fast to write, fast to close.

## License

MIT

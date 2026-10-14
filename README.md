# ChatUIHelpers

Reusable SwiftUI components for building chat and messaging interfaces.

## Requirements

- Swift 6.2 or later
- iOS 17 or later
- macOS 14 or later

## Installation

Add the package to your project with Swift Package Manager:

```swift
dependencies: [
    .package(
        url: "https://github.com/winstondu/ChatUIHelpers",
        branch: "main"
    ),
]
```

Then add `ChatUIHelpers` to your target dependencies:

```swift
.target(
    name: "YourTarget",
    dependencies: ["ChatUIHelpers"]
)
```

## Usage

```swift
import ChatUIHelpers
import SwiftUI

struct MessageRow: View {
    let message: String
    let isCurrentUser: Bool

    var body: some View {
        ChatBubble(
            isFromCurrentUser: isCurrentUser,
            background: isCurrentUser ? .blue : .gray.opacity(0.2),
            tailRadius: 4
        ) {
            Text(message)
                .foregroundStyle(isCurrentUser ? .white : .primary)
        }
    }
}
```

## Included components

- Chat bubbles and custom bubble shapes
- Message composer controls, action buttons, and suggestion carousels
- Hold-to-talk and voice-recording interfaces
- Audio waveform views
- Context menus and deletable attachments
- Link previews, video thumbnails, file labels, and video playback
- Typing indicators, call-to-action messages, and request-state views

The package has no external dependencies.

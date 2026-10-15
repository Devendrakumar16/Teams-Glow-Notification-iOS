# TeamsGlow - Dynamic Notification & Glow Presentation Engine

Custom iOS presentation framework that triggers high-visibility glowing screen borders, queue-based alert handling, audio cues, and custom banner presentation for notifications.

---

## 🛠️ Tech Stack & Architecture
`SwiftUI` `UserNotifications` `AudioToolbox` `Queue Management` `Swift`

- **Platform:** iOS 16.0+
- **Language:** Swift 5.10+
- **Framework:** SwiftUI
- **Architecture:** MVVM / Clean Architecture

---

## ✨ Key Features
- Vibrant edge glow animation with customizable pulse frequencies and color palettes
- FIFO NotificationQueueManager ensuring sequential presentation without dropped alerts
- AudioToolbox integration for distinct auditory feedback
- User configurable settings manager for intensity, duration, and glow behavior

---

## 🚀 Getting Started

### Prerequisites
- macOS Sonoma or newer
- Xcode 15.0 or newer
- iOS Simulator or physical device running iOS 16+

### Installation
1. Clone the repository:
   ```bash
   git clone https://github.com/Devendrakumar16/Teams-Glow-Notification-iOS.git
   cd Teams-Glow-Notification-iOS
   ```
2. Open the project in Xcode:
   ```bash
   open *.xcodeproj 2>/dev/null || open *.xcworkspace
   ```
3. If CocoaPods is used:
   ```bash
   pod install
   open *.xcworkspace
   ```
4. Select your target simulator (e.g., iPhone 15 Pro) and press `Cmd + R` to build and run!

---

## 👨‍💻 Author
- **Devendra Kumar** ([@Devendrakumar16](https://github.com/Devendrakumar16))

---

## 📄 License
This project is open source and available under the [MIT License](LICENSE).

# OnAirMode 🎙️

**Never be interrupted during important calls again!**

OnAirMode is a smart macOS status bar application that automatically enables Do Not Disturb mode whenever your microphone is active. Perfect for remote workers, content creators, and anyone who values uninterrupted focus during calls and recordings.

## ✨ Features

### 🎯 **Automatic Do Not Disturb**
- Instantly activates Do Not Disturb when your microphone turns on
- Automatically disables when you stop speaking or end calls
- Works with any application: Zoom, Teams, Discord, OBS, Podcasting apps, and more

### 🔍 **Real-time Microphone Monitoring**
- Uses advanced CoreAudio APIs for precise microphone detection
- Monitors all audio input devices simultaneously
- Lightweight background operation with minimal system impact

### 🎨 **Clean Status Bar Integration**
- Beautiful SVG icons that adapt to light/dark mode
- Visual indicators show monitoring status at a glance
- Unobtrusive design that fits perfectly in your menu bar

### 🛡️ **Privacy-First Design**
- No data collection or external connections
- All processing happens locally on your Mac
- Respects system permissions and user privacy

## 🚀 Quick Start

### Installation

#### Option 1: Download Pre-built Release
1. Download the latest `OnAirMode.dmg` from [GitHub Releases](../../releases)
2. Open the DMG and drag OnAirMode to Applications
3. Launch OnAirMode from Applications
4. Grant microphone permissions when prompted
5. Install the included shortcut when prompted
6. You're ready to go!

#### Option 2: Build from Source
1. Clone this repository: `git clone <repository-url>`
2. Navigate to the project directory: `cd mic`
3. Run the build script: `./build.sh`
4. The DMG will be created at `build/OnAirMode.dmg`
5. Install following the steps above

**Requirements for building:**
- Xcode Command Line Tools
- macOS 10.15 or later

### How It Works
1. **Start Monitoring**: Click the status bar icon and select "Start Monitoring"
2. **Automatic Protection**: When you speak or join a call, Do Not Disturb activates instantly
3. **Stay Focused**: No notifications, calls, or interruptions while your mic is active
4. **Seamless Return**: Do Not Disturb automatically turns off when you're done

## 💼 Perfect For

### 📞 **Remote Workers**
- Never miss important points in meetings due to notification interruptions
- Maintain professional appearance during video calls
- Automatic protection for ad-hoc calls and impromptu meetings

### 🎬 **Content Creators**
- Record podcasts without notification sounds ruining takes
- Stream without embarrassing popup interruptions
- Focus on content creation without digital distractions

### 🏢 **Professionals**
- Uninterrupted client calls and presentations
- Important interview recordings stay clean
- Focused deep work sessions while using voice commands

### 🎓 **Students & Educators**
- Clean online class recordings
- Distraction-free virtual presentations
- Professional appearance during online exams

## 📋 Requirements

- macOS 10.15 (Catalina) or later
- Microphone access permission
- Shortcuts app (included with macOS)

## 🤝 Contributing

OnAirMode is built with clean, modular Swift code. The architecture includes:

- `AudioMonitor.swift` - CoreAudio microphone detection
- `ShortcutManager.swift` - Shortcuts integration and DND control
- `StatusBarManager.swift` - Menu bar UI and icon management
- `PermissionManager.swift` - System permissions handling
- `OnAirMode.swift` - Main application coordinator

## 📄 License

This project is open source. Feel free to use, modify, and distribute according to the license terms.

---

**Transform your Mac into a professional communication hub. Download OnAirMode today and never be interrupted during important moments again!**

*Built with ❤️ for the remote work revolution*
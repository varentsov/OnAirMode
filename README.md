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

### ⚡ **Smart Auto-Recovery**
- Automatically detects and installs required shortcuts
- Self-healing: recovers if shortcuts are accidentally removed
- Intelligent periodic checking with optimized intervals

### 🛡️ **Privacy-First Design**
- No data collection or external connections
- All processing happens locally on your Mac
- Respects system permissions and user privacy

## 🚀 Quick Start

### Installation
1. Download the latest release
2. Open `OnAirMode.app`
3. Grant microphone permissions when prompted
4. Install the included shortcut when prompted
5. You're ready to go!

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

## 🔧 Technical Excellence

### Modern Architecture
- Modular Swift codebase with clear separation of concerns
- Efficient CoreAudio integration for precise hardware monitoring
- Native macOS Shortcuts integration for system-level control

### Resource Efficient
- Minimal CPU usage (< 1% during monitoring)
- Tiny memory footprint (< 10MB RAM)
- Battery-friendly background operation

### Reliable Operation
- Robust error handling and auto-recovery
- Handles system sleep/wake cycles gracefully
- Continues working after system updates

## 📋 Requirements

- macOS 10.15 (Catalina) or later
- Microphone access permission
- Shortcuts app (included with macOS)

## 🎛️ Advanced Features

### Intelligent Shortcut Management
- Automatic shortcut detection and installation
- Self-repairing if shortcuts are modified or deleted
- Seamless updates without manual intervention

### Flexible Icon System
- SVG-based icons for crisp display at any resolution
- Automatic light/dark mode adaptation
- Fallback emoji icons for maximum compatibility

### Smart Monitoring
- Configurable sensitivity for different microphone types
- Works with USB, Bluetooth, and built-in microphones
- Handles multiple audio input devices intelligently

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
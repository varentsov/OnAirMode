import Cocoa
import AVFoundation
import CoreAudio
import UserNotifications

class MicMonitor: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem?
    private var timer: Timer?
    private var isMonitoring = false
    private var isDNDEnabled = false
    private var isShortcutAvailable = false
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        setupStatusBar()
        requestMicrophonePermission()
        checkAndInstallShortcut()
        startMonitoring()
    }
    
    private func setupStatusBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        updateStatusBarIcon()
        
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Start Monitoring", action: #selector(toggleMonitoring), keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(quit), keyEquivalent: "q"))
        
        statusItem?.menu = menu
    }
    
    private func requestMicrophonePermission() {
        let status = AVCaptureDevice.authorizationStatus(for: .audio)
        
        switch status {
        case .authorized:
            print("Microphone permission already granted")
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .audio) { granted in
                DispatchQueue.main.async {
                    if granted {
                        print("Microphone permission granted")
                    } else {
                        print("Microphone permission denied")
                        self.showPermissionAlert()
                    }
                }
            }
        case .denied, .restricted:
            showPermissionAlert()
        @unknown default:
            showPermissionAlert()
        }
    }
    
    private func showPermissionAlert() {
        let alert = NSAlert()
        alert.messageText = "Microphone Permission Required"
        alert.informativeText = "This app needs microphone access to monitor mic status. Please grant permission in System Preferences > Security & Privacy > Microphone."
        alert.alertStyle = .warning
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
    
    @objc private func toggleMonitoring() {
        if isMonitoring {
            stopMonitoring()
        } else {
            startMonitoring()
        }
    }
    
    private func startMonitoring() {
        isMonitoring = true
        statusItem?.menu?.item(at: 0)?.title = "Stop Monitoring"
        updateStatusBarIcon()
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.checkMicrophoneStatus()
        }
    }
    
    private func stopMonitoring() {
        isMonitoring = false
        timer?.invalidate()
        timer = nil
        statusItem?.menu?.item(at: 0)?.title = "Start Monitoring"
        updateStatusBarIcon()
        
        if isDNDEnabled {
            toggleDoNotDisturb(enable: false)
        }
    }
    
    private func checkMicrophoneStatus() {
        let isMicActive = isMicrophoneActive()
        
        if isMicActive && !isDNDEnabled {
            toggleDoNotDisturb(enable: true)
            updateStatusBarIcon()
        } else if !isMicActive && isDNDEnabled {
            toggleDoNotDisturb(enable: false)
            updateStatusBarIcon()
        }
    }
    
    private func isMicrophoneActive() -> Bool {
        var propertyAddress = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyDefaultInputDevice,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )
        
        var deviceID: AudioDeviceID = 0
        var propertySize = UInt32(MemoryLayout<AudioDeviceID>.size)
        
        let status = AudioObjectGetPropertyData(
            AudioObjectID(kAudioObjectSystemObject),
            &propertyAddress,
            0,
            nil,
            &propertySize,
            &deviceID
        )
        
        guard status == noErr && deviceID != kAudioObjectUnknown else {
            return false
        }
        
        propertyAddress.mSelector = kAudioDevicePropertyDeviceIsRunningSomewhere
        var isRunning: UInt32 = 0
        propertySize = UInt32(MemoryLayout<UInt32>.size)
        
        let runningStatus = AudioObjectGetPropertyData(
            deviceID,
            &propertyAddress,
            0,
            nil,
            &propertySize,
            &isRunning
        )
        
        return runningStatus == noErr && isRunning != 0
    }
    
    private func toggleDoNotDisturb(enable: Bool) {
        let task = Process()
        task.launchPath = "/usr/bin/shortcuts"
        
        // Create temporary file with input text
        let inputText = enable ? "on" : "off"
        let tempDir = FileManager.default.temporaryDirectory
        let inputFile = tempDir.appendingPathComponent("shortcut_input.txt")
        
        do {
            try inputText.write(to: inputFile, atomically: true, encoding: .utf8)
            
            task.arguments = ["run", "macos-focus-control", "--input-path", inputFile.path]
            
            try task.run()
            task.waitUntilExit()
            
            // Clean up temp file
            try? FileManager.default.removeItem(at: inputFile)
            
            if task.terminationStatus == 0 {
                isDNDEnabled = enable
                print("Do Not Disturb \(enable ? "enabled" : "disabled") via macos-focus-control shortcut")
            } else {
                print("Failed to toggle Do Not Disturb - shortcut may not be installed")
            }
        } catch {
            print("Error running shortcuts command: \(error)")
            // Clean up temp file in case of error
            try? FileManager.default.removeItem(at: inputFile)
        }
    }
    
    private func updateStatusBarIcon() {
        if !isMonitoring {
            // Use gray icon when not monitoring
            if let grayIcon = loadIcon(named: "icon_gray") {
                grayIcon.size = NSSize(width: 20, height: 20)
                statusItem?.button?.image = grayIcon
                statusItem?.button?.title = ""
                print("Set gray icon")
            } else {
                // Fallback to emoji if icon loading fails
                statusItem?.button?.title = "🎙️"
                statusItem?.button?.image = nil
                print("Failed to load gray icon, using emoji fallback")
            }
        } else {
            // Use template image (white/black) that adapts automatically
            if let templateIcon = loadIcon(named: "icon_black") {
                templateIcon.isTemplate = true
                templateIcon.size = NSSize(width: 20, height: 20)
                statusItem?.button?.image = templateIcon
                statusItem?.button?.title = ""
                print("Set template icon")
            } else {
                // Fallback to emoji if icon loading fails
                statusItem?.button?.title = "🎤"
                statusItem?.button?.image = nil
                print("Failed to load template icon, using emoji fallback")
            }
        }
    }
    
    private func loadIcon(named filename: String) -> NSImage? {
        guard let executablePath = Bundle.main.executablePath else {
            print("Failed to get executable path")
            return nil
        }
        
        var possiblePaths = [String]()
        
        // Path 1: App bundle structure (when using open command)
        let macosPath = (executablePath as NSString).deletingLastPathComponent
        let contentsPath = (macosPath as NSString).deletingLastPathComponent
        let resourcesPath = "\(contentsPath)/Resources"
        possiblePaths.append("\(resourcesPath)/assets/\(filename).svg")
        
        // Path 2: Direct execution from build directory
        let buildPath = (executablePath as NSString).deletingLastPathComponent
        possiblePaths.append("\(buildPath)/../assets/\(filename).svg")
        
        // Path 3: Working directory relative path
        let currentDir = FileManager.default.currentDirectoryPath
        possiblePaths.append("\(currentDir)/assets/\(filename).svg")
        
        for iconPath in possiblePaths {
            print("Trying to load icon from: \(iconPath)")
            
            guard FileManager.default.fileExists(atPath: iconPath) else {
                print("Icon file does not exist at path: \(iconPath)")
                continue
            }
            
            guard let svgData = NSData(contentsOfFile: iconPath) else { 
                print("Failed to read SVG data from: \(iconPath)")
                continue
            }
            
            guard let image = NSImage(data: svgData as Data) else {
                print("Failed to create NSImage from SVG data")
                continue
            }
            
            print("Successfully loaded icon: \(filename) from \(iconPath)")
            return image
        }
        
        print("Failed to load icon \(filename) from any path")
        return nil
    }
    
    private func checkAndInstallShortcut() {
        print("=== CHECKING SHORTCUT INSTALLATION ===")
        
        // Check if shortcut already exists
        let task = Process()
        task.launchPath = "/usr/bin/shortcuts"
        task.arguments = ["list"]
        
        let pipe = Pipe()
        task.standardOutput = pipe
        
        do {
            try task.run()
            task.waitUntilExit()
            
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let output = String(data: data, encoding: .utf8) ?? ""
            
            print("Shortcuts command output: \(output)")
            
            let shortcuts = output.components(separatedBy: .newlines)
            if shortcuts.contains("macos-focus-control") {
                print("✅ Shortcut 'macos-focus-control' already installed")
                return
            } else {
                print("❌ Shortcut 'macos-focus-control' NOT found")
                print("Available shortcuts: \(shortcuts.filter { !$0.isEmpty })")
            }
        } catch {
            print("❌ Error checking shortcuts: \(error)")
        }
        
        // Install shortcut from bundle
        print("Attempting to install shortcut from bundle...")
        installShortcutFromBundle()
    }
    
    private func installShortcutFromBundle() {
        print("=== INSTALLING SHORTCUT FROM BUNDLE ===")
        
        guard let resourcePath = Bundle.main.resourcePath else {
            print("❌ Could not find app resource path")
            return
        }
        
        print("App resource path: \(resourcePath)")
        
        let shortcutPath = "\(resourcePath)/macos-focus-control.shortcut"
        print("Looking for shortcut at: \(shortcutPath)")
        
        guard FileManager.default.fileExists(atPath: shortcutPath) else {
            print("❌ Shortcut file not found in app bundle")
            
            // List what's actually in the Resources directory
            do {
                let contents = try FileManager.default.contentsOfDirectory(atPath: resourcePath)
                print("Contents of Resources directory: \(contents)")
            } catch {
                print("Could not list Resources directory: \(error)")
            }
            return
        }
        
        print("✅ Found shortcut file in bundle")
        
        // Copy to temp location and open
        let tempPath = "/tmp/macos-focus-control.shortcut"
        
        do {
            if FileManager.default.fileExists(atPath: tempPath) {
                try FileManager.default.removeItem(atPath: tempPath)
            }
            try FileManager.default.copyItem(atPath: shortcutPath, toPath: tempPath)
            
            print("✅ Copied shortcut to temp location: \(tempPath)")
            
            // Open shortcut for installation
            let workspace = NSWorkspace.shared
            workspace.open(URL(fileURLWithPath: tempPath))
            
            print("🚀 Shortcut installation initiated - please approve in Shortcuts app")
            
            // Clean up after delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                try? FileManager.default.removeItem(atPath: tempPath)
                print("🧹 Cleaned up temp shortcut file")
            }
        } catch {
            print("❌ Error installing shortcut: \(error)")
        }
    }
    
    @objc private func quit() {
        if isDNDEnabled {
            toggleDoNotDisturb(enable: false)
        }
        NSApplication.shared.terminate(self)
    }
}

let app = NSApplication.shared
let delegate = MicMonitor()
app.delegate = delegate
app.run()
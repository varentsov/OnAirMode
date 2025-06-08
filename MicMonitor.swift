import Cocoa
import AVFoundation
import CoreAudio
import UserNotifications

class MicMonitor: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem?
    private var timer: Timer?
    private var isMonitoring = false
    private var isDNDEnabled = false
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        setupStatusBar()
        requestMicrophonePermission()
    }
    
    private func setupStatusBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem?.button?.title = "🎤"
        
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
        statusItem?.button?.title = "🎤🟢"
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.checkMicrophoneStatus()
        }
    }
    
    private func stopMonitoring() {
        isMonitoring = false
        timer?.invalidate()
        timer = nil
        statusItem?.menu?.item(at: 0)?.title = "Start Monitoring"
        statusItem?.button?.title = "🎤"
        
        if isDNDEnabled {
            toggleDoNotDisturb(enable: false)
        }
    }
    
    private func checkMicrophoneStatus() {
        let isMicActive = isMicrophoneActive()
        
        if isMicActive && !isDNDEnabled {
            toggleDoNotDisturb(enable: true)
            statusItem?.button?.title = "🎤🔴"
        } else if !isMicActive && isDNDEnabled {
            toggleDoNotDisturb(enable: false)
            statusItem?.button?.title = "🎤🟢"
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
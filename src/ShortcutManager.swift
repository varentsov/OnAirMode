import Foundation
import Cocoa

class ShortcutManager {
    private(set) var isShortcutAvailable = false
    private var shortcutCheckTimer: Timer?
    private var shortcutCheckCount = 0
    
    var onShortcutAvailabilityChanged: ((Bool) -> Void)?
    
    func checkAndInstallShortcut() {
        isShortcutAvailable = checkShortcutExists()
        if !isShortcutAvailable {
            installShortcutFromBundle()
        }
    }
    
    func checkShortcutExists() -> Bool {
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
            return output.components(separatedBy: .newlines).contains("macos-focus-control")
        } catch {
            return false
        }
    }
    
    func toggleDoNotDisturb(enable: Bool) -> Bool {
        guard isShortcutAvailable else { return false }
        
        let task = Process()
        task.launchPath = "/usr/bin/shortcuts"
        
        let inputText = enable ? "on" : "off"
        let tempDir = FileManager.default.temporaryDirectory
        let inputFile = tempDir.appendingPathComponent("shortcut_input.txt")
        
        do {
            try inputText.write(to: inputFile, atomically: true, encoding: .utf8)
            
            task.arguments = ["run", "macos-focus-control", "--input-path", inputFile.path]
            
            try task.run()
            task.waitUntilExit()
            
            try? FileManager.default.removeItem(at: inputFile)
            
            if task.terminationStatus != 0 {
                recheckShortcutAvailability()
                return false
            }
            
            return true
        } catch {
            try? FileManager.default.removeItem(at: inputFile)
            recheckShortcutAvailability()
            return false
        }
    }
    
    func startPeriodicShortcutCheck() {
        guard !isShortcutAvailable else { return }
        
        shortcutCheckCount = 0
        shortcutCheckTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.periodicShortcutCheck()
        }
    }
    
    func stopPeriodicShortcutCheck() {
        shortcutCheckTimer?.invalidate()
        shortcutCheckTimer = nil
        shortcutCheckCount = 0
    }
    
    private func installShortcutFromBundle() {
        guard let resourcePath = Bundle.main.resourcePath else { return }
        
        let shortcutPath = "\(resourcePath)/macos-focus-control.shortcut"
        guard FileManager.default.fileExists(atPath: shortcutPath) else { return }
        
        let tempPath = "/tmp/macos-focus-control.shortcut"
        
        do {
            if FileManager.default.fileExists(atPath: tempPath) {
                try FileManager.default.removeItem(atPath: tempPath)
            }
            try FileManager.default.copyItem(atPath: shortcutPath, toPath: tempPath)
            
            NSWorkspace.shared.open(URL(fileURLWithPath: tempPath))
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                try? FileManager.default.removeItem(atPath: tempPath)
            }
        } catch {
            return
        }
    }
    
    private func periodicShortcutCheck() {
        shortcutCheckCount += 1
        
        if shortcutCheckCount == 30 {
            shortcutCheckTimer?.invalidate()
            shortcutCheckTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
                self.periodicShortcutCheck()
            }
        }
        
        let wasAvailable = isShortcutAvailable
        isShortcutAvailable = checkShortcutExists()
        
        if isShortcutAvailable != wasAvailable {
            onShortcutAvailabilityChanged?(isShortcutAvailable)
            
            if isShortcutAvailable {
                stopPeriodicShortcutCheck()
            }
        }
    }
    
    private func recheckShortcutAvailability() {
        let wasAvailable = isShortcutAvailable
        isShortcutAvailable = checkShortcutExists()
        
        if isShortcutAvailable != wasAvailable {
            onShortcutAvailabilityChanged?(isShortcutAvailable)
        }
    }
}
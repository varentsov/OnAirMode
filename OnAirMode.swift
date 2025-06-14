import Cocoa

class MicMonitor: NSObject, NSApplicationDelegate {
    private var timer: Timer?
    private var isMonitoring = false
    private var isDNDEnabled = false
    
    private let audioMonitor = AudioMonitor()
    private let shortcutManager = ShortcutManager()
    private let statusBarManager = StatusBarManager()
    private let permissionManager = PermissionManager()
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        setupDelegates()
        statusBarManager.setupStatusBar()
        permissionManager.requestMicrophonePermission()
        shortcutManager.checkAndInstallShortcut()
        updateMenuItems()
        
        if shortcutManager.isShortcutAvailable {
            startMonitoring()
        } else {
            shortcutManager.startPeriodicShortcutCheck()
        }
    }
    
    private func setupDelegates() {
        statusBarManager.onToggleMonitoring = { [weak self] in
            self?.toggleMonitoring()
        }
        
        statusBarManager.onQuit = { [weak self] in
            self?.quit()
        }
        
        shortcutManager.onShortcutAvailabilityChanged = { [weak self] isAvailable in
            self?.handleShortcutAvailabilityChanged(isAvailable)
        }
    }
    
    private func toggleMonitoring() {
        if !shortcutManager.isShortcutAvailable {
            permissionManager.showShortcutMissingAlert()
            return
        }
        
        if isMonitoring {
            stopMonitoring()
        } else {
            startMonitoring()
        }
    }
    
    private func startMonitoring() {
        isMonitoring = true
        updateMenuItems()
        statusBarManager.updateStatusBarIcon(isMonitoring: true)
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.checkMicrophoneStatus()
        }
    }
    
    private func stopMonitoring() {
        isMonitoring = false
        timer?.invalidate()
        timer = nil
        updateMenuItems()
        statusBarManager.updateStatusBarIcon(isMonitoring: false)
        
        if isDNDEnabled {
            toggleDoNotDisturb(enable: false)
        }
    }
    
    private func checkMicrophoneStatus() {
        let isMicActive = audioMonitor.isMicrophoneActive()
        
        if isMicActive && !isDNDEnabled {
            toggleDoNotDisturb(enable: true)
            statusBarManager.updateStatusBarIcon(isMonitoring: true)
        } else if !isMicActive && isDNDEnabled {
            toggleDoNotDisturb(enable: false)
            statusBarManager.updateStatusBarIcon(isMonitoring: true)
        }
    }
    
    private func toggleDoNotDisturb(enable: Bool) {
        if shortcutManager.toggleDoNotDisturb(enable: enable) {
            isDNDEnabled = enable
        }
    }
    
    private func updateMenuItems() {
        statusBarManager.updateMenuItems(
            isShortcutAvailable: shortcutManager.isShortcutAvailable,
            isMonitoring: isMonitoring
        )
    }
    
    private func handleShortcutAvailabilityChanged(_ isAvailable: Bool) {
        updateMenuItems()
        
        if isAvailable && !isMonitoring {
            startMonitoring()
        }
    }
    
    @objc private func quit() {
        if isDNDEnabled {
            toggleDoNotDisturb(enable: false)
        }
        shortcutManager.stopPeriodicShortcutCheck()
        NSApplication.shared.terminate(self)
    }
}

@main
struct OnAirModeApp {
    static func main() {
        let app = NSApplication.shared
        let delegate = MicMonitor()
        app.delegate = delegate
        app.run()
    }
}
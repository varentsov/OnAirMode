import Cocoa
import ServiceManagement

class LaunchAtLoginManager {
    private let launchAtLoginKey = "LaunchAtLogin"
    
    var isEnabled: Bool {
        get {
            return UserDefaults.standard.bool(forKey: launchAtLoginKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: launchAtLoginKey)
            setLaunchAtLogin(enabled: newValue)
        }
    }
    
    private func setLaunchAtLogin(enabled: Bool) {
        guard let bundleIdentifier = Bundle.main.bundleIdentifier else {
            print("Could not get bundle identifier")
            return
        }
        
        if #available(macOS 13.0, *) {
            // Use new ServiceManagement API for macOS 13+
            do {
                if enabled {
                    try SMAppService.mainApp.register()
                } else {
                    try SMAppService.mainApp.unregister()
                }
            } catch {
                print("Failed to \(enabled ? "enable" : "disable") launch at login: \(error)")
            }
        } else {
            // Fallback for older macOS versions
            let success = SMLoginItemSetEnabled(bundleIdentifier as CFString, enabled)
            if !success {
                print("Failed to \(enabled ? "enable" : "disable") launch at login")
            }
        }
    }
    
    func initialize() {
        // Ensure the saved preference is applied on first launch
        if UserDefaults.standard.object(forKey: launchAtLoginKey) != nil {
            setLaunchAtLogin(enabled: isEnabled)
        }
    }
}
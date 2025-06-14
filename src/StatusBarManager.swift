import Cocoa

class StatusBarManager {
    private var statusItem: NSStatusItem?
    
    var onToggleMonitoring: (() -> Void)?
    var onQuit: (() -> Void)?
    
    func setupStatusBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        updateStatusBarIcon(isMonitoring: false)
        
        let menu = NSMenu()
        
        let monitoringItem = NSMenuItem(title: "Start Monitoring", action: #selector(toggleMonitoring), keyEquivalent: "")
        monitoringItem.target = self
        menu.addItem(monitoringItem)
        
        menu.addItem(NSMenuItem.separator())
        
        let quitItem = NSMenuItem(title: "Quit", action: #selector(quit), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)
        
        statusItem?.menu = menu
    }
    
    func updateStatusBarIcon(isMonitoring: Bool) {
        let (iconName, fallbackEmoji) = isMonitoring ? ("icon_black", "🎤") : ("icon_gray", "🎙️")
        
        if let icon = loadIcon(named: iconName) {
            icon.size = NSSize(width: 20, height: 20)
            if isMonitoring { icon.isTemplate = true }
            statusItem?.button?.image = icon
            statusItem?.button?.title = ""
        } else {
            statusItem?.button?.title = fallbackEmoji
            statusItem?.button?.image = nil
        }
    }
    
    func updateMenuItems(isShortcutAvailable: Bool, isMonitoring: Bool) {
        guard let menu = statusItem?.menu else { return }
        
        if !isShortcutAvailable {
            menu.item(at: 0)?.title = "Shortcut Not Installed"
            menu.item(at: 0)?.isEnabled = false
        } else if isMonitoring {
            menu.item(at: 0)?.title = "Stop Monitoring"
            menu.item(at: 0)?.isEnabled = true
        } else {
            menu.item(at: 0)?.title = "Start Monitoring"
            menu.item(at: 0)?.isEnabled = true
        }
    }
    
    private func loadIcon(named filename: String) -> NSImage? {
        guard let executablePath = Bundle.main.executablePath else { return nil }
        
        let macosPath = (executablePath as NSString).deletingLastPathComponent
        let contentsPath = (macosPath as NSString).deletingLastPathComponent
        
        let possiblePaths = [
            "\(contentsPath)/Resources/assets/\(filename).svg",
            "\(macosPath)/../assets/\(filename).svg"
        ]
        
        for iconPath in possiblePaths {
            guard FileManager.default.fileExists(atPath: iconPath),
                  let svgData = NSData(contentsOfFile: iconPath),
                  let image = NSImage(data: svgData as Data) else { continue }
            return image
        }
        
        return nil
    }
    
    @objc private func toggleMonitoring() {
        onToggleMonitoring?()
    }
    
    @objc private func quit() {
        onQuit?()
    }
}
import SwiftUI
import AppKit

@main
struct MlRadioFmApp: App {
  @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
  
  var body: some Scene {
    Settings {
      EmptyView()
    }
  }
}

class AppDelegate: NSObject, NSApplicationDelegate {
  var statusItem: NSStatusItem?
  var popover: NSPopover?
  
  func applicationDidFinishLaunching(_ notification: Notification) {
    // Create status bar item
    statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    
    if let button = statusItem?.button {
      button.image = NSImage(systemSymbolName: "radio", accessibilityDescription: "MlRadioFm")
      button.target = self
      
      // Create menu with radio interface and quit option
      let menu = NSMenu()
      menu.addItem(NSMenuItem(title: "Show Radio", action: #selector(showRadio), keyEquivalent: "o"))
      menu.addItem(NSMenuItem.separator())
      menu.addItem(NSMenuItem(title: "Quit", action: #selector(quitApp), keyEquivalent: "q"))
      
      statusItem?.menu = menu
    }
    
    // Create popover
    popover = NSPopover()
    popover?.contentSize = NSSize(width: 280, height: 480)
    popover?.behavior = .transient
    popover?.contentViewController = NSHostingController(rootView: ContentView())
    
    // Hide dock icon
    NSApp.setActivationPolicy(.accessory)
    
    // Automatically show radio stations on launch
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
      self?.showRadio()
    }
  }
  
  @objc func showRadio() {
    if let button = statusItem?.button {
      if popover?.isShown == true {
        popover?.performClose(nil)
      } else {
        popover?.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
      }
    }
  }
  
  @objc func togglePopover() {
    showRadio()
  }
  
  @objc func quitApp() {
    NSApplication.shared.terminate(nil)
  }
}

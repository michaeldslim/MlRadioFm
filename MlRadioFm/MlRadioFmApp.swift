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
      menu.addItem(NSMenuItem(title: "MlRadioFm", action: #selector(showHelp), keyEquivalent: ""))
      menu.addItem(NSMenuItem.separator())
      menu.addItem(NSMenuItem(title: "Show Radio", action: #selector(showRadio), keyEquivalent: ""))
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
  }
  
  @objc func showHelp() {
    let alert = NSAlert()
    alert.messageText = "MlRadioFm"
    alert.informativeText = """
    🎵 Korean & US Radio Stations App 
    (Apple Silicon / Intel)
    
    How to use:
    • Click "Show Radio" to open channels
    • Use volume slider to adjust sound
    
    Radio streams provided by:
    • iHeart Radio (KISS FM, STAR, The New MiX)
    • Korean Broadcasting System (KBS)
    • Munhwa Broadcasting Corporation (MBC)
    • Seoul Broadcasting System (SBS)
    • Other Korean broadcasters
    
    All content is property of respective broadcasters.
    
    Version 1.0        
    Copyright © 2025 Michaeldslim
    All rights reserved
    """
    alert.addButton(withTitle: "OK")
    alert.runModal()
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

//
//  main.swift
//  PiMonitor
//
//  Custom entry point to set activation policy BEFORE SwiftUI initializes
//

import AppKit
import SwiftUI
import OSLog

private let logger = Logger(subsystem: "com.pi-monitor", category: "Main")

// Set activation policy FIRST, before any UI code runs
let showInDock = UserDefaults.standard.bool(forKey: "showInDock")
let policyResult = NSApplication.shared.setActivationPolicy(showInDock ? .regular : .accessory)
logger.info("Activation policy set to \(showInDock ? "regular" : "accessory"), result: \(policyResult)")

// Set app icon from bundle resources
func loadAppIcon() -> NSImage? {
    // Try 1: App bundle icns (when running as proper .app)
    if let icnsPath = Bundle.main.path(forResource: "AppIcon", ofType: "icns"),
       let icon = NSImage(contentsOfFile: icnsPath) {
        return icon
    }

    // Try 2: App bundle Resources folder (resource bundle inside .app)
    if let resourceURL = Bundle.main.resourceURL {
        let resourceBundle = resourceURL.appendingPathComponent("PiMonitor_PiMonitor.bundle")
        if let icon = loadIconFromAssets(in: resourceBundle) {
            return icon
        }
    }

    // Try 3: Bundle.module (SPM resource bundle for debug builds)
    if let icon = loadIconFromAssets(in: Bundle.module.bundleURL) {
        return icon
    }

    // Try 4: Next to executable (SPM debug builds)
    if let execURL = Bundle.main.executableURL {
        let execDir = execURL.deletingLastPathComponent()
        let bundleURL = execDir.appendingPathComponent("PiMonitor_PiMonitor.bundle")
        if let icon = loadIconFromAssets(in: bundleURL) {
            return icon
        }
    }

    return nil
}

func loadIconFromAssets(in bundleURL: URL) -> NSImage? {
    let iconSizes = ["icon_1024x1024.png", "icon_512x512.png", "icon_256x256.png", "icon_128x128.png"]

    for iconName in iconSizes {
        let iconPath = bundleURL
            .appendingPathComponent("Assets.xcassets")
            .appendingPathComponent("AppIcon.appiconset")
            .appendingPathComponent(iconName)

        if FileManager.default.fileExists(atPath: iconPath.path),
           let icon = NSImage(contentsOf: iconPath) {
            return icon
        }
    }
    return nil
}

if let icon = loadAppIcon() {
    NSApplication.shared.applicationIconImage = icon
}

// Now launch the SwiftUI app
PiMonitorApp.main()

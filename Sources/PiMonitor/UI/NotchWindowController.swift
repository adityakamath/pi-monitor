//
//  NotchWindowController.swift
//  PiIsland
//
//  Controls the window positioning and lifecycle
//

import AppKit
import Combine
import SwiftUI

class NotchWindowController: NSWindowController {
    let viewModel: NotchViewModel
    private var currentScreen: NSScreen
    private var cancellables = Set<AnyCancellable>()

    init(screen: NSScreen, sessionManager: SessionManager) {
        self.currentScreen = screen

        let windowFrame = Self.createWindowFrame(for: screen)

        // Create view model
        self.viewModel = NotchViewModel(
            sessionManager: sessionManager
        )

        // Create the window - now a regular window with title bar
        let regularWindow = NSWindow(
            contentRect: windowFrame,
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false
        )

        super.init(window: regularWindow)

        // Configure window
        regularWindow.title = "Pi Monitor"
        regularWindow.minSize = NSSize(width: 400, height: 300)
        regularWindow.isOpaque = true
        regularWindow.backgroundColor = NSColor.windowBackgroundColor
        regularWindow.isMovableByWindowBackground = true

        // Create the SwiftUI view
        let hostingController = NotchViewController(viewModel: viewModel)
        regularWindow.contentViewController = hostingController

        regularWindow.setFrame(windowFrame, display: true)
        regularWindow.center()

        // Make window key and activate
        regularWindow.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    // MARK: - Screen Updates

    /// Update the window for a new screen (less relevant for regular window)
    func updateForScreen(_ newScreen: NSScreen) {
        guard newScreen != currentScreen else { return }
        currentScreen = newScreen
        
        // For regular window, just ensure it's visible on the new screen
        if let window = window {
            let windowFrame = Self.createWindowFrame(for: newScreen)
            window.setFrame(windowFrame, display: true, animate: true)
        }
    }

    // MARK: - Geometry Helpers

    private static func createWindowFrame(for screen: NSScreen) -> NSRect {
        let screenFrame = screen.visibleFrame
        let windowWidth: CGFloat = 500
        let windowHeight: CGFloat = 600

        // Center the window on the screen
        return NSRect(
            x: screenFrame.origin.x + (screenFrame.width - windowWidth) / 2,
            y: screenFrame.origin.y + (screenFrame.height - windowHeight) / 2,
            width: windowWidth,
            height: windowHeight
        )
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - NotchViewController

class NotchViewController: NSHostingController<NotchView> {
    init(viewModel: NotchViewModel) {
        super.init(rootView: NotchView(viewModel: viewModel))
    }

    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.wantsLayer = true
        view.layer?.backgroundColor = .clear
    }
}

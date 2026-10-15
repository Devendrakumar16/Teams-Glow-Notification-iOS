//
//  WindowManager.swift
//  TeamsGlow
//
//  Created by TeamsGlow on 23/09/26.
//

import AppKit
import SwiftUI

// MARK: - Floating Panel

/// A custom `NSPanel` subclass configured as a floating, borderless, transparent overlay.
/// Designed for notification popups that appear above all other windows without stealing focus.
class FloatingPanel: NSPanel {
    
    override init(
        contentRect: NSRect,
        styleMask style: NSWindow.StyleMask,
        backing backingStoreType: NSWindow.BackingStoreType,
        defer flag: Bool
    ) {
        super.init(
            contentRect: contentRect,
            styleMask: [.borderless, .nonactivatingPanel, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        
        configurePanel()
    }
    
    private func configurePanel() {
        // Floating level — above normal windows but below screen savers
        level = .floating
        
        // Transparency
        isOpaque = false
        backgroundColor = .clear
        hasShadow = false
        
        // Behavior — don't steal focus
        isMovableByWindowBackground = false
        hidesOnDeactivate = false
        
        // Multi-space support
        collectionBehavior = [
            .canJoinAllSpaces,
            .fullScreenAuxiliary,
            .stationary,
            .ignoresCycle,
        ]
        
        // No title bar
        titleVisibility = .hidden
        titlebarAppearsTransparent = true
        styleMask.remove(.titled)
        
        // Allow mouse interaction but don't activate the app
        acceptsMouseMovedEvents = true
        ignoresMouseEvents = false
    }
    
    // Don't become key window (prevents stealing focus)
    override var canBecomeKey: Bool { false }
    override var canBecomeMain: Bool { false }
}

// MARK: - WindowManager

/// Creates and manages the floating notification panel.
final class WindowManager {
    
    private var panel: FloatingPanel?
    
    /// Creates a new floating panel centered on the current screen.
    /// - Parameter contentView: The SwiftUI view to host inside the panel.
    /// - Returns: The created `FloatingPanel`.
    @discardableResult
    func createNotificationPanel<Content: View>(with contentView: Content) -> FloatingPanel {
        // Dismiss any existing panel
        dismissPanel()
        
        // Determine the target screen (where the mouse cursor currently is)
        let targetScreen = currentScreen()
        let screenFrame = targetScreen.visibleFrame
        
        // Panel size
        let panelWidth: CGFloat = DesignConstants.Card.width + 40  // Extra padding for glow
        let panelHeight: CGFloat = 240
        
        // Center on screen
        let originX = screenFrame.midX - panelWidth / 2
        let originY = screenFrame.midY - panelHeight / 2
        
        let panelFrame = NSRect(
            x: originX,
            y: originY,
            width: panelWidth,
            height: panelHeight
        )
        
        let panel = FloatingPanel(
            contentRect: panelFrame,
            styleMask: [],
            backing: .buffered,
            defer: false
        )
        
        // Host the SwiftUI view
        let hostingView = NSHostingView(rootView: contentView)
        hostingView.frame = NSRect(x: 0, y: 0, width: panelWidth, height: panelHeight)
        panel.contentView = hostingView
        
        self.panel = panel
        return panel
    }
    
    /// Shows the panel with optional animation.
    func showPanel() {
        panel?.orderFrontRegardless()
    }
    
    /// Hides and releases the panel.
    func dismissPanel() {
        panel?.orderOut(nil)
        panel?.contentView = nil
        panel = nil
    }
    
    /// Updates the panel's content view.
    func updateContent<Content: View>(with contentView: Content) {
        guard let panel = panel else { return }
        let hostingView = NSHostingView(rootView: contentView)
        hostingView.frame = panel.contentView?.frame ?? .zero
        panel.contentView = hostingView
    }
    
    /// Returns the screen where the user's mouse cursor is currently located.
    private func currentScreen() -> NSScreen {
        let mouseLocation = NSEvent.mouseLocation
        
        // Find the screen containing the mouse
        for screen in NSScreen.screens {
            if screen.frame.contains(mouseLocation) {
                return screen
            }
        }
        
        // Fallback to main screen
        return NSScreen.main ?? NSScreen.screens.first!
    }
    
    /// Whether the panel is currently visible.
    var isPanelVisible: Bool {
        panel?.isVisible ?? false
    }
}

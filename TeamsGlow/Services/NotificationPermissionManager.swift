//
//  NotificationPermissionManager.swift
//  TeamsGlow
//
//  Created by TeamsGlow on 23/09/26.
//

import Foundation
import AppKit
import Combine

// MARK: - NotificationPermissionManager

/// Manages Accessibility permission status and guides the user through granting it.
@Observable
final class NotificationPermissionManager {
    
    /// Whether the app currently has Accessibility permission.
    private(set) var isAccessibilityGranted: Bool = false
    
    /// Whether Microsoft Teams is currently running.
    private(set) var isTeamsRunning: Bool = false
    
    private var permissionCheckTimer: Timer?
    
    init() {
        checkAccessibilityPermission()
        checkTeamsRunning()
    }
    
    deinit {
        permissionCheckTimer?.invalidate()
    }
    
    // MARK: - Accessibility Permission
    
    /// Checks the current Accessibility permission status.
    func checkAccessibilityPermission() {
        isAccessibilityGranted = AXIsProcessTrusted()
    }
    
    /// Prompts the user for Accessibility permission by showing the system dialog.
    /// Returns `true` if permission is already granted.
    @discardableResult
    func requestAccessibilityPermission() -> Bool {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue(): true] as CFDictionary
        let trusted = AXIsProcessTrustedWithOptions(options)
        isAccessibilityGranted = trusted
        return trusted
    }
    
    /// Opens System Settings directly to the Accessibility privacy pane.
    func openAccessibilitySettings() {
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") {
            NSWorkspace.shared.open(url)
        }
    }
    
    /// Starts polling for Accessibility permission changes.
    /// macOS doesn't provide a callback when Accessibility permission is toggled,
    /// so we poll every 2 seconds.
    func startMonitoringPermission() {
        permissionCheckTimer?.invalidate()
        permissionCheckTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            self?.checkAccessibilityPermission()
            self?.checkTeamsRunning()
        }
    }
    
    /// Stops polling for permission changes.
    func stopMonitoringPermission() {
        permissionCheckTimer?.invalidate()
        permissionCheckTimer = nil
    }
    
    // MARK: - Teams Detection
    
    /// Checks whether Microsoft Teams is currently running.
    func checkTeamsRunning() {
        let runningApps = NSWorkspace.shared.runningApplications
        isTeamsRunning = runningApps.contains { app in
            app.bundleIdentifier == DesignConstants.Teams.bundleIdNew ||
            app.bundleIdentifier == DesignConstants.Teams.bundleIdClassic
        }
    }
    
    /// Returns the PID of the running Teams process, if any.
    func getTeamsPID() -> pid_t? {
        let runningApps = NSWorkspace.shared.runningApplications
        return runningApps.first { app in
            app.bundleIdentifier == DesignConstants.Teams.bundleIdNew ||
            app.bundleIdentifier == DesignConstants.Teams.bundleIdClassic
        }?.processIdentifier
    }
    
    /// Returns the PID of the NotificationCenter process.
    func getNotificationCenterPID() -> pid_t? {
        let runningApps = NSWorkspace.shared.runningApplications
        return runningApps.first { app in
            app.bundleIdentifier == DesignConstants.Teams.notificationCenterBundleId
        }?.processIdentifier
    }
}

//
//  TeamsNotificationMonitor.swift
//  TeamsGlow
//
//  Created by TeamsGlow on 23/09/26.
//

import Foundation
import AppKit
import Combine

// MARK: - TeamsNotificationMonitor

/// Monitors macOS system notifications for Microsoft Teams banners using the Accessibility API.
///
/// This service observes the `NotificationCenter` system process (`com.apple.notificationcenterui`)
/// for newly created UI elements. When a notification banner appears, it walks the accessibility
/// tree to extract sender name, title, and message content, filtering for Teams-originated notifications.
///
/// **Requires:** Accessibility permission granted in System Settings → Privacy & Security → Accessibility.
@Observable
final class TeamsNotificationMonitor {
    
    /// Whether the monitor is actively observing.
    private(set) var isMonitoring: Bool = false
    
    /// The last error encountered, if any.
    private(set) var lastError: String?
    
    /// Publisher for new Teams notifications.
    let notificationPublisher = PassthroughSubject<TeamsNotification, Never>()
    
    // AXObserver and related state (not @Observable — internal implementation)
    private var axObserver: AXObserver?
    private var notificationCenterElement: AXUIElement?
    private var workspaceObservers: [NSObjectProtocol] = []
    private var recentNotificationKeys: [String: Date] = [:]
    private let deduplicationWindow: TimeInterval = 5.0  // seconds
    
    // Cleanup timer for old dedup entries
    private var cleanupTimer: Timer?
    
    init() {}
    
    deinit {
        stopMonitoring()
    }
    
    // MARK: - Public API
    
    /// Begins monitoring for Teams notifications.
    func startMonitoring() {
        guard !isMonitoring else { return }
        
        // Verify Accessibility permission
        guard AXIsProcessTrusted() else {
            lastError = "Accessibility permission not granted"
            return
        }
        
        lastError = nil
        setupNotificationCenterObserver()
        setupWorkspaceObservers()
        startCleanupTimer()
        isMonitoring = true
    }
    
    /// Stops monitoring for notifications.
    func stopMonitoring() {
        removeAXObserver()
        removeWorkspaceObservers()
        cleanupTimer?.invalidate()
        cleanupTimer = nil
        isMonitoring = false
    }
    
    /// Restarts the monitoring service (useful after permission changes or process restarts).
    func restart() {
        stopMonitoring()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.startMonitoring()
        }
    }
    
    // MARK: - AXObserver Setup
    
    private func setupNotificationCenterObserver() {
        // Find the NotificationCenter process
        guard let ncPID = findNotificationCenterPID() else {
            lastError = "Could not find NotificationCenter process"
            // Retry in a few seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { [weak self] in
                if self?.isMonitoring == false {
                    self?.setupNotificationCenterObserver()
                }
            }
            return
        }
        
        // Create AXUIElement for the NotificationCenter app
        let appElement = AXUIElementCreateApplication(ncPID)
        notificationCenterElement = appElement
        
        // Create AXObserver
        var observer: AXObserver?
        
        // We need to use a C function pointer for the callback.
        // Store `self` reference via the refcon pointer.
        let refcon = Unmanaged.passUnretained(self).toOpaque()
        
        let result = AXObserverCreate(
            ncPID,
            axObserverCallback,
            &observer
        )
        
        guard result == .success, let observer = observer else {
            lastError = "Failed to create AXObserver: \(result.rawValue)"
            return
        }
        
        self.axObserver = observer
        
        // Register for notifications on the app element
        let notifications: [String] = [
            kAXCreatedNotification,
            kAXUIElementDestroyedNotification,
            kAXValueChangedNotification,
            kAXLayoutChangedNotification,
        ]
        
        for notification in notifications {
            let addResult = AXObserverAddNotification(observer, appElement, notification as CFString, refcon)
            if addResult != .success && addResult != .notificationAlreadyRegistered {
                print("[TeamsNotificationMonitor] Failed to add notification \(notification): \(addResult.rawValue)")
            }
        }
        
        // Add the observer to the current run loop
        CFRunLoopAddSource(
            CFRunLoopGetCurrent(),
            AXObserverGetRunLoopSource(observer),
            .defaultMode
        )
        
        print("[TeamsNotificationMonitor] Started monitoring NotificationCenter (PID: \(ncPID))")
    }
    
    // MARK: - Workspace Observers
    
    /// Monitors workspace notifications for Teams app launch/quit and screen changes.
    private func setupWorkspaceObservers() {
        let workspace = NSWorkspace.shared
        let nc = workspace.notificationCenter
        
        // Monitor app launches — re-verify Teams is available
        let launchObserver = nc.addObserver(
            forName: NSWorkspace.didLaunchApplicationNotification,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            if let app = notification.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication,
               app.bundleIdentifier == DesignConstants.Teams.bundleIdNew ||
               app.bundleIdentifier == DesignConstants.Teams.bundleIdClassic {
                print("[TeamsNotificationMonitor] Teams launched")
                self?.lastError = nil
            }
        }
        workspaceObservers.append(launchObserver)
        
        // Monitor app terminations
        let terminateObserver = nc.addObserver(
            forName: NSWorkspace.didTerminateApplicationNotification,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            if let app = notification.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication {
                if app.bundleIdentifier == DesignConstants.Teams.notificationCenterBundleId {
                    // NotificationCenter process restarted — reconnect observer
                    print("[TeamsNotificationMonitor] NotificationCenter terminated, will reconnect...")
                    self?.removeAXObserver()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
                        self?.setupNotificationCenterObserver()
                    }
                }
            }
        }
        workspaceObservers.append(terminateObserver)
        
        // Also listen for distributed notifications from Teams (supplementary signal)
        let distCenter = DistributedNotificationCenter.default()
        let distObserver = distCenter.addObserver(
            forName: nil,
            object: nil,
            queue: .main
        ) { notification in
            // Filter for Teams-related distributed notifications
            let name = notification.name.rawValue
            if name.contains("teams") || name.contains("Teams") ||
               name.contains("microsoft") || name.contains("Microsoft") {
                print("[TeamsNotificationMonitor] Distributed notification: \(name)")
            }
        }
        workspaceObservers.append(distObserver)
    }
    
    // MARK: - AX Element Processing
    
    /// Called from the AXObserver callback when a new UI element is created.
    func handleAXNotification(element: AXUIElement, notificationName: CFString) {
        // We're interested in new elements being created (notification banners)
        let name = notificationName as String
        
        guard name == (kAXCreatedNotification as String) ||
              name == (kAXLayoutChangedNotification as String) ||
              name == (kAXValueChangedNotification as String) else {
            return
        }
        
        // Walk the accessibility tree to find notification content
        DispatchQueue.main.async { [weak self] in
            self?.extractNotificationContent(from: element)
        }
    }
    
    /// Walks the accessibility tree of a UI element to extract notification data.
    private func extractNotificationContent(from element: AXUIElement) {
        // Strategy: Walk the NotificationCenter's window hierarchy to find
        // notification banner elements. These typically contain:
        // - An application name (we filter for "Microsoft Teams")
        // - A title (sender name)
        // - A body (message preview)
        
        // First, try to get windows of the NotificationCenter
        guard let ncElement = notificationCenterElement else { return }
        
        var windowsValue: CFTypeRef?
        let windowResult = AXUIElementCopyAttributeValue(ncElement, kAXWindowsAttribute as CFString, &windowsValue)
        
        guard windowResult == .success,
              let windows = windowsValue as? [AXUIElement] else {
            // Try directly processing the element that triggered the notification
            processElement(element)
            return
        }
        
        // Process each window looking for notification content
        for window in windows {
            processElement(window)
        }
    }
    
    /// Recursively processes an AX element and its children to find notification text.
    private func processElement(_ element: AXUIElement) {
        var allTexts: [String] = []
        collectTexts(from: element, into: &allTexts, depth: 0, maxDepth: 8)
        
        // Try to identify Teams notifications from collected text
        identifyTeamsNotification(from: allTexts)
    }
    
    /// Recursively collects text values from an AX element tree.
    /// Only collects title and value — NOT role descriptions (those return AX metadata
    /// like "system dialogue", "scroll area", etc. which pollutes the output).
    private func collectTexts(from element: AXUIElement, into texts: inout [String], depth: Int, maxDepth: Int) {
        guard depth < maxDepth else { return }
        
        // Collect title, value, and description (which often contains the full text for VoiceOver).
        // Skip roleDescription as it returns AX metadata like "system dialogue".
        if let title = getAXAttribute(element, attribute: kAXTitleAttribute as CFString) as? String,
           !title.isEmpty {
            texts.append(title)
        }
        if let value = getAXAttribute(element, attribute: kAXValueAttribute as CFString) as? String,
           !value.isEmpty {
            texts.append(value)
        }
        if let desc = getAXAttribute(element, attribute: kAXDescriptionAttribute as CFString) as? String,
           !desc.isEmpty {
            texts.append(desc)
        }
        
        // Get children and recurse
        guard let children = getAXAttribute(element, attribute: kAXChildrenAttribute as CFString) as? [AXUIElement] else {
            return
        }
        
        for child in children {
            collectTexts(from: child, into: &texts, depth: depth + 1, maxDepth: maxDepth)
        }
    }
    
    /// Extracts an attribute value from an AXUIElement.
    private func getAXAttribute(_ element: AXUIElement, attribute: CFString) -> CFTypeRef? {
        var value: CFTypeRef?
        let result = AXUIElementCopyAttributeValue(element, attribute, &value)
        return result == .success ? value : nil
    }
    
    /// Identifies a Teams notification from a list of extracted text values.
    private func identifyTeamsNotification(from texts: [String]) {
        guard !texts.isEmpty else { return }
        
        // First, expand any comma-separated values.
        // macOS notification banners often combine fields as:
        // "Microsoft Teams, Adarsh Kumar, message text here"
        var expandedTexts: [String] = []
        for text in texts {
            if text.contains(",") {
                let parts = text.split(separator: ",").map { String($0).trimmingCharacters(in: .whitespaces) }
                expandedTexts.append(contentsOf: parts)
            } else {
                expandedTexts.append(text)
            }
        }
        
        // Check if this is a Teams notification
        let allText = expandedTexts.joined(separator: " ").lowercased()
        let isTeams = allText.contains("microsoft teams") ||
                      expandedTexts.contains(where: { $0 == "Microsoft Teams" || $0 == "Teams" })
        
        guard isTeams else { return }
        
        // Blocklist — filter out all AX metadata, UI element names, and system strings
        let blocklist: Set<String> = [
            "microsoft teams", "teams",
            "notification", "notifications", "notification center",
            "close", "close button", "options", "actions", "action",
            "banner", "alert", "group", "window",
            "button", "image", "icon", "text", "static text",
            "scroll area", "scroll bar", "list", "cell", "row",
            "system dialogue", "system dialog", "dialogue", "dialog",
            "open", "dismiss", "reply", "mark as read",
            "show", "hide", "expand", "collapse",
        ]
        
        let meaningfulTexts = expandedTexts.filter { text in
            let lower = text.lowercased().trimmingCharacters(in: .whitespaces)
            return !lower.isEmpty &&
                   !blocklist.contains(lower) &&
                   !lower.hasPrefix("notification ") &&
                   !lower.hasPrefix("alert ") &&
                   lower.count > 1
        }
        
        // Deduplicate while preserving order. AX trees often contain the same text
        // in multiple properties (e.g. title, value, and description).
        var uniqueTexts: [String] = []
        var seenTexts: Set<String> = []
        for text in meaningfulTexts {
            if !seenTexts.contains(text) {
                seenTexts.insert(text)
                uniqueTexts.append(text)
            }
        }
        
        // Parse sender and message from the unique texts.
        // After filtering, the order is typically: [SenderName], [MessagePreview], ...
        var senderName = "Unknown"
        var messagePreview = ""
        
        if uniqueTexts.count >= 2 {
            senderName = uniqueTexts[0]
            // Join remaining texts as the message (sometimes the message spans multiple AX elements)
            messagePreview = uniqueTexts.dropFirst().joined(separator: " ")
        } else if uniqueTexts.count == 1 {
            let text = uniqueTexts[0]
            // If the single text looks like it contains both sender and message
            // (e.g. "Adarsh Kumar: Hey check this"), try to split on colon
            if let colonRange = text.range(of: ": ") {
                senderName = String(text[text.startIndex..<colonRange.lowerBound])
                messagePreview = String(text[colonRange.upperBound...])
            } else {
                messagePreview = text
                senderName = "Teams"
            }
        } else {
            // No meaningful text found — skip this notification
            return
        }
        
        // Clean up
        senderName = senderName.trimmingCharacters(in: .whitespaces)
        messagePreview = messagePreview.trimmingCharacters(in: .whitespaces)
        
        // Skip if sender is still a system string
        let senderLower = senderName.lowercased()
        if blocklist.contains(senderLower) || senderName.isEmpty {
            return
        }
        
        // Truncate long messages
        if messagePreview.count > 200 {
            messagePreview = String(messagePreview.prefix(200)) + "..."
        }
        
        // If message is empty, use a generic placeholder
        if messagePreview.isEmpty {
            messagePreview = "New message"
        }
        
        // Deduplication check
        let dedupKey = "\(senderName)|\(messagePreview)"
        if let lastSeen = recentNotificationKeys[dedupKey],
           Date().timeIntervalSince(lastSeen) < deduplicationWindow {
            return
        }
        recentNotificationKeys[dedupKey] = Date()
        
        // Create and publish the notification
        let notification = TeamsNotification(
            senderName: senderName,
            messagePreview: messagePreview
        )
        
        print("[TeamsNotificationMonitor] Detected: \(senderName) — \(messagePreview)")
        notificationPublisher.send(notification)
    }
    
    // MARK: - Helpers
    
    private func findNotificationCenterPID() -> pid_t? {
        NSWorkspace.shared.runningApplications.first {
            $0.bundleIdentifier == DesignConstants.Teams.notificationCenterBundleId
        }?.processIdentifier
    }
    
    private func removeAXObserver() {
        if let observer = axObserver, let element = notificationCenterElement {
            AXObserverRemoveNotification(observer, element, kAXCreatedNotification as CFString)
            AXObserverRemoveNotification(observer, element, kAXUIElementDestroyedNotification as CFString)
            AXObserverRemoveNotification(observer, element, kAXValueChangedNotification as CFString)
            AXObserverRemoveNotification(observer, element, kAXLayoutChangedNotification as CFString)
            
            CFRunLoopRemoveSource(
                CFRunLoopGetCurrent(),
                AXObserverGetRunLoopSource(observer),
                .defaultMode
            )
        }
        axObserver = nil
        notificationCenterElement = nil
    }
    
    private func removeWorkspaceObservers() {
        for observer in workspaceObservers {
            NSWorkspace.shared.notificationCenter.removeObserver(observer)
            DistributedNotificationCenter.default().removeObserver(observer)
        }
        workspaceObservers.removeAll()
    }
    
    private func startCleanupTimer() {
        cleanupTimer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { [weak self] _ in
            self?.cleanupDeduplicationCache()
        }
    }
    
    private func cleanupDeduplicationCache() {
        let now = Date()
        recentNotificationKeys = recentNotificationKeys.filter { _, date in
            now.timeIntervalSince(date) < deduplicationWindow * 2
        }
    }
}

// MARK: - AXObserver C Callback

/// C-style callback function for AXObserver. Routes events back to the Swift class.
private func axObserverCallback(
    observer: AXObserver,
    element: AXUIElement,
    notificationName: CFString,
    userData: UnsafeMutableRawPointer?
) {
    guard let userData = userData else { return }
    let monitor = Unmanaged<TeamsNotificationMonitor>.fromOpaque(userData).takeUnretainedValue()
    monitor.handleAXNotification(element: element, notificationName: notificationName)
}


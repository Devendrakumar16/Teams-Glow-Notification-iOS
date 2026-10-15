//
//  TeamsGlowApp.swift
//  TeamsGlow
//
//  Created by Devendra Kumar on 23/09/26.
//

import SwiftUI
import Combine
import AppKit

// MARK: - App Entry Point

@main
struct TeamsGlowApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        // Menu bar extra — the primary UI surface
        MenuBarExtra {
            MenuBarView(
                settings: appDelegate.settingsManager.settings,
                monitor: appDelegate.monitor,
                permissionManager: appDelegate.permissionManager,
                queueManager: appDelegate.queueManager,
                onOpenSettings: { appDelegate.openSettings() },
                onTestNotification: { appDelegate.sendTestNotification() },
                onQuit: { NSApplication.shared.terminate(nil) }
            )
        } label: {
            Image(systemName: "bell.badge.fill")
                .symbolRenderingMode(.hierarchical)
        }
        
        // Settings window
        Window("TeamsGlow Settings", id: "settings") {
            SettingsView(
                settings: appDelegate.settingsManager.settings,
                permissionManager: appDelegate.permissionManager,
                settingsManager: appDelegate.settingsManager
            )
        }
        .windowResizability(.contentSize)
        .defaultPosition(.center)
    }
}

// MARK: - AppDelegate

/// Coordinates the lifecycle of all services, manages the notification pipeline,
/// and handles the onboarding window.
@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    
    // MARK: - Services & Managers
    
    let settingsManager = SettingsManager.shared
    let permissionManager = NotificationPermissionManager()
    let monitor = TeamsNotificationMonitor()
    lazy var queueManager = NotificationQueueManager(settings: settingsManager.settings)
    lazy var presentationManager = NotificationPresentationManager(settings: settingsManager.settings)
    
    private var cancellables = Set<AnyCancellable>()
    private var onboardingWindow: NSWindow?
    
    // MARK: - App Lifecycle
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Start permission monitoring
        permissionManager.startMonitoringPermission()
        
        // Show onboarding if needed
        if !settingsManager.settings.hasCompletedOnboarding {
            showOnboarding()
        } else {
            startMonitoringIfReady()
        }
        
        // Wire up the notification pipeline
        setupNotificationPipeline()
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        monitor.stopMonitoring()
        permissionManager.stopMonitoringPermission()
    }
    
    // MARK: - Notification Pipeline
    
    private func setupNotificationPipeline() {
        // Monitor → Queue
        monitor.notificationPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] notification in
                guard let self = self else { return }
                guard self.settingsManager.settings.isEnabled else { return }
                self.queueManager.enqueue(notification)
            }
            .store(in: &cancellables)
        
        // Queue → Presentation
        queueManager.presentNotification
            .receive(on: DispatchQueue.main)
            .sink { [weak self] notification in
                self?.presentationManager.showNotification(notification)
            }
            .store(in: &cancellables)
        
        // Queue dismiss → Presentation hide
        queueManager.dismissCurrent
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.presentationManager.hide()
            }
            .store(in: &cancellables)
        
        // Presentation callbacks
        presentationManager.onOpenTeams = { [weak self] notification in
            if self?.settingsManager.settings.openTeamsOnClick == true {
                TeamsLauncher.openTeams(conversationId: notification.conversationId)
            }
            self?.queueManager.dismissCurrentNotification()
        }
        
        presentationManager.onDismiss = { [weak self] in
            self?.queueManager.dismissCurrentNotification()
        }
    }
    
    // MARK: - Monitoring
    
    func startMonitoringIfReady() {
        guard permissionManager.isAccessibilityGranted else {
            print("[AppDelegate] Accessibility permission not granted, cannot start monitoring")
            return
        }
        
        if settingsManager.settings.isEnabled {
            monitor.startMonitoring()
        }
    }
    
    // MARK: - Onboarding
    
    func showOnboarding() {
        let onboardingView = OnboardingView(
            permissionManager: permissionManager
        ) { [weak self] in
            self?.settingsManager.settings.hasCompletedOnboarding = true
            self?.onboardingWindow?.close()
            self?.onboardingWindow = nil
            self?.startMonitoringIfReady()
        }
        
        let hostingView = NSHostingView(rootView: onboardingView)
        
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 520, height: 480),
            styleMask: [.titled, .closable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        window.contentView = hostingView
        window.titleVisibility = .hidden
        window.titlebarAppearsTransparent = true
        window.isMovableByWindowBackground = true
        window.center()
        window.makeKeyAndOrderFront(nil)
        window.level = .floating
        
        // Ensure the app is frontmost for the onboarding
        NSApplication.shared.activate(ignoringOtherApps: true)
        
        self.onboardingWindow = window
    }
    
    // MARK: - Settings Window
    
    func openSettings() {
        // Use the SwiftUI Window scene via its ID
        if let window = NSApp.windows.first(where: { $0.title.contains("Settings") }) {
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
        } else {
            // Open the settings window via the Window scene
            NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
            
            // Fallback: try to open via environment open window
            if #available(macOS 13.0, *) {
                for window in NSApp.windows {
                    if window.identifier?.rawValue.contains("settings") == true {
                        window.makeKeyAndOrderFront(nil)
                        NSApp.activate(ignoringOtherApps: true)
                        return
                    }
                }
            }
            
            // Last resort: create settings window manually
            showSettingsWindowManually()
        }
    }
    
    private func showSettingsWindowManually() {
        let settingsView = SettingsView(
            settings: settingsManager.settings,
            permissionManager: permissionManager,
            settingsManager: settingsManager
        )
        
        let hostingView = NSHostingView(rootView: settingsView)
        
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 480, height: 520),
            styleMask: [.titled, .closable, .miniaturizable],
            backing: .buffered,
            defer: false
        )
        window.contentView = hostingView
        window.title = "TeamsGlow Settings"
        window.center()
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    // MARK: - Test Notification
    
    func sendTestNotification() {
        let testNotification = TeamsNotification(
            senderName: "John Smith",
            title: "Microsoft Teams",
            messagePreview: "Hey! Can you review this document? I've made the changes we discussed in the meeting yesterday. 📄",
            conversationId: nil
        )
        queueManager.enqueue(testNotification)
    }
}

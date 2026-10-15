//
//  TeamsLauncher.swift
//  TeamsGlow
//
//  Created by TeamsGlow on 23/09/26.
//

import AppKit

// MARK: - TeamsLauncher

/// Handles launching Microsoft Teams and deep-linking to conversations.
struct TeamsLauncher {
    
    /// Opens Microsoft Teams, optionally navigating to a specific conversation.
    static func openTeams(conversationId: String? = nil) {
        // Try deep-linking first
        if let conversationId = conversationId,
           let url = URL(string: "\(DesignConstants.Teams.urlScheme)l/chat/\(conversationId)") {
            NSWorkspace.shared.open(url)
            return
        }
        
        // Fall back to opening the app directly
        if let teamsURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: DesignConstants.Teams.bundleIdNew) {
            NSWorkspace.shared.openApplication(at: teamsURL, configuration: .init()) { _, error in
                if let error = error {
                    print("[TeamsLauncher] Failed to open Teams (new): \(error.localizedDescription)")
                    // Try classic Teams
                    openClassicTeams()
                }
            }
        } else {
            openClassicTeams()
        }
    }
    
    /// Tries to open classic Microsoft Teams as a fallback.
    private static func openClassicTeams() {
        if let teamsURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: DesignConstants.Teams.bundleIdClassic) {
            NSWorkspace.shared.openApplication(at: teamsURL, configuration: .init()) { _, error in
                if let error = error {
                    print("[TeamsLauncher] Failed to open Teams (classic): \(error.localizedDescription)")
                }
            }
        } else {
            print("[TeamsLauncher] Microsoft Teams not found on this system")
        }
    }
    
    /// Activates (brings to front) Teams if it's already running.
    static func activateTeams() {
        let runningApps = NSWorkspace.shared.runningApplications
        let teamsApp = runningApps.first {
            $0.bundleIdentifier == DesignConstants.Teams.bundleIdNew ||
            $0.bundleIdentifier == DesignConstants.Teams.bundleIdClassic
        }
        
        if let app = teamsApp {
            app.activate()
        } else {
            openTeams()
        }
    }
    
    /// Returns whether Teams is currently running.
    static var isTeamsRunning: Bool {
        NSWorkspace.shared.runningApplications.contains {
            $0.bundleIdentifier == DesignConstants.Teams.bundleIdNew ||
            $0.bundleIdentifier == DesignConstants.Teams.bundleIdClassic
        }
    }
}

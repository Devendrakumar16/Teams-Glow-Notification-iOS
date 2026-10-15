//
//  SettingsManager.swift
//  TeamsGlow
//
//  Created by TeamsGlow on 23/09/26.
//

import Foundation
import ServiceManagement

// MARK: - SettingsManager

/// Centralized manager for application settings and launch-at-login behavior.
@Observable
final class SettingsManager {
    
    /// Shared singleton instance.
    static let shared = SettingsManager()
    
    /// The underlying settings model.
    let settings: NotificationSettings
    
    private init() {
        self.settings = NotificationSettings()
    }
    
    // MARK: - Launch at Login
    
    /// Registers or unregisters the app for login item status using SMAppService.
    func updateLaunchAtLogin(_ enabled: Bool) {
        settings.launchAtLogin = enabled
        
        if #available(macOS 13.0, *) {
            let service = SMAppService.mainApp
            do {
                if enabled {
                    try service.register()
                } else {
                    try service.unregister()
                }
            } catch {
                print("[SettingsManager] Failed to update launch-at-login: \(error.localizedDescription)")
            }
        }
    }
    
    /// Returns the current login item registration status.
    var isRegisteredForLogin: Bool {
        if #available(macOS 13.0, *) {
            return SMAppService.mainApp.status == .enabled
        }
        return false
    }
    
    // MARK: - Convenience
    
    /// Returns the configured animation for notification appearance.
    var appearAnimation: Animation {
        switch settings.animationStyle {
        case .spring:
            return .notificationAppear
        case .smooth:
            return .easeInOut(duration: DesignConstants.Timing.appearDuration)
        case .bouncy:
            return .bouncyAppear
        }
    }
    
    /// Returns the configured animation for notification dismissal.
    var dismissAnimation: Animation {
        return .notificationDismiss
    }
}

// MARK: - Animation Extension (for SettingsManager)

import SwiftUI

extension Animation {
    /// Smooth ease-in-out animation used by the "Smooth" animation style.
    static func smoothAppear(duration: Double = 0.5) -> Animation {
        .easeInOut(duration: duration)
    }
}

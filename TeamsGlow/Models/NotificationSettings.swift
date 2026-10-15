//
//  NotificationSettings.swift
//  TeamsGlow
//
//  Created by TeamsGlow on 23/09/26.
//

import Foundation
import SwiftUI

// MARK: - Animation Style

/// The animation style used for notification appearance/dismissal.
enum AnimationStyle: String, CaseIterable, Identifiable {
    case spring = "Spring"
    case smooth = "Smooth"
    case bouncy = "Bouncy"
    
    var id: String { rawValue }
    
    var displayName: String { rawValue }
    
    var icon: String {
        switch self {
        case .spring: return "wind"
        case .smooth: return "water.waves"
        case .bouncy: return "arrow.up.arrow.down"
        }
    }
}

// MARK: - Color Theme

/// The color theme for notification accents.
enum ColorTheme: String, CaseIterable, Identifiable {
    case teams = "Teams"
    case neon = "Neon"
    case subtle = "Subtle"
    case ocean = "Ocean"
    case sunset = "Sunset"
    
    var id: String { rawValue }
    
    var displayName: String { rawValue }
    
    var gradientColors: [Color] {
        switch self {
        case .teams:
            return [
                Color(red: 0.45, green: 0.27, blue: 0.85),  // Purple
                Color(red: 0.25, green: 0.47, blue: 0.95),  // Blue
                Color(red: 0.10, green: 0.75, blue: 0.85),  // Cyan
                Color(red: 0.85, green: 0.35, blue: 0.65),  // Pink
            ]
        case .neon:
            return [
                Color(red: 0.95, green: 0.15, blue: 0.55),  // Hot pink
                Color(red: 0.55, green: 0.10, blue: 0.95),  // Violet
                Color(red: 0.10, green: 0.85, blue: 0.95),  // Electric cyan
                Color(red: 0.15, green: 0.95, blue: 0.55),  // Neon green
            ]
        case .subtle:
            return [
                Color(red: 0.55, green: 0.55, blue: 0.65),  // Cool gray
                Color(red: 0.45, green: 0.50, blue: 0.70),  // Muted blue
                Color(red: 0.60, green: 0.50, blue: 0.65),  // Lavender
                Color(red: 0.50, green: 0.55, blue: 0.60),  // Slate
            ]
        case .ocean:
            return [
                Color(red: 0.05, green: 0.30, blue: 0.65),  // Deep blue
                Color(red: 0.10, green: 0.55, blue: 0.75),  // Ocean
                Color(red: 0.15, green: 0.75, blue: 0.70),  // Teal
                Color(red: 0.20, green: 0.85, blue: 0.85),  // Aqua
            ]
        case .sunset:
            return [
                Color(red: 0.95, green: 0.35, blue: 0.20),  // Orange
                Color(red: 0.90, green: 0.25, blue: 0.45),  // Rose
                Color(red: 0.75, green: 0.20, blue: 0.65),  // Magenta
                Color(red: 0.50, green: 0.25, blue: 0.80),  // Purple
            ]
        }
    }
    
    var primaryAccent: Color {
        gradientColors.first ?? .purple
    }
}

// MARK: - NotificationSettings

/// Observable settings model backed by UserDefaults.
@Observable
final class NotificationSettings {
    
    // MARK: General
    
    var isEnabled: Bool {
        didSet { UserDefaults.standard.set(isEnabled, forKey: Keys.isEnabled) }
    }
    
    var launchAtLogin: Bool {
        didSet { UserDefaults.standard.set(launchAtLogin, forKey: Keys.launchAtLogin) }
    }
    
    var notificationDuration: Double {
        didSet { UserDefaults.standard.set(notificationDuration, forKey: Keys.notificationDuration) }
    }
    
    var showOnCurrentDisplay: Bool {
        didSet { UserDefaults.standard.set(showOnCurrentDisplay, forKey: Keys.showOnCurrentDisplay) }
    }
    
    // MARK: Appearance
    
    var glassIntensity: Double {
        didSet { UserDefaults.standard.set(glassIntensity, forKey: Keys.glassIntensity) }
    }
    
    var animationStyle: AnimationStyle {
        didSet { UserDefaults.standard.set(animationStyle.rawValue, forKey: Keys.animationStyle) }
    }
    
    var glowIntensity: Double {
        didSet { UserDefaults.standard.set(glowIntensity, forKey: Keys.glowIntensity) }
    }
    
    var colorTheme: ColorTheme {
        didSet { UserDefaults.standard.set(colorTheme.rawValue, forKey: Keys.colorTheme) }
    }
    
    // MARK: Behavior
    
    var autoDismiss: Bool {
        didSet { UserDefaults.standard.set(autoDismiss, forKey: Keys.autoDismiss) }
    }
    
    var openTeamsOnClick: Bool {
        didSet { UserDefaults.standard.set(openTeamsOnClick, forKey: Keys.openTeamsOnClick) }
    }
    
    var playSound: Bool {
        didSet { UserDefaults.standard.set(playSound, forKey: Keys.playSound) }
    }
    
    // MARK: Onboarding
    
    var hasCompletedOnboarding: Bool {
        didSet { UserDefaults.standard.set(hasCompletedOnboarding, forKey: Keys.hasCompletedOnboarding) }
    }
    
    // MARK: Initialization
    
    init() {
        let defaults = UserDefaults.standard
        
        // Register defaults
        let defaultValues: [String: Any] = [
            Keys.isEnabled: true,
            Keys.launchAtLogin: false,
            Keys.notificationDuration: 6.0,
            Keys.showOnCurrentDisplay: true,
            Keys.glassIntensity: 0.7,
            Keys.animationStyle: AnimationStyle.spring.rawValue,
            Keys.glowIntensity: 0.6,
            Keys.colorTheme: ColorTheme.teams.rawValue,
            Keys.autoDismiss: true,
            Keys.openTeamsOnClick: true,
            Keys.playSound: true,
            Keys.hasCompletedOnboarding: false,
        ]
        defaults.register(defaults: defaultValues)
        
        // Load values
        self.isEnabled = defaults.bool(forKey: Keys.isEnabled)
        self.launchAtLogin = defaults.bool(forKey: Keys.launchAtLogin)
        self.notificationDuration = defaults.double(forKey: Keys.notificationDuration)
        self.showOnCurrentDisplay = defaults.bool(forKey: Keys.showOnCurrentDisplay)
        self.glassIntensity = defaults.double(forKey: Keys.glassIntensity)
        self.animationStyle = AnimationStyle(rawValue: defaults.string(forKey: Keys.animationStyle) ?? "") ?? .spring
        self.glowIntensity = defaults.double(forKey: Keys.glowIntensity)
        self.colorTheme = ColorTheme(rawValue: defaults.string(forKey: Keys.colorTheme) ?? "") ?? .teams
        self.autoDismiss = defaults.bool(forKey: Keys.autoDismiss)
        self.openTeamsOnClick = defaults.bool(forKey: Keys.openTeamsOnClick)
        self.playSound = defaults.bool(forKey: Keys.playSound)
        self.hasCompletedOnboarding = defaults.bool(forKey: Keys.hasCompletedOnboarding)
    }
    
    // MARK: - Keys
    
    private enum Keys {
        static let isEnabled = "tg_isEnabled"
        static let launchAtLogin = "tg_launchAtLogin"
        static let notificationDuration = "tg_notificationDuration"
        static let showOnCurrentDisplay = "tg_showOnCurrentDisplay"
        static let glassIntensity = "tg_glassIntensity"
        static let animationStyle = "tg_animationStyle"
        static let glowIntensity = "tg_glowIntensity"
        static let colorTheme = "tg_colorTheme"
        static let autoDismiss = "tg_autoDismiss"
        static let openTeamsOnClick = "tg_openTeamsOnClick"
        static let playSound = "tg_playSound"
        static let hasCompletedOnboarding = "tg_hasCompletedOnboarding"
    }
}

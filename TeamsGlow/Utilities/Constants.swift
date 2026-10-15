//
//  Constants.swift
//  TeamsGlow
//
//  Created by TeamsGlow on 23/09/26.
//

import SwiftUI

// MARK: - Design Constants

enum DesignConstants {
    
    // MARK: Notification Card
    
    enum Card {
        static let width: CGFloat = 400
        static let minHeight: CGFloat = 180
        static let cornerRadius: CGFloat = 20
        static let borderWidth: CGFloat = 1.0
        static let padding: CGFloat = 20
        static let innerSpacing: CGFloat = 12
    }
    
    // MARK: Avatar
    
    enum Avatar {
        static let size: CGFloat = 42
        static let cornerRadius: CGFloat = 21
        static let borderWidth: CGFloat = 2
    }
    
    // MARK: Animation Timing
    
    enum Timing {
        static let appearDuration: Double = 0.5
        static let dismissDuration: Double = 0.35
        static let glowPulseDuration: Double = 2.5
        static let gradientRotationDuration: Double = 4.0
    }
    
    // MARK: Animation Values
    
    enum AnimationValues {
        static let initialScale: CGFloat = 0.92
        static let dismissScale: CGFloat = 0.95
        static let initialOffsetY: CGFloat = 15
        static let dismissOffsetY: CGFloat = -10
    }
    
    // MARK: Fonts
    
    enum Fonts {
        static let appTitle = Font.system(size: 11, weight: .medium, design: .default)
        static let senderName = Font.system(size: 15, weight: .semibold, design: .default)
        static let messagePreview = Font.system(size: 13, weight: .regular, design: .default)
        static let timestamp = Font.system(size: 11, weight: .regular, design: .default)
        static let buttonLabel = Font.system(size: 12, weight: .semibold, design: .default)
    }
    
    // MARK: Teams Identity
    
    enum Teams {
        static let bundleIdNew = "com.microsoft.teams2"
        static let bundleIdClassic = "com.microsoft.teams"
        static let notificationCenterBundleId = "com.apple.notificationcenterui"
        static let urlScheme = "msteams://"
    }
}

// MARK: - Color Extensions

extension Color {
    
    // MARK: Teams Brand Colors
    
    static let teamsPurple = Color(red: 0.45, green: 0.27, blue: 0.85)
    static let teamsBlue = Color(red: 0.25, green: 0.47, blue: 0.95)
    static let teamsCyan = Color(red: 0.10, green: 0.75, blue: 0.85)
    static let teamsPink = Color(red: 0.85, green: 0.35, blue: 0.65)
    static let teamsViolet = Color(red: 0.55, green: 0.22, blue: 0.90)
    
    // MARK: Surface Colors
    
    static let glassBackground = Color.white.opacity(0.06)
    static let glassBorder = Color.white.opacity(0.15)
    static let cardShadow = Color.black.opacity(0.3)
    
    // MARK: Text Colors
    
    static let primaryText = Color.white
    static let secondaryText = Color.white.opacity(0.65)
    static let tertiaryText = Color.white.opacity(0.40)
}

// MARK: - Gradient Presets

extension LinearGradient {
    
    /// The primary Teams-inspired gradient for accent elements.
    static let teamsAccent = LinearGradient(
        colors: [.teamsPurple, .teamsBlue, .teamsCyan],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    /// A vibrant gradient for borders and glows.
    static let teamsBorder = LinearGradient(
        colors: [
            .teamsPurple.opacity(0.6),
            .teamsBlue.opacity(0.4),
            .teamsCyan.opacity(0.6),
            .teamsPink.opacity(0.4),
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    /// Subtle gradient for button backgrounds.
    static let buttonGradient = LinearGradient(
        colors: [
            Color(red: 0.45, green: 0.27, blue: 0.85),
            Color(red: 0.35, green: 0.40, blue: 0.92),
        ],
        startPoint: .leading,
        endPoint: .trailing
    )
}

// MARK: - Animation Presets

extension Animation {
    
    /// Spring animation for notification appearance.
    static let notificationAppear = Animation.spring(
        response: 0.5,
        dampingFraction: 0.78,
        blendDuration: 0.1
    )
    
    /// Smooth ease-out for notification dismissal.
    static let notificationDismiss = Animation.easeOut(duration: 0.35)
    
    /// Bouncy spring for playful animations.
    static let bouncyAppear = Animation.spring(
        response: 0.45,
        dampingFraction: 0.6,
        blendDuration: 0.1
    )
    
    /// Slow continuous animation for glow pulsing.
    static let glowPulse = Animation.easeInOut(duration: 2.5).repeatForever(autoreverses: true)
    
    /// Slow continuous rotation for gradient borders.
    static let gradientRotation = Animation.linear(duration: 4.0).repeatForever(autoreverses: false)
}

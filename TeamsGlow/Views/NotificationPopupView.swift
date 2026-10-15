//
//  NotificationPopupView.swift
//  TeamsGlow
//
//  Created by TeamsGlow on 23/09/26.
//

import SwiftUI

// MARK: - Notification Popup View

/// The premium glassmorphism notification popup displayed in the center of the screen.
/// Wraps `NotificationContentView` with the glass card background and entry/exit animations.
struct NotificationPopupView: View {
    let notification: TeamsNotification
    let settings: NotificationSettings
    let onOpenTeams: () -> Void
    let onDismiss: () -> Void
    
    @State private var isVisible = false
    @State private var isDismissing = false
    
    var body: some View {
        ZStack {
            // Subtle ambient particles
            AmbientParticles(
                count: 6,
                color: settings.colorTheme.primaryAccent.opacity(0.3)
            )
            
            // Main notification card
            NotificationContentView(
                notification: notification,
                settings: settings,
                onOpenTeams: {
                    dismissWithAnimation {
                        onOpenTeams()
                    }
                },
                onDismiss: {
                    dismissWithAnimation {
                        onDismiss()
                    }
                }
            )
            .frame(width: DesignConstants.Card.width)
            .glassCard(
                glassIntensity: settings.glassIntensity,
                borderColors: settings.colorTheme.gradientColors,
                glowIntensity: settings.glowIntensity
            )
            .glowEffect(
                colors: settings.colorTheme.gradientColors,
                radius: 20,
                intensity: settings.glowIntensity * 0.5
            )
            // Entry/Exit animation transforms
            .scaleEffect(animationScale)
            .offset(y: animationOffset)
            .opacity(animationOpacity)
        }
        .frame(width: DesignConstants.Card.width + 40, height: 240)
        .onAppear {
            // Trigger entry animation
            withAnimation(entryAnimation) {
                isVisible = true
            }
        }
    }
    
    // MARK: - Animation State
    
    private var animationScale: CGFloat {
        if isDismissing {
            return DesignConstants.AnimationValues.dismissScale
        }
        return isVisible ? 1.0 : DesignConstants.AnimationValues.initialScale
    }
    
    private var animationOffset: CGFloat {
        if isDismissing {
            return DesignConstants.AnimationValues.dismissOffsetY
        }
        return isVisible ? 0 : DesignConstants.AnimationValues.initialOffsetY
    }
    
    private var animationOpacity: Double {
        if isDismissing {
            return 0
        }
        return isVisible ? 1.0 : 0
    }
    
    private var entryAnimation: Animation {
        switch settings.animationStyle {
        case .spring:
            return .notificationAppear
        case .smooth:
            return .easeInOut(duration: DesignConstants.Timing.appearDuration)
        case .bouncy:
            return .bouncyAppear
        }
    }
    
    // MARK: - Dismiss Animation
    
    private func dismissWithAnimation(completion: @escaping () -> Void) {
        withAnimation(.notificationDismiss) {
            isDismissing = true
        }
        
        // Delay the actual dismiss to let the animation play
        DispatchQueue.main.asyncAfter(deadline: .now() + DesignConstants.Timing.dismissDuration) {
            completion()
        }
    }
}

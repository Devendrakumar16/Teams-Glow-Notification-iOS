//
//  GlowEffect.swift
//  TeamsGlow
//
//  Created by TeamsGlow on 23/09/26.
//

import SwiftUI

// MARK: - Glow Effect Modifier

/// Adds an animated pulsing glow effect around a view.
struct GlowEffectModifier: ViewModifier {
    let colors: [Color]
    let radius: CGFloat
    let intensity: Double
    
    @State private var isAnimating = false
    
    func body(content: Content) -> some View {
        content
            .shadow(
                color: colors.first?.opacity(intensity * (isAnimating ? 0.8 : 0.4)) ?? .clear,
                radius: radius * (isAnimating ? 1.2 : 0.8)
            )
            .shadow(
                color: (colors.count > 1 ? colors[1] : colors.first ?? .clear)
                    .opacity(intensity * (isAnimating ? 0.5 : 0.2)),
                radius: radius * 0.6
            )
            .onAppear {
                withAnimation(.glowPulse) {
                    isAnimating = true
                }
            }
    }
}

// MARK: - Animated Border Glow

/// An animated gradient border with glow effect.
struct AnimatedBorderGlow: View {
    let colors: [Color]
    let cornerRadius: CGFloat
    let lineWidth: CGFloat
    let intensity: Double
    
    @State private var rotation: Double = 0
    @State private var pulsePhase: Bool = false
    
    var body: some View {
        ZStack {
            // Outer glow layer
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(
                    AngularGradient(
                        colors: colors + [colors.first ?? .clear],
                        center: .center,
                        startAngle: .degrees(rotation),
                        endAngle: .degrees(rotation + 360)
                    ),
                    lineWidth: lineWidth + 4
                )
                .blur(radius: 8)
                .opacity(intensity * (pulsePhase ? 0.6 : 0.3))
            
            // Inner border layer
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(
                    AngularGradient(
                        colors: colors + [colors.first ?? .clear],
                        center: .center,
                        startAngle: .degrees(rotation),
                        endAngle: .degrees(rotation + 360)
                    ),
                    lineWidth: lineWidth
                )
                .opacity(intensity * 0.8)
        }
        .onAppear {
            withAnimation(.gradientRotation) {
                rotation = 360
            }
            withAnimation(.glowPulse) {
                pulsePhase = true
            }
        }
    }
}

// MARK: - View Extension

extension View {
    /// Applies an animated glow effect.
    func glowEffect(
        colors: [Color] = [.teamsPurple, .teamsBlue],
        radius: CGFloat = 15,
        intensity: Double = 0.6
    ) -> some View {
        self.modifier(GlowEffectModifier(colors: colors, radius: radius, intensity: intensity))
    }
}

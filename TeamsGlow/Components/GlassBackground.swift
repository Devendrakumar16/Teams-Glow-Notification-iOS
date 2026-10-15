//
//  GlassBackground.swift
//  TeamsGlow
//
//  Created by TeamsGlow on 23/09/26.
//

import SwiftUI
import AppKit

// MARK: - Visual Effect View (NSVisualEffectView Wrapper)

/// Wraps `NSVisualEffectView` for true macOS vibrancy and blur.
struct VisualEffectView: NSViewRepresentable {
    let material: NSVisualEffectView.Material
    let blendingMode: NSVisualEffectView.BlendingMode
    let state: NSVisualEffectView.State
    let opacity: Double
    
    init(
        material: NSVisualEffectView.Material = .hudWindow,
        blendingMode: NSVisualEffectView.BlendingMode = .behindWindow,
        state: NSVisualEffectView.State = .active,
        opacity: Double = 1.0
    ) {
        self.material = material
        self.blendingMode = blendingMode
        self.state = state
        self.opacity = opacity
    }
    
    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = material
        view.blendingMode = blendingMode
        view.state = state
        view.alphaValue = CGFloat(opacity)
        view.wantsLayer = true
        return view
    }
    
    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.material = material
        nsView.blendingMode = blendingMode
        nsView.state = state
        nsView.alphaValue = CGFloat(opacity)
    }
}

// MARK: - Glass Background

/// A premium glassmorphism background with blur, gradient overlay, and animated border.
struct GlassBackground: View {
    let cornerRadius: CGFloat
    let glassIntensity: Double
    let borderColors: [Color]
    let glowIntensity: Double
    
    init(
        cornerRadius: CGFloat = DesignConstants.Card.cornerRadius,
        glassIntensity: Double = 0.7,
        borderColors: [Color] = ColorTheme.teams.gradientColors,
        glowIntensity: Double = 0.6
    ) {
        self.cornerRadius = cornerRadius
        self.glassIntensity = glassIntensity
        self.borderColors = borderColors
        self.glowIntensity = glowIntensity
    }
    
    var body: some View {
        ZStack {
            // Base blur layer
            VisualEffectView(
                material: .hudWindow,
                blendingMode: .behindWindow,
                state: .active,
                opacity: glassIntensity
            )
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            
            // Dark overlay for depth
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(Color.black.opacity(0.20))
            
            // Pinkish tint layer
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.95, green: 0.25, blue: 0.55).opacity(0.12),
                            Color(red: 0.85, green: 0.20, blue: 0.65).opacity(0.08),
                            Color(red: 0.70, green: 0.15, blue: 0.75).opacity(0.06),
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            // Subtle gradient overlay
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.95, green: 0.30, blue: 0.55).opacity(0.10),
                            .clear,
                            Color(red: 0.80, green: 0.20, blue: 0.70).opacity(0.07),
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            // Inner highlight (top edge)
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.08),
                            Color.white.opacity(0.02),
                            .clear,
                        ],
                        startPoint: .top,
                        endPoint: .center
                    )
                )
            
            // Animated border glow
            AnimatedBorderGlow(
                colors: borderColors,
                cornerRadius: cornerRadius,
                lineWidth: DesignConstants.Card.borderWidth,
                intensity: glowIntensity
            )
        }
    }
}

// MARK: - Glass Card Modifier

/// Applies the full glass card effect to any view.
struct GlassCardModifier: ViewModifier {
    let glassIntensity: Double
    let borderColors: [Color]
    let glowIntensity: Double
    
    func body(content: Content) -> some View {
        content
            .background {
                GlassBackground(
                    glassIntensity: glassIntensity,
                    borderColors: borderColors,
                    glowIntensity: glowIntensity
                )
            }
            .clipShape(RoundedRectangle(cornerRadius: DesignConstants.Card.cornerRadius))
            .shadow(color: .cardShadow, radius: 30, y: 10)
    }
}

extension View {
    /// Applies the glassmorphism card background.
    func glassCard(
        glassIntensity: Double = 0.7,
        borderColors: [Color] = ColorTheme.teams.gradientColors,
        glowIntensity: Double = 0.6
    ) -> some View {
        self.modifier(
            GlassCardModifier(
                glassIntensity: glassIntensity,
                borderColors: borderColors,
                glowIntensity: glowIntensity
            )
        )
    }
}

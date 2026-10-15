//
//  GradientButton.swift
//  TeamsGlow
//
//  Created by TeamsGlow on 23/09/26.
//

import SwiftUI

// MARK: - Gradient Button Style

/// A premium button with gradient background, hover effect, and press animation.
struct GradientButtonStyle: ButtonStyle {
    let gradient: LinearGradient
    let cornerRadius: CGFloat
    let isCompact: Bool
    
    @State private var isHovering = false
    
    init(
        gradient: LinearGradient = .buttonGradient,
        cornerRadius: CGFloat = 10,
        isCompact: Bool = false
    ) {
        self.gradient = gradient
        self.cornerRadius = cornerRadius
        self.isCompact = isCompact
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(DesignConstants.Fonts.buttonLabel)
            .foregroundColor(.white)
            .padding(.horizontal, isCompact ? 14 : 18)
            .padding(.vertical, isCompact ? 6 : 9)
            .background {
                ZStack {
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(gradient)
                    
                    // Hover brightness
                    if isHovering {
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .fill(Color.white.opacity(0.12))
                    }
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .shadow(
                color: Color.teamsPurple.opacity(isHovering ? 0.4 : 0.2),
                radius: isHovering ? 10 : 5,
                y: 2
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.7), value: configuration.isPressed)
            .animation(.easeInOut(duration: 0.2), value: isHovering)
            .onHover { hovering in
                isHovering = hovering
            }
    }
}

// MARK: - Subtle Button Style

/// A subtle, transparent button style for secondary actions.
struct SubtleButtonStyle: ButtonStyle {
    let cornerRadius: CGFloat
    
    @State private var isHovering = false
    
    init(cornerRadius: CGFloat = 10) {
        self.cornerRadius = cornerRadius
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(DesignConstants.Fonts.buttonLabel)
            .foregroundColor(.white.opacity(0.85))
            .padding(.horizontal, 18)
            .padding(.vertical, 9)
            .background {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(Color.white.opacity(isHovering ? 0.15 : 0.08))
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .stroke(Color.white.opacity(isHovering ? 0.25 : 0.12), lineWidth: 1)
                    )
            }
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.7), value: configuration.isPressed)
            .animation(.easeInOut(duration: 0.2), value: isHovering)
            .onHover { hovering in
                isHovering = hovering
            }
    }
}

// MARK: - Convenience Extensions

extension ButtonStyle where Self == GradientButtonStyle {
    static var gradientAccent: GradientButtonStyle {
        GradientButtonStyle()
    }
    
    static var compactGradient: GradientButtonStyle {
        GradientButtonStyle(isCompact: true)
    }
}

extension ButtonStyle where Self == SubtleButtonStyle {
    static var subtle: SubtleButtonStyle {
        SubtleButtonStyle()
    }
}

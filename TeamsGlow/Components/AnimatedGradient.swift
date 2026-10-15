//
//  AnimatedGradient.swift
//  TeamsGlow
//
//  Created by TeamsGlow on 23/09/26.
//

import SwiftUI

// MARK: - Animated Gradient Background

/// A continuously animating gradient for ambient background effects.
struct AnimatedGradientBackground: View {
    let colors: [Color]
    let opacity: Double
    
    @State private var animationPhase: CGFloat = 0
    
    init(
        colors: [Color] = ColorTheme.teams.gradientColors,
        opacity: Double = 0.15
    ) {
        self.colors = colors
        self.opacity = opacity
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Moving gradient blob 1
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [colors[0].opacity(opacity), .clear],
                            center: .center,
                            startRadius: 0,
                            endRadius: geometry.size.width * 0.5
                        )
                    )
                    .frame(width: geometry.size.width * 0.8, height: geometry.size.width * 0.8)
                    .offset(
                        x: cos(animationPhase * .pi * 2) * geometry.size.width * 0.15,
                        y: sin(animationPhase * .pi * 2) * geometry.size.height * 0.15
                    )
                
                // Moving gradient blob 2
                if colors.count > 1 {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [colors[1].opacity(opacity * 0.8), .clear],
                                center: .center,
                                startRadius: 0,
                                endRadius: geometry.size.width * 0.4
                            )
                        )
                        .frame(width: geometry.size.width * 0.6, height: geometry.size.width * 0.6)
                        .offset(
                            x: sin(animationPhase * .pi * 2 + 1) * geometry.size.width * 0.2,
                            y: cos(animationPhase * .pi * 2 + 1) * geometry.size.height * 0.2
                        )
                }
                
                // Moving gradient blob 3
                if colors.count > 2 {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [colors[2].opacity(opacity * 0.6), .clear],
                                center: .center,
                                startRadius: 0,
                                endRadius: geometry.size.width * 0.35
                            )
                        )
                        .frame(width: geometry.size.width * 0.5, height: geometry.size.width * 0.5)
                        .offset(
                            x: cos(animationPhase * .pi * 2 + 2.5) * geometry.size.width * 0.18,
                            y: sin(animationPhase * .pi * 2 + 2.5) * geometry.size.height * 0.18
                        )
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .onAppear {
            withAnimation(.linear(duration: 8).repeatForever(autoreverses: false)) {
                animationPhase = 1
            }
        }
    }
}

// MARK: - Ambient Particle Effect

/// Subtle floating particles for premium ambient effects.
struct AmbientParticles: View {
    let count: Int
    let color: Color
    
    @State private var particles: [Particle] = []
    @State private var isAnimating = false
    
    struct Particle: Identifiable {
        let id = UUID()
        var x: CGFloat
        var y: CGFloat
        let size: CGFloat
        let opacity: Double
        let speed: Double
    }
    
    init(count: Int = 8, color: Color = .white) {
        self.count = count
        self.color = color
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(particles) { particle in
                    Circle()
                        .fill(color.opacity(particle.opacity * (isAnimating ? 1 : 0)))
                        .frame(width: particle.size, height: particle.size)
                        .position(
                            x: particle.x + (isAnimating ? CGFloat.random(in: -20...20) : 0),
                            y: particle.y + (isAnimating ? CGFloat.random(in: -30...(-10)) : 0)
                        )
                        .blur(radius: 1)
                }
            }
            .onAppear {
                // Generate random particles
                particles = (0..<count).map { _ in
                    Particle(
                        x: CGFloat.random(in: 0...geometry.size.width),
                        y: CGFloat.random(in: 0...geometry.size.height),
                        size: CGFloat.random(in: 1.5...3.5),
                        opacity: Double.random(in: 0.15...0.4),
                        speed: Double.random(in: 3...6)
                    )
                }
                
                withAnimation(.easeInOut(duration: 4).repeatForever(autoreverses: true)) {
                    isAnimating = true
                }
            }
        }
    }
}

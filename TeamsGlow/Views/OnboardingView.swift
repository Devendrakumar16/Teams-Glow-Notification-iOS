//
//  OnboardingView.swift
//  TeamsGlow
//
//  Created by TeamsGlow on 23/09/26.
//

import SwiftUI

// MARK: - Onboarding View

/// Step-by-step onboarding flow that guides the user through granting Accessibility permission.
struct OnboardingView: View {
    @State var permissionManager: NotificationPermissionManager
    let onComplete: () -> Void
    
    @State private var currentStep: Int = 0
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            // Background
            Color.black
            AnimatedGradientBackground(opacity: 0.08)
            
            VStack(spacing: 0) {
                // Step content
                Group {
                    switch currentStep {
                    case 0:
                        welcomeStep
                    case 1:
                        permissionStep
                    case 2:
                        readyStep
                    default:
                        EmptyView()
                    }
                }
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))
                .animation(.spring(response: 0.5, dampingFraction: 0.8), value: currentStep)
                
                // Step indicators
                HStack(spacing: 8) {
                    ForEach(0..<3, id: \.self) { step in
                        Circle()
                            .fill(step == currentStep ? Color.teamsPurple : Color.white.opacity(0.2))
                            .frame(width: 8, height: 8)
                            .scaleEffect(step == currentStep ? 1.2 : 1.0)
                            .animation(.spring(response: 0.3), value: currentStep)
                    }
                }
                .padding(.bottom, 30)
            }
        }
        .frame(width: 520, height: 480)
        .onAppear {
            permissionManager.startMonitoringPermission()
            withAnimation(.easeInOut(duration: 1)) {
                isAnimating = true
            }
        }
        .onDisappear {
            permissionManager.stopMonitoringPermission()
        }
    }
    
    // MARK: - Step 1: Welcome
    
    private var welcomeStep: some View {
        VStack(spacing: 24) {
            Spacer()
            
            // App icon
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [.teamsPurple.opacity(0.3), .clear],
                            center: .center,
                            startRadius: 20,
                            endRadius: 60
                        )
                    )
                    .frame(width: 120, height: 120)
                
                Image(systemName: "bell.badge.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(.linearGradient(
                        colors: [.teamsPurple, .teamsBlue, .teamsCyan],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .symbolRenderingMode(.hierarchical)
            }
            .scaleEffect(isAnimating ? 1.0 : 0.8)
            .opacity(isAnimating ? 1.0 : 0)
            
            Text("Welcome to TeamsGlow")
                .font(.system(size: 28, weight: .bold, design: .default))
                .foregroundColor(.white)
            
            Text("Beautiful, custom notification popups for\nMicrosoft Teams on your Mac.")
                .font(.system(size: 15, weight: .regular))
                .foregroundColor(.secondaryText)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
            
            Spacer()
            
            Button("Get Started") {
                withAnimation {
                    currentStep = 1
                }
            }
            .buttonStyle(.gradientAccent)
            
            Spacer()
                .frame(height: 40)
        }
        .padding(.horizontal, 40)
    }
    
    // MARK: - Step 2: Permission
    
    private var permissionStep: some View {
        VStack(spacing: 24) {
            Spacer()
            
            // Permission icon
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                (permissionManager.isAccessibilityGranted ? Color.green : Color.orange).opacity(0.3),
                                .clear,
                            ],
                            center: .center,
                            startRadius: 15,
                            endRadius: 55
                        )
                    )
                    .frame(width: 110, height: 110)
                
                Image(systemName: permissionManager.isAccessibilityGranted
                      ? "checkmark.shield.fill"
                      : "lock.shield.fill")
                    .font(.system(size: 44))
                    .foregroundStyle(permissionManager.isAccessibilityGranted
                                    ? .green
                                    : .orange)
                    .symbolRenderingMode(.hierarchical)
                    .contentTransition(.symbolEffect(.replace))
            }
            
            Text("Accessibility Permission")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)
            
            VStack(spacing: 12) {
                Text("TeamsGlow needs Accessibility access to detect notification banners from Microsoft Teams.")
                    .font(.system(size: 14))
                    .foregroundColor(.secondaryText)
                    .multilineTextAlignment(.center)
                
                Text("This permission allows TeamsGlow to read the content of notification banners as they appear on screen.")
                    .font(.system(size: 12))
                    .foregroundColor(.tertiaryText)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 20)
            
            // Permission status badge
            HStack(spacing: 8) {
                Circle()
                    .fill(permissionManager.isAccessibilityGranted ? .green : .orange)
                    .frame(width: 8, height: 8)
                
                Text(permissionManager.isAccessibilityGranted ? "Permission Granted" : "Permission Required")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(permissionManager.isAccessibilityGranted ? .green : .orange)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background {
                Capsule()
                    .fill((permissionManager.isAccessibilityGranted ? Color.green : Color.orange).opacity(0.12))
                    .overlay(
                        Capsule()
                            .stroke((permissionManager.isAccessibilityGranted ? Color.green : Color.orange).opacity(0.25), lineWidth: 1)
                    )
            }
            
            Spacer()
            
            if permissionManager.isAccessibilityGranted {
                Button("Continue") {
                    withAnimation {
                        currentStep = 2
                    }
                }
                .buttonStyle(.gradientAccent)
            } else {
                VStack(spacing: 12) {
                    Button("Open System Settings") {
                        permissionManager.openAccessibilitySettings()
                    }
                    .buttonStyle(.gradientAccent)
                    
                    Text("After enabling, return here — status updates automatically.")
                        .font(.system(size: 11))
                        .foregroundColor(.tertiaryText)
                }
            }
            
            Spacer()
                .frame(height: 40)
        }
        .padding(.horizontal, 40)
    }
    
    // MARK: - Step 3: Ready
    
    private var readyStep: some View {
        VStack(spacing: 24) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [.green.opacity(0.3), .clear],
                            center: .center,
                            startRadius: 15,
                            endRadius: 55
                        )
                    )
                    .frame(width: 110, height: 110)
                
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(.green)
                    .symbolRenderingMode(.hierarchical)
            }
            
            Text("You're All Set!")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.white)
            
            Text("TeamsGlow will now monitor for Microsoft Teams notifications and display beautiful custom popups.")
                .font(.system(size: 14))
                .foregroundColor(.secondaryText)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
            
            VStack(alignment: .leading, spacing: 10) {
                featureRow(icon: "menubar.rectangle", text: "Look for the icon in your menu bar")
                featureRow(icon: "bell.badge.fill", text: "Notifications appear in the center of your screen")
                featureRow(icon: "gear", text: "Customize appearance in Settings")
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.08), lineWidth: 1)
                    )
            }
            
            Spacer()
            
            Button("Start TeamsGlow") {
                onComplete()
            }
            .buttonStyle(.gradientAccent)
            
            Spacer()
                .frame(height: 40)
        }
        .padding(.horizontal, 40)
    }
    
    private func featureRow(icon: String, text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(.teamsCyan)
                .frame(width: 24)
            
            Text(text)
                .font(.system(size: 13))
                .foregroundColor(.secondaryText)
        }
    }
}

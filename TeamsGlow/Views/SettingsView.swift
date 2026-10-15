//
//  SettingsView.swift
//  TeamsGlow
//
//  Created by TeamsGlow on 23/09/26.
//

import SwiftUI

// MARK: - Settings View

/// Beautiful settings window organized into General, Appearance, and Behavior sections.
struct SettingsView: View {
    @State var settings: NotificationSettings
    @State var permissionManager: NotificationPermissionManager
    let settingsManager: SettingsManager
    
    @State private var selectedTab: SettingsTab = .general
    
    enum SettingsTab: String, CaseIterable {
        case general = "General"
        case appearance = "Appearance"
        case behavior = "Behavior"
        
        var icon: String {
            switch self {
            case .general: return "gear"
            case .appearance: return "paintbrush.fill"
            case .behavior: return "hand.tap.fill"
            }
        }
    }
    
    var body: some View {
        ZStack {
            // Dark background
            Color(nsColor: .windowBackgroundColor)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Custom tab bar
                tabBar
                
                Divider()
                    .background(Color.white.opacity(0.1))
                
                // Tab content
                ScrollView {
                    VStack(spacing: 20) {
                        switch selectedTab {
                        case .general:
                            generalSection
                        case .appearance:
                            appearanceSection
                        case .behavior:
                            behaviorSection
                        }
                    }
                    .padding(24)
                }
            }
        }
        .frame(width: 480, height: 520)
    }
    
    // MARK: - Tab Bar
    
    private var tabBar: some View {
        HStack(spacing: 2) {
            ForEach(SettingsTab.allCases, id: \.self) { tab in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedTab = tab
                    }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: tab.icon)
                            .font(.system(size: 12))
                        Text(tab.rawValue)
                            .font(.system(size: 13, weight: .medium))
                    }
                    .foregroundColor(selectedTab == tab ? .white : .secondary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background {
                        if selectedTab == tab {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.teamsPurple.opacity(0.3))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.teamsPurple.opacity(0.4), lineWidth: 1)
                                )
                        }
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
    }
    
    // MARK: - General Section
    
    private var generalSection: some View {
        VStack(spacing: 16) {
            settingsGroup(title: "General") {
                toggleRow(
                    icon: "power",
                    title: "Enable Custom Notifications",
                    subtitle: "Show TeamsGlow popups for Teams notifications",
                    isOn: $settings.isEnabled
                )
                
                Divider().opacity(0.3)
                
                toggleRow(
                    icon: "sunrise",
                    title: "Launch at Login",
                    subtitle: "Start TeamsGlow when you log in",
                    isOn: Binding(
                        get: { settings.launchAtLogin },
                        set: { settingsManager.updateLaunchAtLogin($0) }
                    )
                )
                
                Divider().opacity(0.3)
                
                toggleRow(
                    icon: "display",
                    title: "Show on Current Display",
                    subtitle: "Show notifications on the screen where you're working",
                    isOn: $settings.showOnCurrentDisplay
                )
                
                Divider().opacity(0.3)
                
                // Duration slider
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "clock")
                            .font(.system(size: 14))
                            .foregroundColor(.teamsCyan)
                            .frame(width: 24)
                        
                        Text("Notification Duration")
                            .font(.system(size: 13, weight: .medium))
                        
                        Spacer()
                        
                        Text("\(Int(settings.notificationDuration))s")
                            .font(.system(size: 13, weight: .semibold, design: .monospaced))
                            .foregroundColor(.teamsCyan)
                    }
                    
                    Slider(value: $settings.notificationDuration, in: 3...15, step: 1)
                        .tint(.teamsPurple)
                }
            }
            
            // Permission status
            settingsGroup(title: "Permissions") {
                HStack {
                    Image(systemName: permissionManager.isAccessibilityGranted
                          ? "checkmark.shield.fill"
                          : "xmark.shield.fill")
                        .font(.system(size: 14))
                        .foregroundColor(permissionManager.isAccessibilityGranted ? .green : .red)
                        .frame(width: 24)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Accessibility Permission")
                            .font(.system(size: 13, weight: .medium))
                        Text(permissionManager.isAccessibilityGranted
                             ? "Granted — TeamsGlow can detect notifications"
                             : "Required — Click to open System Settings")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    if !permissionManager.isAccessibilityGranted {
                        Button("Grant Access") {
                            permissionManager.openAccessibilitySettings()
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.teamsPurple)
                        .controlSize(.small)
                    }
                }
                
                Divider().opacity(0.3)
                
                HStack {
                    Image(systemName: permissionManager.isTeamsRunning
                          ? "checkmark.circle.fill"
                          : "circle")
                        .font(.system(size: 14))
                        .foregroundColor(permissionManager.isTeamsRunning ? .green : .secondary)
                        .frame(width: 24)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Microsoft Teams")
                            .font(.system(size: 13, weight: .medium))
                        Text(permissionManager.isTeamsRunning
                             ? "Running"
                             : "Not running — notifications won't be detected")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
            }
        }
    }
    
    // MARK: - Appearance Section
    
    private var appearanceSection: some View {
        VStack(spacing: 16) {
            settingsGroup(title: "Visual") {
                // Glass intensity
                sliderRow(
                    icon: "drop.fill",
                    title: "Glass Intensity",
                    value: $settings.glassIntensity,
                    range: 0.3...1.0,
                    color: .teamsBlue
                )
                
                Divider().opacity(0.3)
                
                // Glow intensity
                sliderRow(
                    icon: "sparkles",
                    title: "Glow Intensity",
                    value: $settings.glowIntensity,
                    range: 0...1.0,
                    color: .teamsPurple
                )
            }
            
            settingsGroup(title: "Animation") {
                // Animation style picker
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Image(systemName: "wand.and.stars")
                            .font(.system(size: 14))
                            .foregroundColor(.teamsPink)
                            .frame(width: 24)
                        
                        Text("Animation Style")
                            .font(.system(size: 13, weight: .medium))
                    }
                    
                    HStack(spacing: 8) {
                        ForEach(AnimationStyle.allCases) { style in
                            Button {
                                withAnimation {
                                    settings.animationStyle = style
                                }
                            } label: {
                                VStack(spacing: 4) {
                                    Image(systemName: style.icon)
                                        .font(.system(size: 16))
                                    Text(style.displayName)
                                        .font(.system(size: 11))
                                }
                                .foregroundColor(settings.animationStyle == style ? .white : .secondary)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .background {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(settings.animationStyle == style
                                              ? Color.teamsPurple.opacity(0.3)
                                              : Color.white.opacity(0.05))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(settings.animationStyle == style
                                                        ? Color.teamsPurple.opacity(0.5)
                                                        : Color.white.opacity(0.08), lineWidth: 1)
                                        )
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            
            settingsGroup(title: "Color Theme") {
                VStack(spacing: 10) {
                    ForEach(ColorTheme.allCases) { theme in
                        Button {
                            withAnimation {
                                settings.colorTheme = theme
                            }
                        } label: {
                            HStack(spacing: 12) {
                                // Color swatch
                                HStack(spacing: 2) {
                                    ForEach(Array(theme.gradientColors.prefix(4).enumerated()), id: \.offset) { _, color in
                                        Circle()
                                            .fill(color)
                                            .frame(width: 14, height: 14)
                                    }
                                }
                                
                                Text(theme.displayName)
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(settings.colorTheme == theme ? .white : .secondary)
                                
                                Spacer()
                                
                                if settings.colorTheme == theme {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.teamsCyan)
                                }
                            }
                            .padding(10)
                            .background {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(settings.colorTheme == theme
                                          ? Color.teamsPurple.opacity(0.2)
                                          : Color.clear)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(settings.colorTheme == theme
                                                    ? Color.teamsPurple.opacity(0.4)
                                                    : Color.white.opacity(0.05), lineWidth: 1)
                                    )
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }
    
    // MARK: - Behavior Section
    
    private var behaviorSection: some View {
        VStack(spacing: 16) {
            settingsGroup(title: "Behavior") {
                toggleRow(
                    icon: "clock.arrow.circlepath",
                    title: "Auto-Dismiss",
                    subtitle: "Automatically dismiss notifications after the configured duration",
                    isOn: $settings.autoDismiss
                )
                
                Divider().opacity(0.3)
                
                toggleRow(
                    icon: "arrow.up.forward.app",
                    title: "Open Teams on Click",
                    subtitle: "Open Microsoft Teams when clicking the 'Open' button",
                    isOn: $settings.openTeamsOnClick
                )
                
                Divider().opacity(0.3)
                
                toggleRow(
                    icon: "speaker.wave.2.fill",
                    title: "Play Sound",
                    subtitle: "Play a subtle sound when a notification arrives",
                    isOn: $settings.playSound
                )
            }
            
            // About section
            settingsGroup(title: "About") {
                HStack {
                    Image(systemName: "bell.badge.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(.linearGradient(
                            colors: [.teamsPurple, .teamsBlue, .teamsCyan],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("TeamsGlow")
                            .font(.system(size: 14, weight: .semibold))
                        Text("Version 1.0")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
            }
        }
    }
    
    // MARK: - Reusable Components
    
    private func settingsGroup<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title.uppercased())
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(.secondary)
                .tracking(1)
            
            VStack(spacing: 12) {
                content()
            }
            .padding(14)
            .background {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white.opacity(0.04))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.white.opacity(0.06), lineWidth: 1)
                    )
            }
        }
    }
    
    private func toggleRow(icon: String, title: String, subtitle: String, isOn: Binding<Bool>) -> some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(.teamsCyan)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 13, weight: .medium))
                Text(subtitle)
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Toggle("", isOn: isOn)
                .toggleStyle(.switch)
                .labelsHidden()
                .tint(.teamsPurple)
        }
    }
    
    private func sliderRow(icon: String, title: String, value: Binding<Double>, range: ClosedRange<Double>, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundColor(color)
                    .frame(width: 24)
                
                Text(title)
                    .font(.system(size: 13, weight: .medium))
                
                Spacer()
                
                Text("\(Int(value.wrappedValue * 100))%")
                    .font(.system(size: 12, weight: .medium, design: .monospaced))
                    .foregroundColor(color)
            }
            
            Slider(value: value, in: range)
                .tint(color)
        }
    }
}

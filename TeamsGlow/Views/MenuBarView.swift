//
//  MenuBarView.swift
//  TeamsGlow
//
//  Created by TeamsGlow on 23/09/26.
//

import SwiftUI

// MARK: - Menu Bar View

/// The content of the menu bar dropdown — shows latest notification prominently,
/// status, recent list, and actions.
struct MenuBarView: View {
    let settings: NotificationSettings
    let monitor: TeamsNotificationMonitor
    let permissionManager: NotificationPermissionManager
    let queueManager: NotificationQueueManager
    let onOpenSettings: () -> Void
    let onTestNotification: () -> Void
    let onQuit: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Latest notification (if any) — sender-focused, no system dialog
            latestNotificationSection
            
            Divider().padding(.vertical, 4)
            
            // Status
            statusSection
            
            Divider().padding(.vertical, 4)
            
            // Recent notifications
            recentSection
            
            Divider().padding(.vertical, 4)
            
            // Actions
            actionsSection
        }
        .padding(8)
        .frame(width: 300)
    }
    
    // MARK: - Latest Notification (replaces old system-dialog header)
    
    private var latestNotificationSection: some View {
        Group {
            if let latest = queueManager.recentNotifications.first {
                // Show the latest sender with their initials avatar — no system branding
                HStack(spacing: 10) {
                    // Sender initials avatar
                    senderAvatar(name: latest.senderName, size: 36)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(latest.senderName)
                            .font(.system(size: 14, weight: .bold))
                        
                        Text(latest.messagePreview)
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                    
                    Spacer()
                    
                    Text(latest.relativeTimestamp)
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
            } else {
                // No notifications yet — simple app name, no system icon
                HStack(spacing: 8) {
                    senderAvatar(name: "TeamsGlow", size: 28)
                    
                    Text("TeamsGlow")
                        .font(.system(size: 13, weight: .semibold))
                    
                    Spacer()
                    
                    // Quick toggle
                    Toggle("", isOn: Binding(
                        get: { settings.isEnabled },
                        set: { settings.isEnabled = $0 }
                    ))
                    .toggleStyle(.switch)
                    .labelsHidden()
                    .controlSize(.mini)
                    .tint(Color(red: 0.90, green: 0.30, blue: 0.55))
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
            }
        }
    }
    
    // MARK: - Sender Avatar (initials in circle)
    
    private func senderAvatar(name: String, size: CGFloat) -> some View {
        let components = name.split(separator: " ")
        let initials: String
        if components.count >= 2 {
            initials = String(components[0].prefix(1) + components[1].prefix(1)).uppercased()
        } else {
            initials = String(name.prefix(2)).uppercased()
        }
        
        return ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.90, green: 0.25, blue: 0.50),
                            Color(red: 0.70, green: 0.18, blue: 0.65),
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            Text(initials)
                .font(.system(size: size * 0.38, weight: .bold, design: .rounded))
                .foregroundColor(.white)
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
    }
    
    // MARK: - Status
    
    private var statusSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            statusRow(
                icon: monitor.isMonitoring ? "antenna.radiowaves.left.and.right" : "antenna.radiowaves.left.and.right.slash",
                text: monitor.isMonitoring ? "Monitoring active" : "Monitoring paused",
                color: monitor.isMonitoring ? .green : .orange
            )
            
            statusRow(
                icon: permissionManager.isAccessibilityGranted ? "lock.open.fill" : "lock.fill",
                text: permissionManager.isAccessibilityGranted ? "Accessibility: Granted" : "Accessibility: Required",
                color: permissionManager.isAccessibilityGranted ? .green : .red
            )
            
            statusRow(
                icon: permissionManager.isTeamsRunning ? "app.badge.checkmark" : "app.badge",
                text: permissionManager.isTeamsRunning ? "Teams: Running" : "Teams: Not running",
                color: permissionManager.isTeamsRunning ? .green : .secondary
            )
            
            if let error = monitor.lastError {
                statusRow(
                    icon: "exclamationmark.triangle.fill",
                    text: error,
                    color: .orange
                )
            }
        }
        .padding(.horizontal, 8)
    }
    
    private func statusRow(icon: String, text: String, color: Color) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 10))
                .foregroundColor(color)
                .frame(width: 16)
            
            Text(text)
                .font(.system(size: 11))
                .foregroundColor(.secondary)
        }
    }
    
    // MARK: - Recent Notifications
    
    private var recentSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Recent")
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(.secondary)
                .textCase(.uppercase)
                .padding(.horizontal, 8)
            
            if queueManager.recentNotifications.isEmpty {
                HStack {
                    Spacer()
                    Text("No recent notifications")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                    Spacer()
                }
                .padding(.vertical, 8)
            } else {
                // Skip the first one (already shown in header)
                ForEach(Array(queueManager.recentNotifications.dropFirst().prefix(4))) { notification in
                    HStack(spacing: 8) {
                        // Sender initials avatar
                        senderAvatar(name: notification.senderName, size: 24)
                        
                        VStack(alignment: .leading, spacing: 1) {
                            Text(notification.senderName)
                                .font(.system(size: 11, weight: .bold))
                                .lineLimit(1)
                            Text(notification.messagePreview)
                                .font(.system(size: 10))
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                        }
                        
                        Spacer()
                        
                        Text(notification.relativeTimestamp)
                            .font(.system(size: 9))
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .contentShape(Rectangle())
                }
            }
        }
    }
    
    // MARK: - Actions
    
    private var actionsSection: some View {
        VStack(spacing: 2) {
            menuButton(icon: "bell.and.waves.left.and.right", title: "Test Notification") {
                onTestNotification()
            }
            
            menuButton(icon: "gear", title: "Settings...") {
                onOpenSettings()
            }
            
            Divider().padding(.vertical, 2)
            
            menuButton(icon: "power", title: "Quit TeamsGlow") {
                onQuit()
            }
        }
    }
    
    private func menuButton(icon: String, title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 12))
                    .frame(width: 16)
                
                Text(title)
                    .font(.system(size: 13))
                
                Spacer()
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

//
//  NotificationContentView.swift
//  TeamsGlow
//
//  Created by TeamsGlow on 23/09/26.
//

import SwiftUI

// MARK: - Notification Content View

/// Clean, minimal notification content — bold sender name, message below, timestamp, and action buttons.
struct NotificationContentView: View {
    let notification: TeamsNotification
    let settings: NotificationSettings
    let onOpenTeams: () -> Void
    let onDismiss: () -> Void
    
    @State private var isHoveringCard = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Top: avatar + sender name (bold) + timestamp
            HStack(spacing: 12) {
                // Avatar
                avatarView
                
                // Sender name — bold and prominent
                Text(notification.senderName)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                // Unread dot
                if notification.isUnread {
                    Circle()
                        .fill(Color(red: 0.95, green: 0.35, blue: 0.55))
                        .frame(width: 7, height: 7)
                        .shadow(color: Color(red: 0.95, green: 0.35, blue: 0.55).opacity(0.6), radius: 4)
                }
                
                Spacer()
                
                // Timestamp
                Text(notification.relativeTimestamp)
                    .font(.system(size: 11, weight: .regular))
                    .foregroundColor(.white.opacity(0.4))
            }
            
            // Message preview — directly below sender
            Text(notification.messagePreview)
                .font(.system(size: 13.5, weight: .regular))
                .foregroundColor(.white.opacity(0.7))
                .lineLimit(2)
                .lineSpacing(3)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // Action buttons
            HStack(spacing: 10) {
                Spacer()
                
                Button("Open Teams") {
                    onOpenTeams()
                }
                .buttonStyle(GradientButtonStyle(
                    gradient: LinearGradient(
                        colors: [
                            Color(red: 0.90, green: 0.25, blue: 0.50),
                            Color(red: 0.75, green: 0.20, blue: 0.65),
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    isCompact: true
                ))
                
                Button("Dismiss") {
                    onDismiss()
                }
                .buttonStyle(.subtle)
            }
            .opacity(isHoveringCard ? 1.0 : 0.8)
            .animation(.easeInOut(duration: 0.2), value: isHoveringCard)
        }
        .padding(DesignConstants.Card.padding)
        .onHover { hovering in
            isHoveringCard = hovering
        }
    }
    
    // MARK: - Avatar
    
    private var avatarView: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: avatarGradientColors,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            Text(initials)
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundColor(.white)
        }
        .frame(width: 38, height: 38)
        .clipShape(Circle())
        .overlay(
            Circle()
                .stroke(Color.white.opacity(0.15), lineWidth: 1)
        )
    }
    
    private var initials: String {
        let components = notification.senderName.split(separator: " ")
        if components.count >= 2 {
            return String(components[0].prefix(1) + components[1].prefix(1)).uppercased()
        }
        return String(notification.senderName.prefix(2)).uppercased()
    }
    
    /// Pinkish avatar gradients — deterministic per sender name.
    private var avatarGradientColors: [Color] {
        let hash = abs(notification.senderName.hashValue)
        let palettes: [[Color]] = [
            [Color(red: 0.90, green: 0.25, blue: 0.50), Color(red: 0.70, green: 0.18, blue: 0.65)],
            [Color(red: 0.85, green: 0.20, blue: 0.60), Color(red: 0.55, green: 0.22, blue: 0.85)],
            [Color(red: 0.95, green: 0.35, blue: 0.45), Color(red: 0.80, green: 0.20, blue: 0.60)],
            [Color(red: 0.75, green: 0.25, blue: 0.70), Color(red: 0.50, green: 0.20, blue: 0.85)],
            [Color(red: 0.88, green: 0.30, blue: 0.55), Color(red: 0.65, green: 0.15, blue: 0.75)],
        ]
        return palettes[hash % palettes.count]
    }
}

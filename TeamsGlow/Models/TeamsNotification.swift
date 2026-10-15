//
//  TeamsNotification.swift
//  TeamsGlow
//
//  Created by TeamsGlow on 23/09/26.
//

import Foundation

// MARK: - TeamsNotification

/// Represents a single Microsoft Teams notification detected by the system.
struct TeamsNotification: Identifiable, Equatable, Hashable {
    let id: UUID
    let senderName: String
    let title: String
    let messagePreview: String
    let timestamp: Date
    let conversationId: String?
    let avatarURL: URL?
    let isUnread: Bool
    let sourceApp: String
    
    init(
        id: UUID = UUID(),
        senderName: String,
        title: String = "Microsoft Teams",
        messagePreview: String,
        timestamp: Date = Date(),
        conversationId: String? = nil,
        avatarURL: URL? = nil,
        isUnread: Bool = true,
        sourceApp: String = "Microsoft Teams"
    ) {
        self.id = id
        self.senderName = senderName
        self.title = title
        self.messagePreview = messagePreview
        self.timestamp = timestamp
        self.conversationId = conversationId
        self.avatarURL = avatarURL
        self.isUnread = isUnread
        self.sourceApp = sourceApp
    }
    
    /// Human-readable relative time string (e.g. "2 min ago", "just now")
    var relativeTimestamp: String {
        let interval = Date().timeIntervalSince(timestamp)
        if interval < 10 {
            return "just now"
        } else if interval < 60 {
            return "\(Int(interval))s ago"
        } else if interval < 3600 {
            let minutes = Int(interval / 60)
            return "\(minutes) min ago"
        } else if interval < 86400 {
            let hours = Int(interval / 3600)
            return "\(hours)h ago"
        } else {
            let days = Int(interval / 86400)
            return "\(days)d ago"
        }
    }
    
    /// Generates a deduplication key based on sender and message content.
    var deduplicationKey: String {
        "\(senderName)|\(messagePreview)"
    }
    
    static func == (lhs: TeamsNotification, rhs: TeamsNotification) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

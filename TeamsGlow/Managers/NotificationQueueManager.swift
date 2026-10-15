//
//  NotificationQueueManager.swift
//  TeamsGlow
//
//  Created by TeamsGlow on 23/09/26.
//

import Foundation
import Combine

// MARK: - NotificationQueueManager

/// Manages a queue of incoming Teams notifications with deduplication and throttling.
@Observable
final class NotificationQueueManager {
    
    /// The notification currently being displayed.
    private(set) var currentNotification: TeamsNotification?
    
    /// The queue of pending notifications.
    private(set) var pendingQueue: [TeamsNotification] = []
    
    /// Recent notifications for display in the menu bar.
    private(set) var recentNotifications: [TeamsNotification] = []
    
    /// Maximum number of pending notifications.
    let maxQueueSize: Int = 5
    
    /// Maximum recent history size.
    let maxRecentSize: Int = 20
    
    /// Publisher for when a notification should be presented.
    let presentNotification = PassthroughSubject<TeamsNotification, Never>()
    
    /// Publisher for when the current notification should be dismissed.
    let dismissCurrent = PassthroughSubject<Void, Never>()
    
    private var cancellables = Set<AnyCancellable>()
    private var dismissTimer: Timer?
    private var isPresenting = false
    
    /// The settings controlling auto-dismiss behavior.
    private let settings: NotificationSettings
    
    init(settings: NotificationSettings) {
        self.settings = settings
    }
    
    // MARK: - Public API
    
    /// Enqueues a new notification. If nothing is currently shown, presents it immediately.
    func enqueue(_ notification: TeamsNotification) {
        // Check for duplicates in queue
        guard !pendingQueue.contains(where: { $0.deduplicationKey == notification.deduplicationKey }) else {
            return
        }
        
        // Also check against current notification
        if let current = currentNotification, current.deduplicationKey == notification.deduplicationKey {
            return
        }
        
        // Add to recent history
        recentNotifications.insert(notification, at: 0)
        if recentNotifications.count > maxRecentSize {
            recentNotifications.removeLast()
        }
        
        if !isPresenting {
            // Present immediately
            present(notification)
        } else {
            // Add to queue
            if pendingQueue.count < maxQueueSize {
                pendingQueue.append(notification)
            }
            // If queue is full, drop the oldest pending
            else {
                pendingQueue.removeFirst()
                pendingQueue.append(notification)
            }
        }
    }
    
    /// Dismisses the current notification and presents the next one in the queue, if any.
    func dismissCurrentNotification() {
        dismissTimer?.invalidate()
        dismissTimer = nil
        
        dismissCurrent.send()
        
        // Small delay before showing next notification
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.advanceQueue()
        }
    }
    
    /// Clears the entire queue and current notification.
    func clearAll() {
        dismissTimer?.invalidate()
        dismissTimer = nil
        currentNotification = nil
        pendingQueue.removeAll()
        isPresenting = false
        dismissCurrent.send()
    }
    
    // MARK: - Internal
    
    private func present(_ notification: TeamsNotification) {
        currentNotification = notification
        isPresenting = true
        presentNotification.send(notification)
        
        // Start auto-dismiss timer if enabled
        if settings.autoDismiss {
            dismissTimer?.invalidate()
            dismissTimer = Timer.scheduledTimer(
                withTimeInterval: settings.notificationDuration,
                repeats: false
            ) { [weak self] _ in
                self?.dismissCurrentNotification()
            }
        }
    }
    
    private func advanceQueue() {
        currentNotification = nil
        isPresenting = false
        
        guard !pendingQueue.isEmpty else { return }
        
        let next = pendingQueue.removeFirst()
        present(next)
    }
}

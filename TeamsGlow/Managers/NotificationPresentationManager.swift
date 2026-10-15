//
//  NotificationPresentationManager.swift
//  TeamsGlow
//
//  Created by TeamsGlow on 23/09/26.
//

import Foundation
import AppKit
import SwiftUI
import Combine

// MARK: - NotificationPresentationManager

/// Orchestrates the display of notification popup windows.
/// Bridges between the queue manager and the floating window system.
@Observable
final class NotificationPresentationManager {
    
    /// Whether a notification is currently being displayed.
    private(set) var isShowingNotification: Bool = false
    
    private let windowManager = WindowManager()
    private let settings: NotificationSettings
    private var cancellables = Set<AnyCancellable>()
    
    /// Callbacks for notification interactions.
    var onOpenTeams: ((TeamsNotification) -> Void)?
    var onDismiss: (() -> Void)?
    
    init(settings: NotificationSettings) {
        self.settings = settings
    }
    
    // MARK: - Public API
    
    /// Shows a notification popup for the given notification.
    func showNotification(_ notification: TeamsNotification) {
        // Play sound if enabled
        if settings.playSound {
            playNotificationSound()
        }
        
        // Create the popup view
        let popupView = NotificationPopupView(
            notification: notification,
            settings: settings,
            onOpenTeams: { [weak self] in
                self?.onOpenTeams?(notification)
                self?.hide()
            },
            onDismiss: { [weak self] in
                self?.onDismiss?()
                self?.hide()
            }
        )
        
        // Create and show the floating panel
        windowManager.createNotificationPanel(with: popupView)
        windowManager.showPanel()
        isShowingNotification = true
    }
    
    /// Hides the current notification popup.
    func hide() {
        windowManager.dismissPanel()
        isShowingNotification = false
    }
    
    // MARK: - Sound
    
    private func playNotificationSound() {
        // Try a clean, pleasant macOS system sound
        let soundNames = ["Glass", "Purr", "Pop", "Blow"]
        for name in soundNames {
            if let sound = NSSound(named: .init(name)) {
                sound.volume = 0.6
                sound.play()
                return
            }
        }
        // Ultimate fallback: system beep
        NSSound.beep()
    }
}

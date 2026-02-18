//
//  NotchViewModel.swift
//  PiIsland
//
//  State management for the window
//

import AppKit
import Combine
import SwiftUI

enum NotchContentType: Equatable {
    case sessions
    case chat(ManagedSession)
    case settings
    case usage

    var id: String {
        switch self {
        case .sessions: return "sessions"
        case .chat(let session): return "chat-\(session.id)"
        case .settings: return "settings"
        case .usage: return "usage"
        }
    }

    static func == (lhs: NotchContentType, rhs: NotchContentType) -> Bool {
        lhs.id == rhs.id
    }
}

@MainActor
@Observable
class NotchViewModel {
    // MARK: - Observable State

    var contentType: NotchContentType = .sessions

    // MARK: - Dependencies

    let sessionManager: SessionManager

    // MARK: - Private

    private var cancellables = Set<AnyCancellable>()
    private var currentChatSession: ManagedSession?

    /// Session that has an unread response
    private(set) var unreadSession: ManagedSession?

    /// Callback for when agent completes - used to trigger bounce animation
    var onAgentCompletedForBounce: (() -> Void)?

    // MARK: - Initialization

    init(sessionManager: SessionManager) {
        self.sessionManager = sessionManager
        setupAgentCompletionHandler()
    }

    private func setupAgentCompletionHandler() {
        sessionManager.onAgentCompleted = { [weak self] session in
            guard let self = self else { return }
            self.handleSessionActivity(session)
            // Trigger bounce animation in the view
            self.onAgentCompletedForBounce?()
        }

        sessionManager.onExternalSessionUpdated = { [weak self] session in
            guard let self = self else { return }
            self.handleSessionActivity(session)
        }

        sessionManager.onSessionResumed = { [weak self] oldSession, newSession in
            guard let self = self else { return }
            if case .chat(let current) = self.contentType, current.id == oldSession.id {
                self.contentType = .chat(newSession)
                self.currentChatSession = newSession
            }
        }
    }

    private func handleSessionActivity(_ session: ManagedSession) {
        // Mark session as having unread activity if we're not viewing it
        if case .chat(let currentSession) = self.contentType,
           currentSession.id == session.id {
            // Currently viewing this session, no unread
            return
        }

        // Mark as unread
        self.unreadSession = session
    }

    // MARK: - Actions

    /// Clear unread state for a session
    func clearUnread(for session: ManagedSession) {
        if unreadSession?.id == session.id {
            unreadSession = nil
        }
    }

    func showChat(for session: ManagedSession) {
        if case .chat(let current) = contentType, current.id == session.id {
            return
        }
        clearUnread(for: session)
        contentType = .chat(session)
        sessionManager.selectedSessionId = session.id
        currentChatSession = session
    }

    func exitChat() {
        currentChatSession = nil
        contentType = .sessions
    }

    func showSettings() {
        contentType = .settings
    }

    func exitSettings() {
        contentType = .sessions
    }

    func showUsage() {
        contentType = .usage
    }

    func exitUsage() {
        contentType = .sessions
    }
}

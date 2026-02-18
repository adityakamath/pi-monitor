//
//  NotchView.swift
//  PiIsland
//
//  The main window SwiftUI view
//

import SwiftUI

struct NotchView: View {
    let viewModel: NotchViewModel

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {
            headerRow
                .frame(height: 44)
                .background(Color(nsColor: .windowBackgroundColor))
            
            Divider()
            
            contentView
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .preferredColorScheme(.dark)
    }

    // MARK: - Header Row

    /// Current activity state from SessionManager (reactive, no polling)
    private var activityState: SessionManager.ActivityState {
        viewModel.sessionManager.activityState
    }

    private func activityColor(for state: SessionManager.ActivityState) -> Color {
        switch state {
        case .idle: return .gray
        case .thinking: return .blue
        case .executing: return .cyan
        case .externallyActive: return .yellow
        case .error: return .red
        }
    }

    @ViewBuilder
    private var headerRow: some View {
        HStack(spacing: 12) {
            // Left side - Pi logo with activity indicator
            HStack(spacing: 8) {
                PiLogo(
                    size: 18,
                    isAnimating: activityState.shouldAnimate,
                    isPulsing: false,
                    bounce: false,
                    color: activityColor(for: activityState)
                )
                
                Text("Pi Monitor")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.primary)
            }
            .padding(.leading, 12)
            
            Spacer()

            // Right side buttons
            openedHeaderButtons
        }
        .padding(.trailing, 12)
    }

    // MARK: - Header Buttons

    private var isChatView: Bool {
        if case .chat = viewModel.contentType { return true }
        return false
    }

    private var isUsageView: Bool {
        if case .usage = viewModel.contentType { return true }
        return false
    }

    @ViewBuilder
    private var openedHeaderButtons: some View {
        HStack(spacing: 8) {
            // Left Side: Navigation back button
            if case .chat = viewModel.contentType {
                NotchBackButton(title: "Sessions") {
                    viewModel.exitChat()
                }
            } else if case .settings = viewModel.contentType {
                NotchBackButton(title: "Sessions") {
                    viewModel.exitSettings()
                }
            } else if case .usage = viewModel.contentType {
                NotchBackButton(title: "Sessions") {
                    viewModel.exitUsage()
                }
            }

            // Session/Usage toggle button
            if !isChatView {
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        if case .usage = viewModel.contentType {
                            viewModel.exitUsage()
                        } else {
                            viewModel.showUsage()
                        }
                    }
                } label: {
                    Image(systemName: isUsageView ? "list.bullet" : "chart.bar.fill")
                        .font(.system(size: 13))
                        .foregroundStyle(isUsageView ? .white : .white.opacity(0.7))
                        .frame(width: 28, height: 28)
                        .background(Color.white.opacity(isUsageView ? 0.15 : 0.08))
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
                .contentShape(Rectangle())
                .help(isUsageView ? "Sessions" : "Usage Monitor")
            }

            // Settings button
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    if case .settings = viewModel.contentType {
                        viewModel.exitSettings()
                    } else {
                        viewModel.showSettings()
                    }
                }
            } label: {
                let isSettings = { if case .settings = viewModel.contentType { return true } else { return false } }()
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 14))
                    .foregroundStyle(isSettings ? .white : .white.opacity(0.7))
                    .frame(width: 28, height: 28)
                    .background(Color.white.opacity(isSettings ? 0.15 : 0.08))
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
            .contentShape(Rectangle())
            .help("Settings")
        }
    }

    // MARK: - Content View

    @ViewBuilder
    private var contentView: some View {
        Group {
            switch viewModel.contentType {
            case .sessions:
                SessionsListView(viewModel: viewModel, sessionManager: viewModel.sessionManager)
            case .chat(let session):
                SessionChatView(session: session)
            case .settings:
                SettingsContentView()
            case .usage:
                UsageNotchView()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Back Button

private struct NotchBackButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                action()
            }
        } label: {
            HStack(spacing: 4) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 10, weight: .semibold))
                Text(title)
                    .font(.system(size: 12, weight: .medium))
            }
            .foregroundStyle(.white.opacity(0.7))
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .background(Color.white.opacity(0.08))
            .clipShape(.rect(cornerRadius: 6))
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

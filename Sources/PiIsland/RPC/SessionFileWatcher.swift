//
//  SessionFileWatcher.swift
//  PiIsland
//
//  Watches the sessions directory for file changes to enable real-time updates
//

import Foundation
import OSLog

private let logger = Logger(subsystem: "com.pi-island", category: "SessionFileWatcher")

/// Watches the Pi sessions directory for changes
@MainActor
final class SessionFileWatcher {
    /// Callback when a session file is created
    var onSessionCreated: ((URL) -> Void)?

    /// Callback when a session file is modified
    var onSessionModified: ((URL) -> Void)?

    /// Callback when a session file is deleted
    var onSessionDeleted: ((URL) -> Void)?

    // MARK: - Private

    private var directorySource: DispatchSourceFileSystemObject?
    private var fileDescriptor: Int32 = -1
    private var isWatching = false
    private var knownFiles: [String: Date] = [:]
    private var pollTimer: Timer?

    private let sessionsDirectory: URL

    // MARK: - Initialization

    init() {
        self.sessionsDirectory = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent(".pi/agent/sessions")
    }

    // MARK: - Public API

    /// Start watching the sessions directory
    func startWatching() {
        guard !isWatching else { return }

        // Ensure directory exists
        guard FileManager.default.fileExists(atPath: sessionsDirectory.path) else {
            logger.warning("Sessions directory does not exist: \(self.sessionsDirectory.path)")
            return
        }

        // Scan initial state
        scanDirectory()

        // Set up directory monitoring using DispatchSource
        setupDirectoryWatch()

        // Also set up a polling timer for deeper file change detection
        // (DispatchSource only detects directory-level changes, not file content changes)
        setupPollingTimer()

        isWatching = true
        logger.info("Started watching sessions directory")
    }

    /// Stop watching
    func stopWatching() {
        pollTimer?.invalidate()
        pollTimer = nil

        directorySource?.cancel()
        directorySource = nil

        if fileDescriptor >= 0 {
            close(fileDescriptor)
            fileDescriptor = -1
        }

        isWatching = false
        logger.info("Stopped watching sessions directory")
    }

    // MARK: - Directory Watching

    private func setupDirectoryWatch() {
        fileDescriptor = open(sessionsDirectory.path, O_EVTONLY)
        guard fileDescriptor >= 0 else {
            logger.error("Failed to open directory for monitoring")
            return
        }

        let source = DispatchSource.makeFileSystemObjectSource(
            fileDescriptor: fileDescriptor,
            eventMask: [.write, .delete, .rename, .extend],
            queue: .main
        )

        source.setEventHandler { [weak self] in
            Task { @MainActor in
                self?.handleDirectoryChange()
            }
        }

        source.setCancelHandler { [weak self] in
            if let fd = self?.fileDescriptor, fd >= 0 {
                close(fd)
                self?.fileDescriptor = -1
            }
        }

        source.resume()
        directorySource = source
    }

    private func setupPollingTimer() {
        // Poll every 1 second for file content changes
        pollTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.checkForFileChanges()
            }
        }
    }

    // MARK: - Change Detection

    private func handleDirectoryChange() {
        checkForFileChanges()
    }

    private func checkForFileChanges() {
        let currentFiles = scanSessionFiles()

        // Check for new files
        for (path, modDate) in currentFiles {
            if knownFiles[path] == nil {
                // New file
                logger.info("New session file detected: \(path)")
                onSessionCreated?(URL(fileURLWithPath: path))
            } else if let oldDate = knownFiles[path], modDate > oldDate {
                // Modified file
                logger.info("Session file modified: \(path)")
                onSessionModified?(URL(fileURLWithPath: path))
            }
        }

        // Check for deleted files
        for path in knownFiles.keys {
            if currentFiles[path] == nil {
                logger.info("Session file deleted: \(path)")
                onSessionDeleted?(URL(fileURLWithPath: path))
            }
        }

        knownFiles = currentFiles
    }

    private func scanDirectory() {
        knownFiles = scanSessionFiles()
        logger.info("Scanned \(self.knownFiles.count) session files")
    }

    private func scanSessionFiles() -> [String: Date] {
        var files: [String: Date] = [:]

        guard let projectDirs = try? FileManager.default.contentsOfDirectory(
            at: sessionsDirectory,
            includingPropertiesForKeys: [.isDirectoryKey]
        ) else {
            return files
        }

        for projectDir in projectDirs {
            guard projectDir.hasDirectoryPath else { continue }

            if let sessionFiles = try? FileManager.default.contentsOfDirectory(
                at: projectDir,
                includingPropertiesForKeys: [.contentModificationDateKey]
            ) {
                for file in sessionFiles where file.pathExtension == "jsonl" {
                    if let attrs = try? FileManager.default.attributesOfItem(atPath: file.path),
                       let modDate = attrs[.modificationDate] as? Date {
                        files[file.path] = modDate
                    }
                }
            }
        }

        return files
    }
}

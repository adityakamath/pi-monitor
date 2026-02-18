# Pi Monitor

A native macOS window application for the [Pi Coding Agent](https://pi.dev). Pi Monitor provides a clean desktop interface for managing and interacting with your Pi agent sessions.

> **Note:** Screenshots coming soon! The app features a clean macOS window with session management, chat interface, and real-time status indicators.

> **Looking for Pi Island?** The original Dynamic Island implementation is preserved in the [`island` branch](https://github.com/adityakamath/pi-monitor/tree/island).

## Features

### Core
- **Native Window Interface** - Standard macOS window with resizable, draggable interface
- **Full Chat Interface** - Send messages, receive streaming responses
- **Real-time Status** - See thinking, executing, idle states at a glance
- **Tool Execution** - Watch tool calls with live output streaming
- **Native macOS** - Built with SwiftUI, optimized for macOS 14+

### Session Management
- **Multi-session Support** - Manage multiple Pi sessions simultaneously
- **Session Resume** - Click any historical session to resume where you left off
- **Historical Sessions** - Browse recent sessions from ~/.pi/agent/sessions/
- **External Activity Detection** - Yellow indicator for sessions active in other terminals
- **Live Session Indicators** - Visual indicators for connected sessions

### Model & Provider
- **Model Selector** - Dropdown to switch between available models
- **Provider Grouping** - Models organized by provider
- **Thinking Level** - Adjustable reasoning depth for supported models

### Settings
- **Launch at Login** - Start Pi Monitor automatically
- **Show in Dock** - Toggle dock icon visibility
- **Menu Bar Icon** - Always visible in menu bar with options to open or quit the app

### UI Polish
- **Clean Layout** - Standard window with header and content area
- **Proper Padding** - 16pt spacing for comfortable viewing
- **Auto-scroll** - Chat scrolls to latest message
- **Dark Mode** - Optimized for dark mode interface

## Architecture

Pi Monitor spawns Pi in RPC mode (`pi --mode rpc`) and communicates via stdin/stdout JSON protocol:

```
Pi Monitor (macOS app)
    |
    |--- stdin: Commands (prompt, switch_session, get_messages, etc.)
    |--- stdout: Events (message streaming, tool execution, etc.)
    |
    v
pi --mode rpc (child process)
```

## Requirements

- macOS 14.0+
- Pi Coding Agent installed (`npm install -g @mariozechner/pi-coding-agent`)
- Valid API key for your preferred provider

## Building

### Development (Debug)

```bash
swift build
.build/debug/PiMonitor
```

### Production (App Bundle)

Create a proper macOS `.app` bundle with icon and LSUIElement support:

```bash
./scripts/bundle.sh
```

This generates `Pi Monitor.app` with:
- Proper app icon from `pi-monitor.icon` (Xcode 15+ Icon Composer format)
- `LSUIElement: true` - no dock icon by default, no terminal on launch
- All resources bundled correctly
- Login shell environment extraction (works when launched from Finder)

### Creating a DMG for Distribution

To distribute the app with proper codesigning (to avoid Gatekeeper warnings), you should sign it with a Developer ID Application certificate and notarize it with Apple.

Find your signing identity:
```bash
security find-identity -p codesigning -v
```

Build and sign:
```bash
# Build + ad-hoc sign + create DMG (for local/trusted distribution)
./scripts/bundle.sh --sign --dmg

# Build + sign with Developer ID + create DMG (for public distribution)
./scripts/bundle.sh --sign-id "Developer ID Application: Your Name (TEAM_ID)" --dmg
```

This creates `Pi-Monitor-0.0.1.dmg`. To completely remove the "Apple could not verify..." warning for other users, you must notarize the DMG:

```bash
export APPLE_ID="your@email.com"
export APPLE_PASSWORD="app-specific-password"
export APPLE_TEAM_ID="YOUR_TEAM_ID"

./scripts/notarize.sh Pi-Monitor-0.0.1.dmg
```

You can verify the result with:
```bash
spctl -a -vv -t install "Pi-Monitor-0.0.1.dmg"
```

**Note:** Without a Developer ID certificate and notarization, recipients may see a "damaged" error or a security warning. They can bypass this by right-clicking the app and selecting **Open**, or by running:
```bash
xattr -cr "/Applications/Pi Monitor.app"
```

### Installation

From DMG:
1. Open `Pi-Monitor-0.0.1.dmg`
2. Drag `Pi Monitor` to the `Applications` folder

Or manually:
```bash
cp -R "Pi Monitor.app" /Applications/
```

### Auto-launch at Login

1. Open **System Settings > General > Login Items**
2. Click **+** and add **Pi Monitor** from Applications

The app will launch silently without opening a terminal window.

## Usage

1. Launch Pi Monitor from Applications or via the menu bar icon
2. The window will open centered on your screen
3. Click a session to open chat, or click the settings icon for configuration
4. Type messages in the input bar to interact with Pi

### Menu Bar

Pi Monitor includes a menu bar icon (Pi logo) in the top-right of your screen:
- **Open Pi Monitor** (⌘O) - Brings the window to front (useful when dock icon is hidden)
- **Quit Pi Monitor** (⌘Q) - Exits the application

The menu bar icon is always visible, even when "Show in Dock" is disabled in settings.

### Status Indicators

- **Gray** - Disconnected / Historical session
- **Yellow** - Externally active (modified recently)
- **Green** - Connected and idle
- **Blue** - Thinking
- **Cyan** - Executing tool
- **Red** - Error

## File Structure

```
pi-monitor/
  Package.swift
  Sources/
    PiMonitor/
      PiMonitorApp.swift          # Entry point, AppDelegate, StatusBarController
      Core/
        AppVersion.swift           # Version management
        NotchViewModel.swift       # State management
        UpdateChecker.swift        # Update checking (disabled)
      UI/
        NotchView.swift            # Main SwiftUI view
        NotchWindowController.swift # Window controller
        PiLogo.swift               # Pi logo shape
        SettingsContentView.swift  # Settings panel
        SessionsListView.swift     # Sessions list
      RPC/
        PiRPCClient.swift          # RPC process management
        RPCChatView.swift          # Chat UI components
        RPCTypes.swift             # Protocol types
        SessionManager.swift       # Session management
      UsageMonitor/
        Services/
          UsageMonitorService.swift # Usage tracking
        Views/
          UsageNotchView.swift      # Usage display
```

## Version

Current version: **0.0.1**

## License

MIT

# Pi Island

A native macOS Dynamic Island-style interface for the [Pi Coding Agent](https://github.com/badlogic/pi-mono). Pi Island provides a floating notch UI that gives you a glanceable view of your Pi agent's status with full chat capabilities.

## Features

- **Floating Notch UI** - Sits at the top of your screen, mimicking Dynamic Island
- **Full Chat Interface** - Send messages, receive streaming responses
- **Real-time Status** - See thinking, executing, idle states at a glance
- **Tool Execution** - Watch tool calls with live output streaming
- **Model Control** - Switch models, adjust thinking level
- **Native macOS** - Built with SwiftUI, optimized for macOS

## Architecture

Pi Island spawns Pi in RPC mode (`pi --mode rpc`) and communicates via stdin/stdout JSON protocol. This provides full bidirectional control:

```
Pi Island (macOS app)
    |
    |--- stdin: Commands (prompt, abort, set_model, etc.)
    |--- stdout: Events (message streaming, tool execution, etc.)
    |
    v
pi --mode rpc (child process)
```

## Requirements

- macOS 14.0+
- Pi Coding Agent installed (`npm install -g @mariozechner/pi-coding-agent`)
- Valid API key or subscription for your preferred provider

## Building

```bash
cd PiIsland
swift build
.build/debug/PiIsland
```

## Usage

1. Launch Pi Island
2. Hover over the notch area at the top of your screen to expand
3. Type messages in the input bar to interact with Pi
4. Click the status bar icon for quick actions (new session, cycle model, quit)

### Keyboard Shortcuts

- **Enter** - Send message
- **Escape** - Abort current operation (when streaming)

### Status Indicators

- **Gray** - Idle/Disconnected
- **Blue** - Thinking
- **Green** - Executing tool
- **Red** - Error

## Files

```
PiIsland/
  PiIsland/
    PiIslandApp.swift      # App entry, window controller, notch UI
    RPC/
      PiRPCClient.swift    # Process management, JSON protocol
      RPCSession.swift     # High-level session state management
      RPCChatView.swift    # Chat UI components
      RPCTypes.swift       # Command and event types
```

## License

MIT

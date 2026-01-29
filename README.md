# Pi Island

A native macOS "Dynamic Island" style interface for the [Pi Coding Agent](https://github.com/badlogic/pi-mono). Provides glanceable status, permission gating, and cost monitoring without leaving your IDE.

## Overview

Pi Island consists of two components:

1. **Native macOS App** (`PiIsland/`) - A Swift/SwiftUI floating window that sits near the notch/menu bar
2. **Pi Extension** (`extension/pi-island.ts`) - Bridges the Pi Agent to the native app via Unix Domain Socket

## Quick Start

### 1. Build and Run the macOS App

```bash
cd PiIsland
swift build
.build/debug/PiIsland
```

### 2. Install the Extension

Copy the extension to your Pi extensions directory:

```bash
cp extension/pi-island.ts ~/.pi/agent/extensions/
```

Or for project-local installation:

```bash
mkdir -p .pi/extensions
cp extension/pi-island.ts .pi/extensions/
```

### 3. Run Pi

```bash
pi
```

The extension will automatically connect to Pi Island when both are running.

## Testing the Connection

To test the socket connection without running Pi:

```bash
# Start Pi Island first
cd PiIsland && .build/debug/PiIsland

# In another terminal, run the test script
node tests/test-bridge.mjs
```

You should see connection logs in the Pi Island console output.

## Architecture

```
+---------------------+       +---------------------------+
| macOS Environment   |       | Pi Agent Process (Node)   |
|                     |       |                           |
| +---------------+   |  IPC  | +---------------------+   |
| | Pi Island App |<=========>| | Pi-Bridge Ext       |   |
| | (Swift/SwiftUI)|  Socket  | | (TypeScript)        |   |
| +---------------+   |       | +---------------------+   |
|       ^             |       |           ^               |
|       |             |       |           |               |
| +---------------+   |       | +---------------------+   |
| | Window Server |   |       | | Core Runtime        |   |
| +---------------+   |       | +---------------------+   |
+---------------------+       +---------------------------+
```

## IPC Protocol (JSON-Lines)

| Direction      | Type        | Payload Example                           | Description              |
|----------------|-------------|-------------------------------------------|--------------------------|
| Agent -> UI    | `HANDSHAKE` | `{ "pid": 1234, "project": "/src" }`      | Session initiation       |
| Agent -> UI    | `STATUS`    | `{ "state": "thinking", "cost": 0.05 }`   | State update             |
| Agent -> UI    | `TOOL_REQ`  | `{ "id": "req_1", "cmd": "rm -rf /" }`    | Permission request       |
| UI -> Agent    | `TOOL_RES`  | `{ "id": "req_1", "allow": false }`       | Permission verdict       |
| UI -> Agent    | `INTERRUPT` | `{}`                                      | Stop current generation  |

## Development Status

See [PLAN.md](PLAN.md) for the implementation roadmap.

### Phase 1: The Bridge (Current)
- [x] Swift Socket Server
- [x] TypeScript Connector (test script)
- [x] Pi Extension scaffolding

### Phase 2: The Sentinel
- [ ] Event Streaming
- [ ] Blocking Mechanism
- [ ] Grant Loop

### Phase 3: The Interface
- [ ] Floating Window polish
- [ ] Hover Physics & Click-Through
- [ ] State Visualization

### Phase 4: Integration & Hardening
- [ ] Robust Reconnection
- [ ] Installer Script
- [ ] Documentation

## License

MIT

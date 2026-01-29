/**
 * Test script to validate Unix Domain Socket connection to Pi Island.
 * Run with: node tests/test-bridge.mjs
 */
import * as net from "node:net";

const SOCKET_PATH = "/tmp/pi-island.sock";

console.log("[Test] Connecting to Pi Island...");

const client = net.createConnection(SOCKET_PATH, () => {
  console.log("[Test] Connected!");

  // Send handshake
  const handshake = {
    type: "HANDSHAKE",
    payload: {
      pid: process.pid,
      project: process.cwd(),
    },
  };
  client.write(JSON.stringify(handshake) + "\n");
  console.log("[Test] Sent handshake");

  // Send status update
  setTimeout(() => {
    const status = {
      type: "STATUS",
      payload: {
        state: "thinking",
        cost: 0.05,
      },
    };
    client.write(JSON.stringify(status) + "\n");
    console.log("[Test] Sent status: thinking");
  }, 500);

  // Send tool start
  setTimeout(() => {
    const toolStart = {
      type: "TOOL_START",
      payload: {
        tool: "bash",
        input: { command: "ls -la" },
      },
    };
    client.write(JSON.stringify(toolStart) + "\n");
    console.log("[Test] Sent tool start: bash");
  }, 1000);

  // Send tool end
  setTimeout(() => {
    const toolEnd = {
      type: "TOOL_END",
      payload: {
        tool: "bash",
        isError: false,
      },
    };
    client.write(JSON.stringify(toolEnd) + "\n");
    console.log("[Test] Sent tool end");
  }, 1500);

  // Send back to idle
  setTimeout(() => {
    const status = {
      type: "STATUS",
      payload: {
        state: "idle",
      },
    };
    client.write(JSON.stringify(status) + "\n");
    console.log("[Test] Sent status: idle");
  }, 2000);

  // Close after 3 seconds
  setTimeout(() => {
    console.log("[Test] Closing connection");
    client.end();
  }, 3000);
});

client.on("data", (data) => {
  console.log("[Test] Received:", data.toString().trim());
});

client.on("error", (err) => {
  console.error("[Test] Connection error:", err.message);
  console.log("[Test] Is Pi Island running?");
  process.exit(1);
});

client.on("close", () => {
  console.log("[Test] Connection closed");
  process.exit(0);
});

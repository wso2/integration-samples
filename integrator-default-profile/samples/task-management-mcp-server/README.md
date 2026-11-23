# Task Management MCP Server

An MCP server over a small task board, for trying out MCP on the platform. It carries no
authentication and no configuration of its own: deploy it, then secure the endpoint it is
published on from the integration's settings, and the same server runs unchanged under
whichever scheme you choose.

## Tools

| Tool | What it does |
| --- | --- |
| `listTasks` | Lists the board, or only the tasks in one status |
| `createTask` | Adds a task, open and at medium priority unless told otherwise |
| `setTaskStatus` | Moves a task to `open`, `in-progress` or `done` |
| `assignTask` | Gives a task to someone |

## The board

Four tasks are seeded in memory. There is no database: each replica keeps its own copy, and a
restart returns to the seeded four. That keeps the sample to one deployable with nothing to
provision, which is the point of it — a real integration would write to a store.

## Running it locally

```bash
bal run
```

The server listens on port 9090 and serves MCP at `/mcp`. Point any MCP client at
`http://localhost:9090/mcp`, or call it directly:

```bash
curl -X POST http://localhost:9090/mcp \
  -H 'Content-Type: application/json' \
  -H 'Accept: application/json, text/event-stream' \
  -d '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2025-06-18","capabilities":{},"clientInfo":{"name":"curl","version":"1"}}}'
```

The response carries an `mcp-session-id` header; send it back on `tools/list` and `tools/call`.

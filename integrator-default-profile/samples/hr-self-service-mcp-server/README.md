# HR Self-Service MCP Server

## Description

A standalone MCP (Model Context Protocol) server, written in Ballerina, that lets employees, managers and HR admins manage leave through any MCP client. There is no AI agent and no external system: sample data is loaded from `data.json` into memory at startup, and all changes stay in memory (they are lost on restart).

The server is an **OAuth 2.0 protected resource** that follows the MCP authorization specification. It works with any OAuth 2.0 / OIDC provider that issues **JWT access tokens**; nothing is tied to a specific provider.

## Prerequisites

- An OAuth 2.0 / OIDC identity provider that can issue JWT access tokens (for example Keycloak, Okta, Auth0, Microsoft Entra ID or Asgardeo), set up as described below.
- An MCP client that implements the MCP authorization flow.

### 1. Register the API (resource) and its scopes

Define these four scopes on the API / resource server that represents this MCP server:

| Scope | Meaning |
|-------|---------|
| `hr:read` | Read your own profile, leave balances and leave requests |
| `hr:write` | Apply for and cancel your own leave |
| `hr:approve` | Approve or reject leave of your direct reports |
| `hr:read:all` | Read any employee's data (HR admins) |

Make the access tokens for this API:

- **JWT** (not opaque tokens), signed with a key published at a JWKS endpoint.
- Issued with the **audience** (`aud`) you will set in `oauthAudience`. If the provider supports resource indicators (RFC 8707), use the MCP server URL (`<serverPublicUrl>/mcp`). Otherwise use the API identifier you registered.
- Carrying the granted scopes in a claim (`scope` as a space-separated string, or `scp` on some providers; set `oauthScopeClaim` accordingly).
- Carrying the user's identity in a claim such as `email`. Some providers do not put `email` in access tokens by default; add it as a custom or optional claim, or set `userClaim` to another claim (for example `preferred_username` or `sub`) that matches an employee email or id.

### 2. Decide which users get which scopes

| Users | Scopes to grant |
|-------|-----------------|
| Every employee | `hr:read`, `hr:write` |
| Managers | `hr:read`, `hr:write`, `hr:approve` |
| HR admins | `hr:read`, `hr:write`, `hr:read:all` (add `hr:approve` if the admin also manages people; in the sample data the HR admin manages the two managers) |

Use groups or roles at the provider to map users to scopes, as your provider allows. Users only get the scopes they are allowed to; the MCP client requests scopes and the provider issues the intersection.

### 3. Create a client for MCP clients

Create a **public** client (no client secret) for the MCP client application:

- Grant: authorization code with **PKCE**.
- Redirect URIs: the ones your MCP client uses (check your MCP client's documentation).
- Allowed scopes: `hr:read`, `hr:write`, `hr:approve`, `hr:read:all`.
- If your MCP client supports Dynamic Client Registration (RFC 7591) and your provider allows it, no manual client is needed; otherwise enter the client id in the MCP client.

### 4. Create the test users and update the sample data

`data.json` uses placeholder emails. Replace them with the emails of your test users (keep them in sync with the `email` claim of the tokens):

| Employee | Placeholder email | Role in the sample data |
|----------|-------------------|-------------------------|
| Maya Lindqvist (E001) | `hr.admin@example.com` | HR admin, manages E002 and E003 |
| Daniel Okafor (E002) | `eng.manager@example.com` | Engineering manager, manages E004 and E005 |
| Sofia Marchetti (E003) | `sales.manager@example.com` | Sales manager, manages E006 |
| Kenji Watanabe (E004) | `engineer1@example.com` | Employee |
| Amara Nwosu (E005) | `engineer2@example.com` | Employee |
| Lucas Fernandes (E006) | `sales.rep@example.com` | Employee |

The sample leave requests are dated around late 2026 and early 2027. If you run the server much later, move the pending request dates forward so they are still in the future.

## Configuration

Provide the configuration through a `Config.toml` file in the project root:

```toml
serverPublicUrl = "<SERVER_PUBLIC_URL>"
oauthIssuer = "<OAUTH_ISSUER>"
oauthJwksUrl = "<OAUTH_JWKS_URL>"
oauthAudience = "<SERVER_PUBLIC_URL>/mcp"
oauthScopeClaim = "scope"
userClaim = "email"
```

| Configurable | Required | Description |
|--------------|----------|-------------|
| `serverPublicUrl` | yes | Public base URL of this server, without a path, for example `https://hr-mcp.example.com`. The MCP endpoint is `<serverPublicUrl>/mcp`; this value is the resource identifier published in the metadata |
| `oauthIssuer` | yes | Token issuer; must equal the `iss` claim and is published as the authorization server |
| `oauthJwksUrl` | yes | JWKS endpoint used to verify token signatures |
| `oauthAudience` | yes | Expected `aud` of the access tokens |
| `oauthScopeClaim` | no (default `scope`) | Token claim holding the scopes, for example `scp` |
| `userClaim` | no (default `email`) | Token claim that identifies the user; matched to an employee email or id (case-insensitive) |

## Usage Instructions

1. Run the integration from the project root, so that `data.json` is found. The server listens on port `9091`, and the MCP endpoint is `<serverPublicUrl>/mcp`. Per the MCP authorization specification, a production deployment must be served over HTTPS (set `serverPublicUrl` to the public HTTPS URL, for example behind a reverse proxy).
2. Use an MCP client that implements the MCP authorization flow (for example MCP Inspector, VS Code, Claude Desktop or Claude Code via remote MCP) and connect it to `<serverPublicUrl>/mcp`.
3. Try the scenarios below.

### No token

Call the endpoint without a token:

```
curl -i -X POST <SERVER_PUBLIC_URL>/mcp \
  -H "Content-Type: application/json" -H "Accept: application/json, text/event-stream" \
  -d '{"jsonrpc":"2.0","id":1,"method":"tools/list"}'
```

Expected: `401 Unauthorized` with a `WWW-Authenticate: Bearer ...` header that references the protected resource metadata. Then check the metadata:

```
curl <SERVER_PUBLIC_URL>/.well-known/oauth-protected-resource/mcp
```

Expected: JSON with `resource`, `authorization_servers` (your issuer) and `scopes_supported`. An OAuth-capable client uses this to start the sign-in.

### Employee (for example `engineer1@example.com`, scopes `hr:read hr:write`)

1. Connect the MCP client and sign in as the employee through your identity provider.
2. `getMyProfile`: returns Kenji Watanabe with manager Daniel Okafor.
3. `getLeaveBalance`: annual 20 entitled, 5 used, 4 pending, 11 available.
4. `listLeaveRequests` with `status` = `pending`: returns `L-1002`.
5. `getLeaveBalance` with `employeeId` = `engineer2@example.com`: fails with **403 insufficient_scope**, requesting `hr:read:all`. The client can then ask the user to grant the additional scope.
6. `applyForLeave` for a future weekday range: succeeds and returns a pending request. Try a past date, a weekend start, overlapping dates, or more days than available to see each validation error.
7. `cancelLeaveRequest` with the new request id: succeeds. Cancelling an approved request fails.
8. `listPendingApprovals`: fails with **403 insufficient_scope** (`hr:approve` needed).

### Manager (for example `eng.manager@example.com`, scopes `hr:read hr:write hr:approve`)

1. `listPendingApprovals`: returns `L-1002` (Kenji) and `L-1004` (Amara); not `L-1006`, which belongs to the sales team.
2. `approveLeaveRequest` with `L-1002`: succeeds; Kenji's used annual days increase by 4.
3. `rejectLeaveRequest` with `L-1004` and no comment: fails because a comment is required; with a comment it succeeds.
4. `approveLeaveRequest` with `L-1006`: fails because Lucas does not report to this manager.
5. `getLeaveBalance` for another employee: **403 insufficient_scope** for `hr:read:all`.

### HR admin (for example `hr.admin@example.com`, scopes `hr:read hr:write hr:read:all`, plus `hr:approve` for approvals)

1. `getLeaveBalance` with `employeeId` = `engineer1@example.com`: succeeds.
2. `listLeaveRequests` with `employeeId` = `sales.rep@example.com`: returns `L-1005` (rejected) and `L-1006` (pending).
3. `listPendingApprovals` (with `hr:approve`): returns `L-1007` from Daniel Okafor, who reports to the HR admin. The admin cannot approve requests of employees who do not report to them, such as `L-1006`.

## How It Works

1. An MCP client calls `POST /mcp` without a token. The server answers `401` with a `WWW-Authenticate` challenge that points to its **protected resource metadata** (RFC 9728), served at `/.well-known/oauth-protected-resource/mcp` on the same port.
2. The metadata names the identity provider (authorization server) and the supported scopes. The client discovers the provider's own metadata, registers or uses a configured client, and signs the user in through the organization's identity provider (authorization code flow with PKCE).
3. The client calls the server with `Authorization: Bearer <access token>`. The server validates the JWT: signature (JWKS), issuer, audience and expiry.
4. Each tool declares the scope it needs. A token without it gets `403` with `error="insufficient_scope"` and the missing scope, so the client can ask the user for it.
5. The signed-in user is identified from a token claim (`email` by default) and matched to an employee in the data (by email, or by employee id).

With `hr:read` a user can read only their own data. If they pass another employee's id or email to `getLeaveBalance` or `listLeaveRequests`, the server requires `hr:read:all` and, when it is missing, answers `403 insufficient_scope` with `scope="hr:read:all"`. The scope `hr:read:all` implies `hr:read`, so an HR admin token with only `hr:read:all` also works for own data. Approvals need `hr:approve` **and** the requester must report directly to the caller; otherwise the call fails.

It implements eight tools:

| Tool | Scope | Notes |
|------|-------|-------|
| `getMyProfile` | `hr:read` | Name, title, department, manager, direct reports |
| `getLeaveBalance` | `hr:read` (own), `hr:read:all` (another employee) | Annual, sick, personal: entitled, used, pending, available. Optional `employeeId` (id or email) |
| `listLeaveRequests` | `hr:read` (own), `hr:read:all` (another employee) | Optional `employeeId` and `status` (pending, approved, rejected, cancelled) |
| `applyForLeave` | `hr:write` | `leaveType`, `startDate`, `endDate` (YYYY-MM-DD), optional `reason` |
| `cancelLeaveRequest` | `hr:write` | Own pending requests only |
| `listPendingApprovals` | `hr:approve` | Pending requests of the caller's direct reports |
| `approveLeaveRequest` | `hr:approve` | Requester must report to the caller; optional `comment` |
| `rejectLeaveRequest` | `hr:approve` | Requester must report to the caller; `comment` is required |

Leave rules for `applyForLeave`:

- Start and end dates must be working days (Monday to Friday); weekends in between are not counted. Public holidays are not modelled.
- The start date must be today (UTC) or later, and the end date must not be before the start date.
- The working days requested must not exceed the available balance (`entitled - used - pending`) of that leave type.
- The dates must not overlap the employee's pending or approved requests.
- The new request is created as `pending`. The balance's `used` count grows when a manager approves it.

Project files:

- `main.bal`: MCP service (the tools), OAuth protection and data loading at startup
- `functions.bal`: identity resolution, scope checks, leave rules and in-memory store
- `types.bal`: data and result types
- `config.bal`: configurable values
- `data.json`: sample employees, balances and leave requests

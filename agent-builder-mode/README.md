# AI Chat Agent

Template for a chattable AI agent using an LLM, prompts and tools.

## Layout

```
ai-chat-agent/
└── PROJECT_HANDLE/          # workspace root (only when createAsWorkspace is true)
    ├── Ballerina.toml       # [workspace] title + packages
    ├── .vscode/
    │   └── settings.json    # ballerina.isBI
    └── PACKAGE_NAME/        # integration package
        ├── Ballerina.toml
        ├── main.bal         # chat service
        ├── agents.bal       # agent definition
        ├── connections.bal
        ├── automation.bal
        ├── config.bal
        ├── data_mappings.bal
        ├── functions.bal
        ├── types.bal
        ├── .gitignore
        └── .vscode/
            ├── settings.json    # ballerina.isBI
            └── launch.json      # Ballerina debug configurations
```

`Config.toml` is deliberately absent — it is ignored repo-wide (root
`.gitignore` `**/Config.toml`) and generated per project, since it carries the
model provider access token.

The `.vscode/` files are tracked even though the root `.gitignore` excludes
`.vscode`: they were added with `git add -f`, which keeps them tracked from then
on. **Any new file added under these `.vscode/` directories needs `git add -f`
too**, or it will be silently ignored.

## Placeholders

Substitution is a plain string replace applied to **both directory names and
file contents**, so the tooling must rename the placeholder directories as well
as rewrite the file bodies.

Placeholders are named after the `createBIProject` payload fields, uppercased,
so the mapping is 1:1 with the call site and needs no translation table.

| Placeholder | `createBIProject` field | Used in |
| --- | --- | --- |
| `PROJECT_HANDLE` | `projectHandle` | workspace root directory name |
| `WORKSPACE_NAME` | `workspaceName` | root `Ballerina.toml` &rarr; `workspace.title` |
| `PACKAGE_NAME` | `packageName` | package directory name; root `Ballerina.toml` &rarr; `workspace.packages`; package `Ballerina.toml` &rarr; `package.name` |
| `PROJECT_NAME` | `projectName` | package `Ballerina.toml` &rarr; `package.title` |
| `ORG_HANDLE` | `orgHandle` | package `Ballerina.toml` &rarr; `package.org` |
| `VERSION` | `version` | package `Ballerina.toml` &rarr; `package.version` |
| `AGENT_NAME` | *(not in this payload — see below)* | `main.bal` &rarr; service path and `<agent>.run(...)` call; `agents.bal` &rarr; agent variable and `systemPrompt.role` |

Worked example for form input `projectName` / `integrationName` / `agentName`:

| Placeholder | Value |
| --- | --- |
| `PROJECT_HANDLE` | `projectname` |
| `WORKSPACE_NAME` | `projectName` |
| `PACKAGE_NAME` | `integrationname` |
| `PROJECT_NAME` | `integrationName` |
| `ORG_HANDLE` | e.g. `kauminigunasinghe` |
| `VERSION` | `0.1.0` |
| `AGENT_NAME` | `agentName` |

### Notes

- **`PROJECT_NAME` holds the integration name.** The payload passes
  `projectName: formData.integrationName.trim()`, so this token is the
  *integration* name — the project (workspace) display name is `WORKSPACE_NAME`.
  The token names follow the payload, not the form labels.
- **`AGENT_NAME` is not part of `createBIProject`.** The agent name never reaches
  that call, so whichever step scaffolds the agent has to substitute it in
  `main.bal` and `agents.bal`.
- **`createAsWorkspace: false`** means no workspace is created. In that case the
  `PROJECT_HANDLE/` level and its `Ballerina.toml` do not apply, and
  `PACKAGE_NAME/` becomes the project root. `workspaceName` and `projectHandle`
  are `undefined` in that mode.
- **`VERSION` must always be written.** `version` is optional in the payload
  (`formData.version || undefined`), but `package.version` must be valid semver —
  an unsubstituted `VERSION` will not build. Fall back to `0.1.0` when the form
  leaves it empty.
- **Not templated:** `package.distribution` is pinned to `2201.13.4`; it comes
  from the installed Ballerina distribution rather than the form. `orgName` (org
  display name), `projectPath`, `createDirectory` and `createAsWorkspace` have no
  slot in the package files — `package.org` takes the handle, not the display
  name.
- The tokens are plain uppercase identifiers with no delimiter characters: legal
  directory names on every OS (Windows rejects `< > : " | ? *` in paths, and Git
  for Windows refuses to check out such a path), valid Ballerina identifiers and
  valid TOML string content, so the template stays syntactically parseable
  before substitution.
- No token is a substring of another, so replacements can be applied in any
  order.

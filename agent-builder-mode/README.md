# AI Chat Agent

Template for a chattable AI agent using an LLM, prompts and tools.

## Layout

```
ai-chat-agent/                # this whole folder is the workspace root
├── Ballerina.toml            # [workspace] title + packages
├── .vscode/
│   └── settings.json         # ballerina.isBI
└── ai_chat_agent/            # integration package
    ├── Ballerina.toml
    ├── main.bal               # chat service
    ├── agents.bal             # agent definition
    ├── connections.bal
    ├── automation.bal
    ├── config.bal
    ├── data_mappings.bal
    ├── functions.bal
    ├── types.bal
    ├── .gitignore
    └── .vscode/
        ├── settings.json      # ballerina.isBI
        └── launch.json        # Ballerina debug configurations
```

`Config.toml` is deliberately absent — it is ignored repo-wide (root
`.gitignore` `**/Config.toml`) and generated per project, since it carries the
model provider access token.

This is a plain, concrete sample, not a placeholder template: it is downloaded
and opened as-is, with no substitution step. Anyone customizing it should
rename things directly — `ai_chat_agent` (folder, `package.name`, `package.title`,
`workspace.packages`), the `chatAgent` variable, and the `/agent` service path
are just starting names, not tokens to replace mechanically.

The `.vscode/` files are tracked even though the root `.gitignore` excludes
`.vscode`: they were added with `git add -f`, which keeps them tracked from then
on. **Any new file added under these `.vscode/` directories needs `git add -f`
too**, or it will be silently ignored.

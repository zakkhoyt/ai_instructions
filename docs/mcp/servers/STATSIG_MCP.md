
# Statsig MCP

> Manage Statsig feature gates, dynamic configs, experiments, and layers from any AI agent.

## Overview

- **GitHub**: [GeLi2001/statsig-mcp](https://github.com/GeLi2001/statsig-mcp)
- **Official Statsig docs**: [docs.statsig.com/integrations/mcp/overview](https://docs.statsig.com/integrations/mcp/overview)
- **Transport**: stdio
- **Auth**: Console API key (`STATSIG_CONSOLE_API_KEY`)

The Statsig MCP server connects your AI agent to the Statsig Console API, enabling it to read and manage feature gates, dynamic configs, experiments, and layers. Useful for inspecting flag status, checking experiment configurations, and making targeted changes without leaving your editor.

> **Note**: This is a community server by [GeLi2001](https://github.com/GeLi2001). Statsig also documents MCP integration at [docs.statsig.com/integrations/mcp](https://docs.statsig.com/integrations/mcp/overview).

**Key tools:**
- List, get, create, update, and delete feature gates
- List, get, create, update, and delete dynamic configs
- List, get, create, and delete experiments
- List, get, create, and delete layers

---

## Authentication

**Method: Statsig Console API Key**

1. Go to [console.statsig.com → Settings → Keys & Environments](https://console.statsig.com/api_keys)
2. Copy a **Console API key** (prefix: `console-`)
3. Store as env var: `export STATSIG_CONSOLE_API_KEY="console-..."`

> Console API keys are long-lived and managed per Statsig project. They are personal to your account — use your own key, not a shared one.

---

## Environment Variables

| Variable                   | Description                         | Required |
| -------------------------- | ----------------------------------- | -------- |
| `STATSIG_CONSOLE_API_KEY`  | Statsig Console API key (`console-...`) | Yes  |

---

## Setup

### VSCode (User scope)

```jsonc
// ~/Library/Application Support/Code/User/mcp.json
{
  "servers": {

    // # About
    // statsig - Manage Statsig feature gates, dynamic configs, experiments, and layers via MCP.
    //
    // # References
    // * [GitHub: GeLi2001/statsig-mcp](https://github.com/GeLi2001/statsig-mcp)
    // * [Statsig: Console API Keys](https://console.statsig.com/api_keys)
    // * [Statsig: MCP Integration Overview](https://docs.statsig.com/integrations/mcp/overview)
    //
    // # Installation
    // Installed automatically via `npx` on first run.
    //
    // # Authorization
    // 1) Create a Statsig Console API key
    //   * [Statsig Console: Keys & Environments](https://console.statsig.com/api_keys)
    //   * Copy a key with the `console-` prefix
    // 2) Set as `STATSIG_CONSOLE_API_KEY` env var
    "statsig": {
      "type": "stdio",
      "command": "npx",
      "args": ["-y", "statsig-mcp"],
      "env": {
        "STATSIG_CONSOLE_API_KEY": "<YOUR_STATSIG_CONSOLE_API_KEY>"
      }
    }

  }
}
```

### VSCode (Workspace scope)

```jsonc
// .vscode/mcp.json
{
  "servers": {

    // # About
    // statsig - Manage Statsig feature gates, dynamic configs, experiments, and layers via MCP.
    //
    // # References
    // * [GitHub: GeLi2001/statsig-mcp](https://github.com/GeLi2001/statsig-mcp)
    // * [Statsig: Console API Keys](https://console.statsig.com/api_keys)
    // * [Statsig: MCP Integration Overview](https://docs.statsig.com/integrations/mcp/overview)
    //
    // # Installation
    // Installed automatically via `npx` on first run.
    //
    // # Authorization
    // 1) Create a Statsig Console API key
    //   * [Statsig Console: Keys & Environments](https://console.statsig.com/api_keys)
    //   * Copy a key with the `console-` prefix
    // 2) Set as `STATSIG_CONSOLE_API_KEY` env var
    "statsig": {
      "type": "stdio",
      "command": "npx",
      "args": ["-y", "statsig-mcp"],
      "env": {
        "STATSIG_CONSOLE_API_KEY": "<YOUR_STATSIG_CONSOLE_API_KEY>"
      }
    }

  }
}
```

### Claude Code (User scope)

```shell
claude mcp add --scope user --transport stdio statsig -- npx -y statsig-mcp
```

Then set the env var in `~/.claude.json`:

```jsonc
{
  "mcpServers": {

    // # About
    // statsig - Manage Statsig feature gates, dynamic configs, experiments, and layers via MCP.
    //
    // # References
    // * [GitHub: GeLi2001/statsig-mcp](https://github.com/GeLi2001/statsig-mcp)
    // * [Statsig: Console API Keys](https://console.statsig.com/api_keys)
    // * [Statsig: MCP Integration Overview](https://docs.statsig.com/integrations/mcp/overview)
    //
    // # Installation
    // Installed automatically via `npx` on first run.
    //
    // # Authorization
    // 1) Create a Statsig Console API key
    //   * [Statsig Console: Keys & Environments](https://console.statsig.com/api_keys)
    //   * Copy a key with the `console-` prefix
    // 2) Set as `STATSIG_CONSOLE_API_KEY` env var
    "statsig": {
      "type": "stdio",
      "command": "/bin/zsh",
      "args": ["-lc", "npx -y statsig-mcp"],
      "env": {
        "STATSIG_CONSOLE_API_KEY": "<YOUR_STATSIG_CONSOLE_API_KEY>"
      }
    }

  }
}
```

### Claude Code (Project scope)

```jsonc
// .mcp.json (repository root)
{
  "mcpServers": {

    // # About
    // statsig - Manage Statsig feature gates, dynamic configs, experiments, and layers via MCP.
    //
    // # References
    // * [GitHub: GeLi2001/statsig-mcp](https://github.com/GeLi2001/statsig-mcp)
    // * [Statsig: Console API Keys](https://console.statsig.com/api_keys)
    // * [Statsig: MCP Integration Overview](https://docs.statsig.com/integrations/mcp/overview)
    //
    // # Installation
    // Installed automatically via `npx` on first run.
    //
    // # Authorization
    // 1) Create a Statsig Console API key
    //   * [Statsig Console: Keys & Environments](https://console.statsig.com/api_keys)
    //   * Copy a key with the `console-` prefix
    // 2) Set as `STATSIG_CONSOLE_API_KEY` env var
    "statsig": {
      "type": "stdio",
      "command": "/bin/zsh",
      "args": ["-lc", "npx -y statsig-mcp"],
      "env": {
        "STATSIG_CONSOLE_API_KEY": "<YOUR_STATSIG_CONSOLE_API_KEY>"
      }
    }

  }
}
```

### Claude Desktop

```jsonc
// ~/Library/Application Support/Claude/claude_desktop_config.json
{
  "mcpServers": {

    // # About
    // statsig - Manage Statsig feature gates, dynamic configs, experiments, and layers via MCP.
    //
    // # References
    // * [GitHub: GeLi2001/statsig-mcp](https://github.com/GeLi2001/statsig-mcp)
    // * [Statsig: Console API Keys](https://console.statsig.com/api_keys)
    // * [Statsig: MCP Integration Overview](https://docs.statsig.com/integrations/mcp/overview)
    //
    // # Installation
    // Installed automatically via `npx` on first run.
    //
    // # Authorization
    // 1) Create a Statsig Console API key
    //   * [Statsig Console: Keys & Environments](https://console.statsig.com/api_keys)
    //   * Copy a key with the `console-` prefix
    // 2) Set as `STATSIG_CONSOLE_API_KEY` env var
    "statsig": {
      "command": "/bin/zsh",
      "args": ["-lc", "npx -y statsig-mcp"],
      "env": {
        "STATSIG_CONSOLE_API_KEY": "<YOUR_STATSIG_CONSOLE_API_KEY>"
      }
    }

  }
}
```

### Cursor

```jsonc
// ~/.cursor/mcp.json
{
  "mcpServers": {

    // # About
    // statsig - Manage Statsig feature gates, dynamic configs, experiments, and layers via MCP.
    //
    // # References
    // * [GitHub: GeLi2001/statsig-mcp](https://github.com/GeLi2001/statsig-mcp)
    // * [Statsig: Console API Keys](https://console.statsig.com/api_keys)
    // * [Statsig: MCP Integration Overview](https://docs.statsig.com/integrations/mcp/overview)
    //
    // # Installation
    // Installed automatically via `npx` on first run.
    //
    // # Authorization
    // 1) Create a Statsig Console API key
    //   * [Statsig Console: Keys & Environments](https://console.statsig.com/api_keys)
    //   * Copy a key with the `console-` prefix
    // 2) Set as `STATSIG_CONSOLE_API_KEY` env var
    "statsig": {
      "command": "/bin/zsh",
      "args": ["-lc", "npx -y statsig-mcp"],
      "env": {
        "STATSIG_CONSOLE_API_KEY": "<YOUR_STATSIG_CONSOLE_API_KEY>"
      }
    }

  }
}
```

---

## Common Prompts / Usage Examples

```
List all feature gates in the project
```

```
Check whether the "new_checkout_flow" feature gate is enabled and what its rules are
```

```
Create a new feature gate called "ios_dark_mode_v2" targeting 10% of users
```

```
Show all active experiments and their current targeting rules
```

```
What dynamic configs exist and what are their default values?
```

```
Update the "app_config" dynamic config to set timeout to 30 seconds
```

---

## References

- [GitHub: GeLi2001/statsig-mcp](https://github.com/GeLi2001/statsig-mcp)
- [Statsig: MCP Integration Overview](https://docs.statsig.com/integrations/mcp/overview)
- [Statsig Console: Keys & Environments](https://console.statsig.com/api_keys)
- [Statsig: Console API Reference](https://docs.statsig.com/console-api/introduction)
- [Statsig](https://statsig.com)

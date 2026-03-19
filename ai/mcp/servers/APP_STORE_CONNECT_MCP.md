
# App Store Connect MCP Server

> Manage iOS/macOS apps, subscriptions, TestFlight, and more via Apple's APIs from any AI agent.

## Overview

- **GitHub**: [github.com/cristianoaredes/mcp-apple-store](https://github.com/cristianoaredes/mcp-apple-store)
- **Transport**: `stdio` — local `node` process (must clone and build)
- **Tools**: 83+ covering App Store Server API (StoreKit 2) and App Store Connect API

`mcp-apple-store` wraps both of Apple's developer APIs behind structured MCP tools. It lets an AI agent manage your app's TestFlight builds, provisioning profiles, IAP subscriptions, customer reviews, analytics, and App Store submissions — as well as verify StoreKit 2 transactions at runtime.

**Why useful for Hatch iOS dev:**
- Manage Nightlight's IAP subscription groups and subscriptions from the agent session.
- Check active subscriber status and transaction history for debugging.
- Add devices to provisioning profiles without opening App Store Connect.
- List and respond to customer reviews inline.
- Submit new app versions for review from the command line.

---

## Authentication

**Method: App Store Connect API Key (JWT-based, long-lived)**

App Store Connect API Keys do not expire on a fixed schedule — they remain valid until you revoke them. This makes them the preferred auth method over OAuth.

**How to create an API Key:**
1. Go to [App Store Connect → Users and Access → Integrations → API Keys](https://appstoreconnect.apple.com/access/api)
2. Click the `+` button, give the key a name (e.g., `mcp-agent`)
3. Choose a role appropriate for your use (see permissions table below)
4. Click **Generate** — download the `.p8` file immediately (cannot be re-downloaded)
5. Note the **Issuer ID** (top of the page) and **Key ID** (in the key row)

**Required permissions per feature:**

| Permission       | Required For                                                 |
| ---------------- | ------------------------------------------------------------ |
| `App Manager`    | Apps, Versions, App Store Submission                         |
| `Developer`      | TestFlight, Builds                                           |
| `Admin`          | Users, Provisioning Profiles, Certificates, Devices          |
| `Finance`        | Sales Reports, Finance Reports                               |

> For full coverage, create an **Admin** key. For CI/read-only use, `App Manager` + `Developer` is sufficient.

**Store the private key securely:**

```zsh
# Place the downloaded .p8 at a stable path, e.g.:
mv ~/Downloads/AuthKey_DFHY4X2SUF.p8 ~/.zsh_home/tokens/AuthKey_DFHY4X2SUF.p8
chmod 600 ~/.zsh_home/tokens/AuthKey_DFHY4X2SUF.p8
```

---

## Installation

This server runs as a **local node process** — it must be cloned and built before first use.

```zsh
# Clone to a stable local path
git clone https://github.com/cristianoaredes/mcp-apple-store.git \
  ~/code/other/mcp/mcp-apple-store

cd ~/code/other/mcp/mcp-apple-store

# Install dependencies and build
npm install
npm run build

# Verify the entry point exists
ls dist/index.js
```

> **No npx/uvx**: Unlike many MCP servers, this one does not publish to npm. You must use the local `dist/index.js` path.

---

## Environment Variables

| Variable                     | Description                                                         | Required |
| ---------------------------- | ------------------------------------------------------------------- | -------- |
| `APP_STORE_ISSUER_ID`        | Issuer ID from App Store Connect → Users & Access → Integrations   | Yes      |
| `APP_STORE_KEY_ID`           | Key ID matching your downloaded `.p8` file                          | Yes      |
| `APP_STORE_PRIVATE_KEY_PATH` | Path to the `.p8` private key file (relative or absolute)          | Yes      |
| `APP_BUNDLE_ID`              | Bundle ID of your app (e.g. `com.hatchbaby.Nightlight`)            | Yes      |
| `APP_APPLE_ID`               | Numeric Apple ID for your app (found in App Store Connect)          | Yes      |
| `APP_STORE_ENVIRONMENT`      | `Sandbox` or `Production` (default: `Production`)                  | No       |
| `LOG_LEVEL`                  | Logging verbosity — `info`, `debug`, `error` (default: `info`)     | No       |
| `APPLE_ROOT_CERT_PATH`       | Path to Apple Root CA cert — needed only for webhook verification   | No       |
| `WEBHOOK_PORT`               | Port for incoming App Store Server Notifications (e.g. `3000`)     | No       |
| `WEBHOOK_PATH`               | URL path for webhook endpoint (e.g. `/webhooks/apple`)              | No       |

**Set in `~/.zshrc`:**

```zsh
export APPLE_ASC_MCP_ISSUER_ID="69a6de82-c091-47e3-e053-5b8c7c11a4d1"
export APPLE_ASC_MCP_KEY_ID="DFHY4X2SUF"
export APPLE_ASC_MCP_AUTH_KEY_PATH="$HOME/.zsh_home/tokens/AuthKey_DFHY4X2SUF.p8"
export APPLE_ASC_MCP_BUNDLE_ID="com.hatchbaby.Nightlight"
export APPLE_ASC_MCP_APPLE_ID="123456789"
export APPLE_ASC_MCP_STORE_ENVIRONMENT="Sandbox"
export APPLE_ASC_MCP_LOG_LEVEL="info"
```

---

## Tool Categories (83+ tools)

### App Store Server API (StoreKit 2)

| Tool                        | Description                                       |
| --------------------------- | ------------------------------------------------- |
| `get_subscription_status`   | Get subscription status for a transaction         |
| `check_active_subscription` | Check if a user has an active subscription        |
| `get_subscription_by_product` | Get subscription by product ID                  |
| `get_transaction_history`   | Get a user's transaction history                  |
| `get_transaction_info`      | Get details for a specific transaction            |
| `lookup_order`              | Look up an order by order ID                      |
| `get_refund_history`        | Get refund history for a user                     |
| `verify_transaction`        | Verify transaction authenticity (JWS signature)   |
| `send_consumption_info`     | Send consumption data to Apple                    |
| `request_test_notification` | Request a test server notification                |

### App Store Connect API

| Category      | Tool count | Description                                           |
| ------------- | ---------- | ----------------------------------------------------- |
| Apps          | 6          | List, get, create, and update apps                    |
| TestFlight    | 5          | Builds, beta testers, beta groups                     |
| Provisioning  | 7          | Certificates, profiles, devices, bundle IDs           |
| Users         | 2          | Team members and invitations                          |
| IAP           | 11         | IAPs, subscription groups, subscriptions              |
| Reviews       | 7          | Customer reviews and responses                        |
| Analytics     | 4          | Sales reports and finance reports                     |
| Events        | 8          | In-app events management                             |
| Submission    | 13         | App versions and App Store submission                 |

---

## Setup

> All configs below pass credentials via environment variables. Never embed the `.p8` key content directly in config files.

### VSCode (User scope)

File: `~/Library/Application Support/Code/User/mcp.json`

```jsonc
{
  "servers": {
    // App Store Connect MCP — local node process, JWT auth via .p8 key
    // GitHub: https://github.com/cristianoaredes/mcp-apple-store
    // Key: https://appstoreconnect.apple.com/access/api
    "apple-store": {
      "type": "stdio",
      "command": "node",
      // Path is relative to $HOME
      "args": ["code/other/mcp/mcp-apple-store/dist/index.js"],
      "env": {
        "APP_STORE_ISSUER_ID": "${APPLE_ASC_MCP_ISSUER_ID}",
        "APP_STORE_KEY_ID": "${APPLE_ASC_MCP_KEY_ID}",
        "APP_STORE_PRIVATE_KEY_PATH": "${APPLE_ASC_MCP_AUTH_KEY_PATH}",
        "APP_BUNDLE_ID": "${APPLE_ASC_MCP_BUNDLE_ID}",
        "APP_APPLE_ID": "${APPLE_ASC_MCP_APPLE_ID}",
        "APP_STORE_ENVIRONMENT": "${APPLE_ASC_MCP_STORE_ENVIRONMENT}",
        "LOG_LEVEL": "${APPLE_ASC_MCP_LOG_LEVEL}"

        // Optional: uncomment if using webhooks
        // "APPLE_ROOT_CERT_PATH": "${HOME}/keys/AppleRootCA-G3.cer",
        // "WEBHOOK_PORT": "3000",
        // "WEBHOOK_PATH": "/webhooks/apple"
      }
    }
  }
}
```

### VSCode (Workspace scope)

File: `.vscode/mcp.json`

```jsonc
{
  "servers": {
    // App Store Connect MCP — env vars must be set in shell before launching VSCode
    "apple-store": {
      "type": "stdio",
      "command": "node",
      "args": ["${env:HOME}/code/other/mcp/mcp-apple-store/dist/index.js"],
      "env": {
        "APP_STORE_ISSUER_ID": "${APPLE_ASC_MCP_ISSUER_ID}",
        "APP_STORE_KEY_ID": "${APPLE_ASC_MCP_KEY_ID}",
        "APP_STORE_PRIVATE_KEY_PATH": "${APPLE_ASC_MCP_AUTH_KEY_PATH}",
        "APP_BUNDLE_ID": "${APPLE_ASC_MCP_BUNDLE_ID}",
        "APP_APPLE_ID": "${APPLE_ASC_MCP_APPLE_ID}",
        "APP_STORE_ENVIRONMENT": "${APPLE_ASC_MCP_STORE_ENVIRONMENT}"
      }
    }
  }
}
```

### Claude Code (User scope)

```shell
claude mcp add --scope user --transport stdio apple-store -- \
  node "$HOME/code/other/mcp/mcp-apple-store/dist/index.js"
```

Resulting entry in `~/.claude.json`:

```json
{
  "mcpServers": {
    "apple-store": {
      "type": "stdio",
      "command": "/bin/zsh",
      "args": ["-lc", "node \"$HOME/code/other/mcp/mcp-apple-store/dist/index.js\""],
      "env": {
        "APP_STORE_ISSUER_ID": "${APPLE_ASC_MCP_ISSUER_ID}",
        "APP_STORE_KEY_ID": "${APPLE_ASC_MCP_KEY_ID}",
        "APP_STORE_PRIVATE_KEY_PATH": "${APPLE_ASC_MCP_AUTH_KEY_PATH}",
        "APP_BUNDLE_ID": "${APPLE_ASC_MCP_BUNDLE_ID}",
        "APP_APPLE_ID": "${APPLE_ASC_MCP_APPLE_ID}",
        "APP_STORE_ENVIRONMENT": "${APPLE_ASC_MCP_STORE_ENVIRONMENT}",
        "LOG_LEVEL": "${APPLE_ASC_MCP_LOG_LEVEL}"
      }
    }
  }
}
```

### Claude Code (Project scope)

File: `.mcp.json` in repo root

```json
{
  "mcpServers": {
    "apple-store": {
      "type": "stdio",
      "command": "/bin/zsh",
      "args": ["-lc", "node \"$HOME/code/other/mcp/mcp-apple-store/dist/index.js\""],
      "env": {
        "APP_STORE_ISSUER_ID": "${APPLE_ASC_MCP_ISSUER_ID}",
        "APP_STORE_KEY_ID": "${APPLE_ASC_MCP_KEY_ID}",
        "APP_STORE_PRIVATE_KEY_PATH": "${APPLE_ASC_MCP_AUTH_KEY_PATH}",
        "APP_BUNDLE_ID": "${APPLE_ASC_MCP_BUNDLE_ID}",
        "APP_APPLE_ID": "${APPLE_ASC_MCP_APPLE_ID}",
        "APP_STORE_ENVIRONMENT": "${APPLE_ASC_MCP_STORE_ENVIRONMENT}",
        "LOG_LEVEL": "${APPLE_ASC_MCP_LOG_LEVEL}"
      }
    }
  }
}
```

### Claude Desktop

File: `~/Library/Application Support/Claude/claude_desktop_config.json`

```jsonc
{
  "mcpServers": {
    // App Store Connect MCP
    // Note: Launch Claude Desktop from terminal to inherit env vars:
    //   open -a "Claude" from a zsh session that has APPLE_ASC_MCP_* set
    "apple-store": {
      "command": "node",
      "args": ["/Users/zakkhoyt/code/other/mcp/mcp-apple-store/dist/index.js"],
      "env": {
        "APP_STORE_ISSUER_ID": "${APPLE_ASC_MCP_ISSUER_ID}",
        "APP_STORE_KEY_ID": "${APPLE_ASC_MCP_KEY_ID}",
        "APP_STORE_PRIVATE_KEY_PATH": "${APPLE_ASC_MCP_AUTH_KEY_PATH}",
        "APP_BUNDLE_ID": "${APPLE_ASC_MCP_BUNDLE_ID}",
        "APP_APPLE_ID": "${APPLE_ASC_MCP_APPLE_ID}",
        "APP_STORE_ENVIRONMENT": "${APPLE_ASC_MCP_STORE_ENVIRONMENT}",
        "LOG_LEVEL": "${APPLE_ASC_MCP_LOG_LEVEL}"
      }
    }
  }
}
```

### Cursor

Global: `~/.cursor/mcp.json` — or project: `.cursor/mcp.json`

```json
{
  "mcpServers": {
    "apple-store": {
      "command": "/bin/zsh",
      "args": [
        "-lc",
        "node \"$HOME/code/other/mcp/mcp-apple-store/dist/index.js\""
      ],
      "env": {
        "APP_STORE_ISSUER_ID": "${APPLE_ASC_MCP_ISSUER_ID}",
        "APP_STORE_KEY_ID": "${APPLE_ASC_MCP_KEY_ID}",
        "APP_STORE_PRIVATE_KEY_PATH": "${APPLE_ASC_MCP_AUTH_KEY_PATH}",
        "APP_BUNDLE_ID": "${APPLE_ASC_MCP_BUNDLE_ID}",
        "APP_APPLE_ID": "${APPLE_ASC_MCP_APPLE_ID}",
        "APP_STORE_ENVIRONMENT": "${APPLE_ASC_MCP_STORE_ENVIRONMENT}",
        "LOG_LEVEL": "${APPLE_ASC_MCP_LOG_LEVEL}"
      }
    }
  }
}
```

---

## Common Prompts / Usage Examples

```
# List all apps in App Store Connect
List all my apps in App Store Connect

# Check subscription status
Check if the subscription with transaction ID 1234567890 is active for app com.hatchbaby.Nightlight

# Get transaction history
Get transaction history for user token <token>

# List TestFlight builds
List the last 5 TestFlight builds for Nightlight

# Manage beta testers
Add beta.tester@hatch.co as a beta tester for the Nightlight app

# Check unanswered reviews
List unanswered 1-star reviews for Nightlight and suggest responses

# List provisioning profiles
List all distribution provisioning profiles for com.hatchbaby.Nightlight

# Register a test device
Register device with UDID 00008101-001234567890001E as 'QA iPhone 15'

# IAP management
List all subscription groups for Nightlight

# Submit for review
Submit version 1.2.3 of Nightlight for App Store review
```

---

## Rate Limits

| API                    | Limit              |
| ---------------------- | ------------------ |
| App Store Server API   | 50 requests/minute |
| App Store Connect API  | 3600 requests/hour |

The server has built-in rate limiting with automatic retry/exponential backoff.

---

## References

- [GitHub: mcp-apple-store](https://github.com/cristianoaredes/mcp-apple-store)
- [App Store Connect API — Keys](https://appstoreconnect.apple.com/access/api)
- [App Store Connect API Docs](https://developer.apple.com/documentation/appstoreconnectapi)
- [App Store Server API Docs](https://developer.apple.com/documentation/appstoreserverapi)
- [App Store Connect API roles and permissions](https://developer.apple.com/help/app-store-connect/reference/role-permissions)

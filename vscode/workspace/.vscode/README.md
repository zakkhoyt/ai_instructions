*.json files in this directory will be merged into `$dest_dir/.vscode/*.json` by `scripts/configure_ai_instructions.zsh`.




# .vscode/mcp.json

```json
{
	"servers": {
		"XcodeBuildMCP": {
			"command": "npx",
			"args": [
				"-y",
				"xcodebuildmcp@latest"
			],
			"env": {
				"INCREMENTAL_BUILDS_ENABLED": "false",
				"NODE_ENV": "development",
				"DEBUG": "*"
			},
			"type": "stdio"
		},
		"context7": {
			"command": "npx",
			"args": [
				"-y",
				"@upstash/context7-mcp@latest"
			],
			"type": "stdio"
		},
		// "atlassian/atlassian-mcp-server": {
		// 	"type": "http",
		// 	"url": "https://mcp.atlassian.com/v1/sse",
		// 	"gallery": "https://api.mcp.github.com",
		// 	"version": "1.0.0"
		// },
		// "mcp-atlassian": {
		// 	"command": "docker",
		// 	"args": [
		// 		"run",
		// 		"--rm",
		// 		"-i",
		// 		"--env-file", ".vscode/atlassian.env",
		// 		"ghcr.io/sooperset/mcp-atlassian:latest",
		// 		"--transport", "stdio"
		// 	],
		// 	"type": "stdio"
		// }
	},
	"inputs": []
}
```

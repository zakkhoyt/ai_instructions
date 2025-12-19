*.json files in this directory will be merged into `$HOME/Library/Application Support/Code/User/*.json` by `scripts/configure_ai_instructions.zsh`.


```json
// # Web colors: 
// * https://www.w3schools.com/colors/colors_picker.asp
// * https://en.wikipedia.org/wiki/Web_colors
{
    "[dockercompose]": {
        "editor.autoIndent": "advanced",
        "editor.defaultFormatter": "redhat.vscode-yaml",
        "editor.insertSpaces": true,
        "editor.quickSuggestions": {
            "comments": false,
            "other": true,
            "strings": true
        },
        "editor.tabSize": 2
    },
    "[dot]": {
        "editor.defaultFormatter": "tintinweb.graphviz-interactive-preview"
    },
    "[github-actions-workflow]": {
        "editor.defaultFormatter": "redhat.vscode-yaml"
    },
    "[javascript, ruby]": {},
    "[json]": {
        "editor.tabSize": 2
    },
    "[json5]": {
        "editor.tabSize": 2
    },
    "[jsonc]": {
        "editor.tabSize": 2
    },
    "[markdown]": {
        "editor.quickSuggestions": {
            "other": "inline"
        },
        "editor.tabSize": 4,
        "editor.wordWrap": "off"
    },
    "[OpenSCAD]": {
        "editor.tabSize": 2
    },
    "[python]": {
        "editor.formatOnType": true
    },
    "[ruby]": {
        "editor.tabSize": 2
    },
    "[shellscript]": {
        "editor.tabSize": 2
    },
    "[swift]": {
        "editor.tabSize": 4
    },
    "[yaml]": {
        "editor.tabSize": 4
    },
    "arduino.additionalUrls": [
        "http://arduino.esp8266.com/stable/package_esp8266com_index.json",
        "https://adafruit.github.io/arduino-board-index/package_adafruit_index.json"
    ],
    "arduino.commandPath": "arduino-cli",
    "arduino.logLevel": "verbose",
    "arduino.path": "/opt/homebrew/bin/",
    "arduino.useArduinoCli": true,
    "atlascode.bitbucket.enabled": false,
    "atlascode.jira.enabled": true,
    "atlascode.jira.explorer.fetchAllQueryResults": true,
    "atlascode.jira.jqlList": [
        {
            "enabled": true,
            "id": "f5cf7786-7210-4107-9515-5c61ae417ed8",
            "monitor": true,
            "name": "My hatchbaby Issues",
            "query": "assignee = currentUser() AND resolution = Unresolved ORDER BY lastViewed DESC",
            "siteId": "6c13c4f6-29c7-4d31-912c-2d1ffc380813"
        }
    ],
    "auto-build.defaultEnv.name": "BIGTREE_SKR_2_F429",
    "auto-build.showOnStart": false,
    "autoDocstring.customTemplatePath": "/Users/zakkhoyt/Library/Application Support/Code/User/snippets/python_autoDocstring.moustache",
    "autoDocstring.includeName": true,
    "autoDocstring.startOnNewLine": true,
    "avprobe.ffmpegPath": "/usr/local/bin/ffmpeg",
    "avprobe.ffprobePath": "/usr/local/bin/ffprobe",
    // "better-comments.highlightPlainText": false,
    "better-comments.multilineComments": true,
    // "better-comments.tags": [
    //     // {
    //     //     "backgroundColor": "transparent",
    //     //     "bold": true,
    //     //     "color": "#3498DB",
    //     //     "italic": false,
    //     //     "strikethrough": false,
    //     //     "tag": "# ##"
    //     // },
    //     // {
    //     //     "backgroundColor": "transparent",
    //     //     "bold": true,
    //     //     "color": "#61AFEF",
    //     //     "italic": false,
    //     //     "strikethrough": false,
    //     //     "tag": "# #"
    //     // },
    //     // {
    //     //     "backgroundColor": "transparent",
    //     //     "bold": false,
    //     //     "color": "#ABB2BF",
    //     //     "italic": false,
    //     //     "strikethrough": false,
    //     //     "tag": "# * "
    //     // },
    //     // {
    //     //     "backgroundColor": "transparent",
    //     //     "bold": false,
    //     //     "color": "#98C379",
    //     //     "italic": false,
    //     //     "strikethrough": false,
    //     //     "tag": "# ```"
    //     // },
    //     // {
    //     //     "backgroundColor": "transparent",
    //     //     "bold": false,
    //     //     "color": "#E5C07B",
    //     //     "italic": false,
    //     //     "strikethrough": false,
    //     //     "tag": "`"
    //     // },
    //     // {
    //     //     "backgroundColor": "transparent",
    //     //     "bold": false,
    //     //     "color": "#C678DD",
    //     //     "italic": true,
    //     //     "strikethrough": false,
    //     //     "tag": "["
    //     // }
    // ],
    "blender.executables": [
        {
            "isDebug": false,
            "name": "",
            "path": "/Applications/Blender.app/Contents/MacOS/blender"
        }
    ],
    "chat.agent.thinkingStyle": "expanded",
    "chat.mcp.gallery.enabled": true,
    "chat.mcp.serverSampling": {
        "Global in Code: XcodeBuildMCP": {
            "allowedModels": [
                "copilot/claude-sonnet-4.5",
                "copilot/auto",
                "copilot/gpt-5.1-codex"
            ]
        }
    },
    "chat.tools.terminal.autoApprove": {
        "*": {
            "approve": true,
            "matchCommandLine": true
        },
        "/;/": {
            "approve": true,
            "matchCommandLine": true
        },
        "/.*/": {
            "approve": true,
            "matchCommandLine": true
        },
        "/\\?/": {
            "approve": true,
            "matchCommandLine": true
        },
        "/\\(.+\\)/s": {
            "approve": true,
            "matchCommandLine": true
        },
        "/\\(/": {
            "approve": true,
            "matchCommandLine": true
        },
        "/\\)/": {
            "approve": true,
            "matchCommandLine": true
        },
        "/\\[/": {
            "approve": true,
            "matchCommandLine": true
        },
        "/\\]/": {
            "approve": true,
            "matchCommandLine": true
        },
        "/\\{.+\\}/s": {
            "approve": true,
            "matchCommandLine": true
        },
        "/\\{/": {
            "approve": true,
            "matchCommandLine": true
        },
        "/\\}/": {
            "approve": true,
            "matchCommandLine": true
        },
        "/\\*/": {
            "approve": true,
            "matchCommandLine": true
        },
        "/\\|/": {
            "approve": true,
            "matchCommandLine": true
        },
        "/\\|\\|/": {
            "approve": true,
            "matchCommandLine": true
        },
        "/\\$/": {
            "approve": true,
            "matchCommandLine": true
        },
        "/\\$\\(/": {
            "approve": true,
            "matchCommandLine": true
        },
        "/\\$\\{/": {
            "approve": true,
            "matchCommandLine": true
        },
        "/&&/": {
            "approve": true,
            "matchCommandLine": true
        },
        "/`.+`/s": {
            "approve": true,
            "matchCommandLine": true
        },
        "/`/": {
            "approve": true,
            "matchCommandLine": true
        },
        "/</": {
            "approve": true,
            "matchCommandLine": true
        },
        "/>/": {
            "approve": true,
            "matchCommandLine": true
        },
        "/>>/": {
            "approve": true,
            "matchCommandLine": true
        },
        "/2>/": {
            "approve": true,
            "matchCommandLine": true
        },
        "/2>&1/": {
            "approve": true,
            "matchCommandLine": true
        },
        "/Users/zakkhoyt/code/repositories/hatch/hatch_sleep/environment-toolbox/docs/videos/first_critical_alert/.gitignored/generate_espeak.zsh": true,
        "awk": true,
        "chmod": true,
        "find": true,
        "grep": true,
        "jq": true,
        "sed": true,
        "tee": true,
        "xargs": true
    },
    "chatgpt.lang": "en",
    "cmake.configureOnOpen": false,
    "coderabbit.autoReviewMode": "disabled",
    "color-manager.contextMenu": {
        "edit": true,
        "findColors": true,
        "openPalette": true,
        "openPicker": true
    },
    "color-manager.languages": [
        "json",
        "json5",
        "markdown",
        "md",
        "swift",
        "shellscript",
        "sh",
        "bash",
        "zsh",
        "swift",
        "html",
        "css",
        "javascript",
        "typescript",
        "python"
    ],
    "colorInfo.languages": [
        {
            "colors": "css",
            "selector": "css"
        },
        {
            "colors": "css",
            "selector": "sass"
        },
        {
            "colors": "css",
            "selector": "scss"
        },
        {
            "colors": "css",
            "selector": "less"
        },
        {
            "colors": "puml",
            "selector": "css"
        },
        {
            "colors": "puml",
            "selector": "sass"
        },
        {
            "colors": "puml",
            "selector": "scss"
        },
        {
            "colors": "puml",
            "selector": "less"
        }
    ],
    "debug.onTaskErrors": "showErrors",
    "diffEditor.maxComputationTime": 0,
    "docker.extension.enableComposeLanguageServer": false,
    "doxdocgen.file.fileOrder": [
        "file",
        "author",
        "brief",
        "date"
    ],
    "doxdocgen.generic.briefTemplate": "@brief {text}",
    "doxdocgen.generic.commentPrefix": "## ",
    "doxdocgen.generic.firstLine": "##",
    "doxdocgen.generic.lastLine": "##",
    "doxdocgen.generic.paramTemplate": "@param {param} ",
    "doxdocgen.generic.returnTemplate": "@return ",
    // Enable for shell scripts
    "doxdocgen.generic.triggerSequence": "##",
    "editor.accessibilitySupport": "off",
    "editor.dropIntoEditor.preferences": [
        "markdown.link.audio"
    ],
    "editor.find.seedSearchStringFromSelection": "selection",
    "editor.fontFamily": "'Fira Mono'",
    "editor.fontLigatures": true,
    "editor.inlayHints.enabled": "offUnlessPressed",
    "editor.largeFileOptimizations": false,
    "editor.lineNumbers": "on",
    "editor.minimap.enabled": false,
    "editor.occurrencesHighlight": "off",
    "editor.pasteAs.enabled": true,
    "editor.stickyScroll.enabled": true,
    "editor.tabCompletion": "on",
    "explorer.confirmDelete": false,
    "explorer.confirmDragAndDrop": false,
    "files.associations": {
        ".swiftformat": "shellscript",
        ".zsh_hatch": "shellscript",
        "*.sh": "shellscript",
        "*.swift": "swift",
        "*.txt": "makefile",
        "Fastfile": "ruby",
        "Fastfile_original": "ruby",
        "Fastfile+dsym": "ruby",
        "Fastfile+helpers": "ruby",
        "Fastfile+variables": "ruby"
    },
    "files.defaultLanguage": "markdown",
    "files.exclude": {
        "**/.git": false,
        "**/backup": true,
        "**/backup/*": true
    },
    "git-graph.dialog.merge.squashCommits": true,
    "git.autofetch": true,
    "git.confirmSync": false,
    "git.openRepositoryInParentFolders": "always",
    "github-actions.org-features": true,
    "github-actions.workflows.pinned.refresh.enabled": true,
    "github.copilot.chat.agent.thinkingTool": true,
    "github.copilot.nextEditSuggestions.enabled": true,
    "github.customPullRequestTitle": true,
    "github.gitProtocol": "ssh",
    "githubPullRequests.defaultMergeMethod": "squash",
    "githubPullRequests.fileListLayout": "tree",
    "githubPullRequests.pullBranch": "never",
    "githubPullRequests.pushBranch": "always",
    "gitlab.customQueries": [
        {
            "name": "Issues assigned to me",
            "noItemText": "There is no issue assigned to you.",
            "scope": "assigned_to_me",
            "state": "opened",
            "type": "issues"
        },
        {
            "name": "Issues created by me",
            "noItemText": "There is no issue created by you.",
            "scope": "created_by_me",
            "state": "opened",
            "type": "issues"
        },
        {
            "name": "Merge requests assigned to me",
            "noItemText": "There is no MR assigned to you.",
            "scope": "assigned_to_me",
            "state": "opened",
            "type": "merge_requests"
        },
        {
            "name": "Merge requests I'm reviewing",
            "noItemText": "There is no MR for you to review.",
            "reviewer": "<current_user>",
            "state": "opened",
            "type": "merge_requests"
        },
        {
            "name": "Merge requests created by me",
            "noItemText": "There is no MR created by you.",
            "scope": "created_by_me",
            "state": "opened",
            "type": "merge_requests"
        },
        {
            "name": "All project merge requests",
            "noItemText": "The project has no merge requests",
            "scope": "all",
            "state": "opened",
            "type": "merge_requests"
        }
    ],
    "gitlab.instanceUrl": "https://gitlab.com",
    "gitlens.ai.model": "vscode",
    "gitlens.ai.vscode.model": "copilot:gpt-4.1",
    "gitlens.graph.experimental.minimap.enabled": true,
    "gitlens.graph.minimap.enabled": false,
    "gitlens.views.branches.branches.layout": "list",
    "gitlens.views.repositories.files.layout": "tree",
    "gitlens.views.searchAndCompare.files.layout": "tree",
    "graphviz-interactive-preview.debouncingInterval": 10,
    "graphviz.hotUpdate": true,
    "graphviz.multiPanel": true,
    "liveshare.featureSet": "stable",
    "lldb.launch.expressions": "native",
    "lldb.library": "/Applications/Xcode.app/Contents/SharedFrameworks/LLDB.framework/Versions/A/LLDB",
    "markdown-preview-enhanced.alwaysShowBacklinksInPreview": true,
    "markdown-preview-enhanced.codeBlockTheme": "github-dark.css",
    "markdown-preview-enhanced.enableExtendedTableSyntax": true,
    "markdown-preview-enhanced.enableHTML5Embed": true,
    "markdown-preview-enhanced.enablePreviewZenMode": false,
    "markdown-preview-enhanced.enableTypographer": true,
    "markdown-preview-enhanced.enableWikiLinkSyntax": false,
    "markdown-preview-enhanced.hideDefaultVSCodeMarkdownPreviewButtons": false,
    "markdown-preview-enhanced.HTML5EmbedUseLinkSyntax": true,
    "markdown-preview-enhanced.markdownFileExtensions": [
        ".md",
        ".markdown",
        ".mdown",
        ".mkdn",
        ".mkd",
        ".rmd",
        ".qmd",
        ".mdx"
    ],
    "markdown-preview-enhanced.mermaidTheme": "dark",
    "markdown-preview-enhanced.pandocArguments": [
        "--to",
        "rtf"
    ],
    "markdown-preview-enhanced.plantumlJarPath": "/opt/homebrew/Cellar/plantuml/1.2025.0/libexec/plantuml.jar",
    "markdown-preview-enhanced.previewTheme": "github-dark.css",
    "markdown-preview-enhanced.revealjsTheme": "moon.css",
    // "markdown.editor.pasteUrlAsFormattedLink.enabled": "always",
    // https://maiminh1996.github.io/blog/2024/enabling-copy-paste-image-markdown/
    // https://github.com/microsoft/vscode/blob/main/extensions/markdown-language-features/package.nls.json
    // https://github.com/microsoft/vscode/blob/main/extensions/markdown-language-features/src/languageFeatures/copyFiles/copyFiles.ts
    // * documentDirName: Absolute parent directory path of the Markdown document, e.g. `/Users/me/myProject/docs`.
    // * documentRelativeDirName: Relative parent directory path of the Markdown document, e.g. `docs`. This is the same as `${documentDirName}` if the file is not part of a workspace.
    // * documentFileName: The filename of the Markdown document, e.g. `README.md`.
    // * documentBaseName: The basename of the Markdown document, e.g. `README`.
    // * documentExtName: The extension of the Markdown document, e.g. `md`.
    // * documentFilePath: Absolute path of the Markdown document, e.g. `/Users/me/myProject/docs/README.md`.
    // * documentRelativeFilePath: Relative path of the Markdown document, e.g. `docs/README.md`. This is the same as `${documentFilePath}` if the file is not part of a workspace.
    "markdown.copyFiles.destination": {
        // "/markdown/**/*": "${documentWorkspaceFolder}/markdown/images/${fileExtName}",
        // "/swift/**/*": "swift/${documentWorkspaceFolder}/swift/images/${fileExtName}",
        // "**/*": "${documentWorkspaceFolder}/images/${fileExtName}",
        "**/*": "${documentDirName}/images/"
        // "**/*": "${documentWorkspaceFolder}/images/${fileExtName}/",
    },
    "markdown.editor.drop.copyIntoWorkspace": "mediaFiles",
    "markdown.editor.drop.enabled": "smart",
    "markdown.editor.filePaste.copyIntoWorkspace": "mediaFiles",
    "markdown.editor.filePaste.enabled": "smart",
    "markdown.extension.completion.enabled": true,
    "markdown.extension.print.theme": "dark",
    "markdown.extension.theming.decoration.renderLink": true,
    "markdown.links.openLocation": "beside",
    // "markdown-preview-enhanced.enableLinkify": true,
    "markdown.preview.linkify": true,
    "markdown.validate.duplicateLinkDefinitions.enabled": "error",
    // "markdown.updateLinksOnFileMove.include": [
    //     "**/*.{md,mkd,mdwn,mdown,markdown,markdn,mdtxt,mdtext,workbook}",
    //     "**/*.{jpg,jpe,jpeg,png,bmp,gif,ico,webp,avif,tiff,svg,mp4}"
    // ],
    "markdown.validate.enabled": true,
    "markdown.validate.fileLinks.enabled": "error",
    "markdownExtended.pdfLandscape": true,
    "markdownExtended.puppeteerExecutable": "'/Applications/Google Chrome.app/Contents/MacOS/Google Chrome'",
    "notebook.cellToolbarLocation": {
        "default": "right",
        "jupyter-notebook": "left"
    },
    "openscad.export.exportNameFormat": "${fileBasenameNoExtension}_${#}.${exportExtension}",
    "openscad.export.skipSaveDialog": true,
    "openscad.maxInstances": 1,
    "plantuml.render": "Local",
    "python.pythonPath": "/usr/local/bin/python3",
    "redhat.telemetry.enabled": true,
    "ruby.codeCompletion": "rcodetools",
    "ruby.intellisense": "rubyLocate",
    "ruby.useLanguageServer": true,
    "scad-lsp.launchPath": "/Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD",
    "scm.alwaysShowActions": true,
    "security.promptForLocalFileProtocolHandling": false,
    "security.workspace.trust.banner": "never",
    "security.workspace.trust.untrustedFiles": "open",
    "sequencediagrams.diagram.style": "simple",
    "shellcheck.logLevel": "debug",
    "solargraph.bundlerPath": "/Users/zakkhoyt/.rbenv/shims/bundle",
    "solargraph.commandPath": " /Users/zakkhoyt/.gem/gems/solargraph-0.47.2/bin/solargraph",
    "solargraph.useBundler": true,
    "swift.backgroundCompilation": false,
    "swift.createTasksForLibraryProducts": true,
    "swift.debugger.path": "/usr/bin/lldb",
    "swift.disableAutoResolve": true,
    "swift.excludePathsFromPackageDependencies": [
        ".git",
        ".github",
        ".gitignored"
    ],
    "swift.ignoreSearchingForPackagesInSubfolders": [
        ".",
        ".build",
        "Packages",
        "out",
        "bazel-out",
        "bazel-bin",
        ".gitignored"
    ],
    "swift.scriptSwiftLanguageVersion": "5",
    "swift.showTestExplorer": true,
    "swift.swiftEnvironmentVariables": {
        "DEVELOPER_DIR": "/Applications/Xcode.app/Contents/Developer"
    },
    "sync.gist": "99a86d9b6fd9dc326f8d5711dca43079",
    "task.allowAutomaticTasks": "on",
    "terminal.explorerKind": "both",
    "terminal.external.osxExec": "iTerm.app",
    "terminal.integrated.defaultLocation": "editor",
    "terminal.integrated.defaultProfile.osx": "zsh",
    "terminal.integrated.enableImages": true,
    "terminal.integrated.enableMultiLinePasteWarning": "never",
    "terminal.integrated.hideOnStartup": "whenEmpty",
    "terminal.integrated.profiles.osx": {
        "bash": {
            "args": [
                "-l"
            ],
            "icon": "terminal-bash",
            "path": "bash"
        },
        "fish": {
            "args": [
                "-l"
            ],
            "path": "fish"
        },
        "pwsh": {
            "icon": "terminal-powershell",
            "path": "pwsh"
        },
        "tmux": {
            "icon": "terminal-tmux",
            "path": "tmux"
        },
        "zsh": {
            "args": [
                "-l"
            ],
            "path": "zsh"
        }
    },
    "terminal.integrated.scrollback": 100000,
    "terminal.integrated.shellIntegration.enabled": true,
    "terminal.integrated.shellIntegration.environmentReporting": true,
    "terminal.integrated.shellIntegration.history": 1000,
    "terminal.integrated.suggest.cdPath": "relative",
    "terminal.integrated.suggest.enabled": true,
    "todo-tree.filtering.includeHiddenFiles": false,
    "todo-tree.general.schemes": [
        "file",
        "ssh",
        "untitled",
        "vscode-notebook-cell",
        "vscode-userdata"
    ],
    "todo-tree.general.showActivityBarBadge": true,
    "todo-tree.general.tags": [
        "CIStablity: zakkhoyt",
        "P0: zakkhoyt",
        "FIXME: zakkhoyt",
        "TODO: zakkhoyt",
        "IDEA: zakkhoyt",
        "NICE: zakkhoyt",
        "GOAL: zakkhoyt",
        "TODO: CI P0",
        "TODO: CI P1",
        "TODO: CI P2",
        "TODO: CI P3",
        "TODO: CI Nice2Have",
        "NOTE: CI",
        "GOAL: zakkhoyt"
        // "zakk",
        // "FIXME:",
        // "TODO:",
        // "IDEA:",
        // "NICE:"
    ],
    // case .aqua: "#00FFFF"
    // case .black: "#000000"
    // case .blue: "#0000FF"
    // case .fuchsia: "#FF00FF"
    // case .gray: "#808080"
    // case .green: "#008000"
    // case .lime: "#00FF00"
    // case .maroon: "#800000"
    // case .navy: "#000080"
    // case .olive: "#808000"
    // case .purple: "#800080"
    // case .red: "#FF0000"
    // case .silver: "#C0C0C0"
    // case .teal: "#008080"
    // case .white: "#FFFFFF"
    // case .yellow: "#FFFF00"
    "todo-tree.highlights.backgroundColourScheme": [
        // "bf00ff", // "CIStablity: " - purple
        "orange", // "P0: zakkhoyt"
        "red", // "FIXME: zakkhoyt"
        "maroon", // "TODO: zakkhoyt"
        "00b3e6", // "IDEA: zakkhoyt" - dark cyan
        "green", // "NICE: zakkhoyt"
        "#dd00dd"
        // "rgb(250,0,0)", //  "TODO: CI P0",
        // "rgb(242,13,13)", //  "TODO: CI P1",
        // "rgb(230,26,26)", //  "TODO: CI P2",
        // "rgb(217,38,38)", //  "TODO: CI P3",
        // "rgb(204,51,51)", //  "TODO: CI Nice2Have",
        // "rgb(255,179,0)", //  "NOTE: CI",
        // "rgb(255,89,9)", //  "GOAL: zakkhoyt",
    ],
    "todo-tree.highlights.foregroundColourScheme": [
        // "white", // "CIStablity: " - purple
        "navy", // "P0: zakkhoyt"
        "white", // "FIXME: zakkhoyt"
        "white", // "TODO: zakkhoyt"
        "white", // "IDEA: zakkhoyt" - dark cyan
        "white", // "NICE: zakkhoyt"
        "white"
        // "white", // "TODO: CI P0",
        // "white", // "TODO: CI P1",
        // "white", // "TODO: CI P2",
        // "white", // "TODO: CI P3",
        // "white", // "TODO: CI Nice2Have",
        // "white", // "NOTE: CI",
        // "white", // "GOAL: zakkhoyt",
        // "white",
        // "white",
        // "white",
        // "white",
        // "#880b8b"
    ],
    "todo-tree.highlights.useColourScheme": true,
    "todo-tree.regex.subTagRegex": ".*(HSD-[0-9]{2,6}).*",
    "todo-tree.tree.autoRefresh": false,
    "todo-tree.tree.buttons.groupBySubTag": true,
    "todo-tree.tree.groupedBySubTag": true,
    "todo-tree.tree.showCountsInTree": true,
    "todo-tree.tree.subTagClickUrl": "https://hatchbaby.atlassian.net/browse/${subTag}",
    "vsicons.dontShowNewVersionMessage": true,
    "window.commandCenter": true,
    "workbench.activityBar.location": "top",
    "workbench.editorAssociations": {
        "*.ipynb": "jupyter-notebook"
    },
    "workbench.panel.location": "bottom",
    "workbench.productIconTheme": "macos-modern",
    "workbench.sash.hoverDelay": 30,
    "workbench.secondarySideBar.showLabels": false,
    "workbench.startupEditor": "none",
    "yaml.schemas": {
        "file:///Users/zakkhoyt/.vscode/extensions/atlassian.atlascode-4.0.11/resources/schemas/pipelines-schema.json": "bitbucket-pipelines.yml"
    }
}
```




# User mcp.json

```json
{
	"servers": {
		"github/github-mcp-server": {
			"type": "http",
			"url": "https://api.githubcopilot.com/mcp/",
			"gallery": "https://api.mcp.github.com/2025-09-15/v0/servers/ab12cd34-5678-90ef-1234-567890abcdef",
			"version": "0.13.0"
		},
		// "mcp-atlassian": {
		// 	"command": "docker",
		// 	"args": [
		// 		"run",
		// 		"--rm",
		// 		"-i",
		// 		// "--env-file", "${workspaceFolder}/.vscode/atlassian.env",
		// 		// "--env-file", "/Users/zakkhoyt/.hatch/config/vscode/mcp-atlassian.env",
		// 		"--env-file", "$HOME/.hatch/config/vscode/mcp-atlassian.env",
		// 		"ghcr.io/sooperset/mcp-atlassian:latest",
		// 		"--transport", "stdio"
		// 	],
		// 	"type": "stdio"
		// }

		// Use a wrapper script to inject env vars from the user's shell
		// ```zsh
		// # $HOME/.hatch/scripts/mcp-atlassian-wrapper.sh
		// #!/usr/bin/env zsh
		// docker run --rm -i \
		// 	-e JIRA_URL="$MY_JIRA_URL" \
		// 	-e JIRA_USERNAME="$MY_JIRA_USER" \
		// 	-e JIRA_API_TOKEN="$MY_JIRA_TOKEN" \
		// 	ghcr.io/sooperset/mcp-atlassian:latest \
		// 	--transport stdio
		// ```
		"mcp-atlassian": {
			// "command": "/Users/zakkhoyt/.hatch/scripts/_source/mcp_atlassian_wrapper/mcp_atlassian_wrapper.zsh",
			"command": "/Users/zakkhoyt/.hatch/scripts/mcp_atlassian_wrapper.zsh",
			"args": [],
			"type": "stdio"
		}
	},
	"inputs": []
}
```

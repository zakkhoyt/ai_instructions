# Icons and Images

This reference covers icon acquisition, types, sizing, naming conventions, and usage markup.

---

## Central Backing Store

All icons and banners are managed through a central backing store to avoid duplicate downloads and ensure consistency across repositories.

| Location                         | Purpose                                             |
| -------------------------------- | --------------------------------------------------- |
| `~/.ai/docs/images/icons/`       | Permanent cache — shared across all projects        |
| `docs/images/icons/`             | Project copy — used in markdown links               |

**Flow**: Internet → `~/.ai/docs/images/icons/` → `docs/images/icons/`

When a new icon is obtained, store it in the central backing store first, then copy to the project directory.

---

## Image Types

Two distinct image types are used for apps, tools, companies, and hardware vendors:

| Type   | Filename pattern         | Aspect ratio  | Inline `height` | Standalone `height` |
| ------ | ------------------------ | ------------- | --------------- | ------------------- |
| Icon   | `${service}_icon.png`   | Square (~1:1) | `16`            | `64`                |
| Banner | `${service}_banner.png` | Wide (>3:1)   | Never           | `64`                |

- **Icons** — may be used inline with text or as standalone displays
- **Banners** — standalone only; never inline with text

---

## HTML Markup

Always use `<img>` tags (never `![alt](src)` markdown syntax). Use the `height` attribute (not `width`) for icons and banners so the browser auto-sizes the other dimension.

> [!IMPORTANT]
> Never specify both `width` and `height` on the same `<img>` tag — set only one dimension and let the browser preserve aspect ratio.

### Inline with Text (Icons Only)

```html
<img src="docs/images/icons/xcode_icon.png" alt="xcode_icon" height="16">
```

### Standalone Display (Icons or Banners)

```html
<!-- Icon standalone -->
<img src="docs/images/icons/xcode_icon.png" alt="xcode_icon" height="64">

<!-- Banner standalone -->
<img src="docs/images/icons/github_actions_banner.png" alt="github_actions_banner" height="64">
```

### Alt Text

Derive `alt` from the basename of the file without extension:

| File                          | `alt` value               |
| ----------------------------- | ------------------------- |
| `xcode_icon.png`              | `xcode_icon`              |
| `github_actions_banner.png`   | `github_actions_banner`   |
| `mac_stadium_icon.png`        | `mac_stadium_icon`        |

---

## Usage Examples

### Inline Icon with App Name

```markdown
Install <img src="docs/images/icons/xcode_icon.png" alt="xcode_icon" height="16"> `Xcode` using the `xcodes` CLI.

Configure <img src="docs/images/icons/github_icon.png" alt="github_icon" height="16"> `GitHub Actions` runners.

Provision hardware from <img src="docs/images/icons/mac_stadium_icon.png" alt="mac_stadium_icon" height="16"> `MacStadium`.
```

### Standalone Banner

```markdown
## Development Tools

<img src="docs/images/icons/xcode_banner.png" alt="xcode_banner" height="64">

Apple's integrated development environment for macOS and iOS.

---

<img src="docs/images/icons/github_actions_banner.png" alt="github_actions_banner" height="64">

Continuous integration and deployment platform.
```

---

## Naming Conventions

- Icons: `${service}_icon.png` — e.g., `xcode_icon.png`, `github_actions_icon.png`
- Banners: `${service}_banner.png` — e.g., `xcode_banner.png`, `github_actions_banner.png`
- Use `snake_case` for multi-word service names

---

## Acquisition Fallback Chain

When an icon or banner is not in the backing store, try these sources in order:

### 1. Extract from `*.app` Bundle (macOS Only)

```zsh
# -s: source file
# -f: output format
# --out: output file path
sips --setProperty format png /Applications/Xcode.app/Contents/Resources/AppIcon.icns \
  --out ~/.ai/docs/images/icons/xcode_icon.png
```

### 2. Check Local Documentation

Look for official product icons in PDFs or user manuals related to the product (cover pages, headers).

### 3. Official Application Website or Documentation

Visit the official website or product documentation. Extract a favicon or download a high-quality version of the product icon.

### 4. DuckDuckGo Image Search (Public Domain Only)

```zsh
# Search for small, public-domain images
# URL encoding: spaces → +, filter separator → %2C
# iaf=size%3ASmall%2Clicense%3APublic → size:Small, license:Public
open "https://duckduckgo.com/?q=xcode+icon&iar=images&iaf=size%3ASmall%2Clicense%3APublic"
```

### 5. No Suitable Image Found — Use Text Only

> [!CAUTION]
> Do NOT use a placeholder or wrong icon. A wrong icon is misleading and disorienting. If the correct icon cannot be found, omit it entirely and use a text-only reference.

---

## Common Entities

Add icons and banners for these when mentioned in documentation:

| Entity           | Icon filename              | Banner filename              |
| ---------------- | -------------------------- | ---------------------------- |
| `Xcode`          | `xcode_icon.png`           | `xcode_banner.png`           |
| `Homebrew`       | `homebrew_icon.png`        | `homebrew_banner.png`        |
| `Fastlane`       | `fastlane_icon.png`        | `fastlane_banner.png`        |
| `Ruby`           | `ruby_icon.png`            | `ruby_banner.png`            |
| `GitHub`         | `github_icon.png`          | `github_banner.png`          |
| `GitHub Actions` | `github_actions_icon.png`  | `github_actions_banner.png`  |
| `macOS`          | `macos_icon.png`           | `macos_banner.png`           |
| `iOS`            | `ios_icon.png`             | `ios_banner.png`             |
| `Apple`          | `apple_icon.png`           | `apple_banner.png`           |

This list is not exhaustive — add icons for any app, company, or hardware vendor mentioned in documentation.

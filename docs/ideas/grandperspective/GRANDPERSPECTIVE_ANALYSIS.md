# GrandPerspective Analysis

## Purpose and Workflow
GrandPerspective scans a chosen folder (or volume) and renders a treemap where each rectangle corresponds to a file or group of files; area is proportional to size, and hovering/locking the selection exposes metadata and actions such as Open, Reveal, Quick Look, and Delete ([docs/ideas/grandperspective/references/GrandPerspectiveHelp/Views.html](docs/ideas/grandperspective/references/GrandPerspectiveHelp/Views.html), [docs/ideas/grandperspective/references/GrandPerspectiveHelp/NavigatingViews.html](docs/ideas/grandperspective/references/GrandPerspectiveHelp/NavigatingViews.html)). Filters and masks can be applied either before scanning (Filtered Scan, Default Filter preference) or after the fact via the Display tab, letting you hide cloud-only files, version-control folders, large binaries, etc. without discarding their contribution to the reported sizes ([docs/ideas/grandperspective/references/GrandPerspectiveHelp/MasksAndFilters.html](docs/ideas/grandperspective/references/GrandPerspectiveHelp/MasksAndFilters.html), [docs/ideas/grandperspective/references/Names.strings](docs/ideas/grandperspective/references/Names.strings)).

## Data Model and File Format
Every scan can be saved as a `.gpscan` file. The on-disk structure is plain XML that captures the folder tree, per-node sizes (logical, physical, or tally), timestamps, and any annotations added in the Info tab, then the XML is gzipped for storage ([docs/ideas/grandperspective/references/GrandPerspectiveHelp/SavingViewContents.html](docs/ideas/grandperspective/references/GrandPerspectiveHelp/SavingViewContents.html)). Because the payload is structured XML, it can be losslessly converted to JSON/JSON5 or streamed through `yq`/`jq`, and it can be base64-encoded when embedding inside other documents. Third-party tools such as the Rust-based `gpscan` emit exactly the same format, which is why GrandPerspective can visualize headless scans kicked off elsewhere ([docs/ideas/grandperspective/references/web/gpscan_README.md](docs/ideas/grandperspective/references/web/gpscan_README.md)).

## Visualization Stack
The Display tab exposes three major choices:

- **Color mapping** — Creation/Modification/Access times, Extension, Uniform Type Identifier, Folder, Top folder, Level, Name, or a flat color (Nothing). These mappings drive the legend and help correlate related files ([docs/ideas/grandperspective/references/GrandPerspectiveHelp/ViewDisplayPanel.html](docs/ideas/grandperspective/references/GrandPerspectiveHelp/ViewDisplayPanel.html)).
- **Palette** — Fifteen built-in `.clr` lists (Olive sunset, Moss and lichen, Monaco, Bujumbura, Coffee beans, Blue sky tulips, Origami mice, Green eggs, Feng Shui, Daytona Beach, Magenta magic, Rainbow, Lagoon nebula, Heatmap 23, Heatmap 12) that affect how many unique colors are available for a mapping ([docs/ideas/grandperspective/references/Names.strings](docs/ideas/grandperspective/references/Names.strings)).
- **Visibility** — Show Files, Packages & Files, or Packages & Folders. This determines how aggressively items are grouped; packages can be collapsed to single rectangles, or everything can be left at file granularity ([docs/ideas/grandperspective/references/GrandPerspectiveHelp/ViewDisplayPanel.html](docs/ideas/grandperspective/references/GrandPerspectiveHelp/ViewDisplayPanel.html)).

Display focus and selection focus controls (toolbar buttons, mouse wheel, View menu) further limit how deep the treemap renders and which ancestor gets highlighted, enabling high-level overviews or precise drilling with the same dataset ([docs/ideas/grandperspective/references/GrandPerspectiveHelp/NavigatingViews.html](docs/ideas/grandperspective/references/GrandPerspectiveHelp/NavigatingViews.html)).

## Preferences and Actions
Key preference groups:

- **Scanning** — Choose Logical/Physical/Tally file sizes, Binary vs Decimal units, and a default filter to skip unwanted folders during new scans ([docs/ideas/grandperspective/references/GrandPerspectiveHelp/FileSizes.html](docs/ideas/grandperspective/references/GrandPerspectiveHelp/FileSizes.html), [docs/ideas/grandperspective/references/GrandPerspectiveHelp/Preferences.html](docs/ideas/grandperspective/references/GrandPerspectiveHelp/Preferences.html)).
- **Display** — Seed new views with preferred color mapping, palette, mask, and show mode, toggle "Show entire volume", and pick the initial display focus (Unlimited by default; runtime focus is adjusted via View > Display Focus) ([docs/ideas/grandperspective/references/GrandPerspectiveHelp/Preferences.html](docs/ideas/grandperspective/references/GrandPerspectiveHelp/Preferences.html)).
- **Actions** — Decide whether deletion is disabled, file-only, or folder-inclusive, whether confirmation is required, what happens to the old window after a rescan, and what happens when the last window closes (Show Welcome, Quit, or Do nothing) ([docs/ideas/grandperspective/references/GrandPerspectiveHelp/Preferences.html](docs/ideas/grandperspective/references/GrandPerspectiveHelp/Preferences.html), [docs/ideas/grandperspective/references/Names.strings](docs/ideas/grandperspective/references/Names.strings)).

During an active session the toolbar duplicates most actions (Focus +/-/Reset, Zoom +/-/Reset, Refresh/Rescan, Delete, Open, Quick Look, Reveal), ensuring that both mouse-driven and keyboard-driven workflows are supported.

## Automation and Extensibility
GrandPerspective itself has no CLI switches, but two automation vectors exist:

1. **Pure shell** — Use `gpscan` (Homebrew `kojix2/brew/gpscan`) to crawl directories headlessly and feed the resulting `.gpscan` into `open -a GrandPerspective`. This keeps scripts in `zsh` but still benefits from the GUI for visualization ([docs/ideas/grandperspective/references/web/gpscan_README.md](docs/ideas/grandperspective/references/web/gpscan_README.md)).
2. **AppleScript + System Events** — Drive menu items such as `Scan Folder…`, `Rescan`, `Export As Image…`, or `Load Scan Data…`, type paths into dialogs, and even enumerate pop-up options (e.g., filters, palettes) programmatically. This is the only way to automate end-to-end scans via the GUI because the app does not expose a headless mode.

## Inputs, Outputs, and Limitations
Inputs are either live filesystem scans (with optional masks/filters) or previously saved `.gpscan` files. Outputs include:

- `.gpscan` (gzipped XML), suitable for archiving or sharing ([docs/ideas/grandperspective/references/GrandPerspectiveHelp/SavingViewContents.html](docs/ideas/grandperspective/references/GrandPerspectiveHelp/SavingViewContents.html)).
- TIFF snapshots via Export As Image; these reflect the current display settings and are useful for reports.
- Tab-delimited text exports that list every file with whatever columns you select, for downstream shell processing.

GrandPerspective’s main constraints today are the lack of a public CLI, limited export formats (TIFF + text only), and an aging UI toolkit that makes automation necessary for scripting. Those gaps motivate the replacement plan in the next document.

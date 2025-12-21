# GrandPerspective Replacement Plan

## Goals
Build a portable scanner/visualizer that matches GrandPerspective’s feature set (treemap rendering, filters/masks, focus controls, palette management) while adding modern automation hooks, richer export formats, and cross-platform libraries. All recommendations below trace back to the gaps and requirements captured in [docs/ideas/grandperspective/WIP_GRANDPERSPECTIVE.md](docs/ideas/grandperspective/WIP_GRANDPERSPECTIVE.md) and the analysis document.

## Language Recommendation
Use Swift end-to-end:

1. **Swift Package Manager project** — one library target (`DiskUsageCore`) for scanning, data modeling, and serialization; one executable target for the CLI/daemon; and optionally one App target (via SwiftUI) for a native macOS UI. Swift makes it easy to call low-level POSIX APIs, integrates with SwiftUI/CoreGraphics for rendering, and is already the preferred language per the constraints list.
2. **Bridging to shell** — expose thin `zsh` entry points that call the Swift executable so existing scripts can drive scans, mirroring how `gpscan` slots into `open -a GrandPerspective` ([docs/ideas/grandperspective/references/web/gpscan_README.md](docs/ideas/grandperspective/references/web/gpscan_README.md)).

## Plot Types to Consider
- **Primary** — Treemap (squarified) to preserve the mental model current users expect ([docs/ideas/grandperspective/references/GrandPerspectiveHelp/Views.html](docs/ideas/grandperspective/references/GrandPerspectiveHelp/Views.html)).
- **Secondary** — Offer Sunburst, Icicle, and Circle-Packing views powered by the same tree data so users can pivot to radial or hierarchical strip charts when treemaps feel cluttered ([docs/ideas/grandperspective/references/PLOTLY.md](docs/ideas/grandperspective/references/PLOTLY.md)).
- **Tertiary** — Histograms/line charts (via SwiftCharts) showing age distributions or growth over time.

## Data Structures to Use
- Store the filesystem snapshot as a persistent tree: each node keeps `path`, `type`, `logicalSize`, `physicalSize`, `mtime`, `ctime`, `atime`, `children[]`, and optional `filterFlags` (cloud-only, hard-link, etc.).
- Maintain an adjacency list or parent-pointer array for fast traversal when computing treemap rectangles.
- Cache aggregated metrics (total size, file counts) at each node to avoid recomputation when users adjust filters or focus.

## Data Format Translations
- **Native** — Continue writing `.gpscan`-compatible gzipped XML for instant interoperability with GrandPerspective ([docs/ideas/grandperspective/references/GrandPerspectiveHelp/SavingViewContents.html](docs/ideas/grandperspective/references/GrandPerspectiveHelp/SavingViewContents.html)).
- **Modern** — Add JSON/JSON5 export (tree model serialized using the structure above) and CSV/TSV dumps for pipelines.
- **Graph** — Emit `.dot` files so Graphviz’s `patchwork` layout can recreate treemaps or alternative layouts, and include optional `.puml`/`.mermaid` snippets to document interesting slices ([docs/ideas/grandperspective/references/GRAPHVIZ.md](docs/ideas/grandperspective/references/GRAPHVIZ.md)).
- **Binary snapshot** — Provide an option to base64 the gzipped XML when embedding in APIs or syncing to cloud storage.

## Graph Rendering
- Use CoreGraphics for the treemap renderer so both CLI (via `swift run render --format png`) and GUI targets share the same drawing code. Build a thin Scene/Renderer abstraction so the same tree can be fed to Graphviz (`patchwork` for treemap, `dot/neato` for network views) or to SwiftUI for interactive zoom/focus controls.
- Manage palettes via JSON or `NSColorList` files mirroring the built-in options (Olive sunset, Heatmap 23, etc.) so users can extend them ([docs/ideas/grandperspective/references/Names.strings](docs/ideas/grandperspective/references/Names.strings)).
- Overlay focus rectangles, selection outlines, and legends using SwiftUI so accessibility (VoiceOver, Dynamic Type) comes for free.

## Image Formats
- **Vector** — SVG and PDF from CoreGraphics for documentation-quality exports; keep layer metadata so rectangles remain selectable in Illustrator.
- **Raster** — PNG and JPEG for quick sharing; support Retina/non-Retina and color-profile embedding.
- **Document** — Continue offering tabular TSV/CSV and `.gpscan` for archival.

## Automation and CLI
- Provide a first-class CLI (`diskmap scan <path> --filter no-cloud --format gpscan,json`) that emits structured output or launches the viewer. Mimic `gpscan` flags (apparent size, cross-mounts, include zero-byte files) so existing shell scripts migrate easily ([docs/ideas/grandperspective/references/web/gpscan_README.md](docs/ideas/grandperspective/references/web/gpscan_README.md)).
- Offer an AppleScript/Shortcuts bridge for GUI automations (`diskmap://scan?path=...`).
- Ship Homebrew formulae/taps so installation mirrors today’s `brew install grandperspective` flow ([docs/ideas/grandperspective/references/GRANDPERSPECTIVE.md](docs/ideas/grandperspective/references/GRANDPERSPECTIVE.md)).

## Export and Sharing Strategy
- Let users bundle scans plus styles into a single `.diskmap` package (gzipped JSON + palette + legend config).
- Support batch exporting (multiple folders, scheduled scans) by writing CLI-friendly config files (YAML/JSON) that list target paths, masks, and desired outputs.
- Keep an eye toward publishing data to web dashboards (e.g., Plotly Sunburst via `plotly.py` or Plotly Swift wrappers) for remote review.

## Roadmap Highlights
1. **Phase 1** — Implement the Swift scanner + `.gpscan` writer, plus a CLI that mirrors `gpscan` feature parity.
2. **Phase 2** — Add CoreGraphics treemap renderer, SVG/PNG export, palettes, and sample legends.
3. **Phase 3** — Ship the SwiftUI macOS app with live focus controls, info panels, deletion toggles, and AppleScript dictionary.
4. **Phase 4** — Layer in alternate charts (Sunburst/Icicle), JSON/dot exports, and scheduling/automation features.

This plan ensures the replacement stays faithful to GrandPerspective’s proven UX while unlocking automation, richer exports, and extensibility that modern workflows demand.

#!/usr/bin/env -S zsh -euo pipefail

# Extract icons from macOS applications
# This script extracts app icons and prepares them for use in documentation

icon_dir="$(cd "$(dirname "$0")" && pwd)"
target_size=32

echo "📦 Extracting icons from macOS applications..."
echo "Target directory: $icon_dir"
echo "Target size: ${target_size}x${target_size}px"
echo ""

# Function to extract icon from app
extract_icon() {
  local app_path="$1"
  local icon_name="$2"
  local output_path="$icon_dir/${icon_name}.png"
  
  if [[ ! -d "$app_path" ]]; then
    echo "⚠️  App not found: $app_path"
    return 1
  fi
  
  # Find the icon file (usually .icns)
  local icon_file=$(find "$app_path/Contents/Resources" -name "*.icns" | head -1)
  
  if [[ -z "$icon_file" ]]; then
    echo "⚠️  No icon found in: $app_path"
    return 1
  fi
  
  echo "✅ Extracting: $icon_name from $app_path"
  
  # Convert ICNS to PNG at target size
  sips -s format png -z "$target_size" "$target_size" "$icon_file" --out "$output_path" &>/dev/null
  
  echo "   → Saved to: $output_path"
}

# Extract icons from installed apps
extract_icon "/Applications/Xcode.app" "xcode"
extract_icon "/Applications/iTerm.app" "iterm"
extract_icon "/Applications/Visual Studio Code.app" "vscode"
extract_icon "/System/Applications/Utilities/Terminal.app" "terminal"

echo ""
echo "✨ Icon extraction complete!"
echo ""
echo "Next steps:"
echo "1. Download additional icons from web sources (see ICON_SOURCES.md)"
echo "2. Add corner rounding to icons if desired (optional)"
echo "3. Verify icons render correctly in markdown"
echo ""
echo "Manual downloads needed:"
echo "  - homebrew.png (https://brew.sh/)"
echo "  - fastlane.png (https://fastlane.tools/)"
echo "  - ruby.png (https://www.ruby-lang.org/)"
echo "  - github.png (https://github.com/logos)"
echo "  - github_actions.png (https://github.com/logos)"
echo "  - macos.png (Apple branding)"
echo "  - ios.png (Apple branding)"
echo "  - apple.png (Apple logo)"
echo "  - hatch.png (Hatch branding - internal)"
echo "  - mac_stadium.png (https://www.macstadium.com/)"
echo "  - lastpass.png (https://www.lastpass.com/)"



ActionItems
* [ ] Re-read AI instructions, especially `markdown`, `zsh`, and `swift`
* [ ] Read this entire document and carry out the research mentioned: `docs/ideas/grandperspective/WIP_GRANDPERSPECTIVE.md`
* [ ] Check off every box in this document before then writing a couple of new documents:
* [ ] `docs/ideas/grandperspective/GRANDPERSPECTIVE_ANALYSIS.md` - This document will detail everything about the GrandPerspective app
  * How it works
  * Data formats
  * Graph types
  * How to control it from CLI
  * Every UI control, options, settings, and every type of input and output
* [ ] `docs/ideas/grandperspective/GRANDPERSPECTIVE_REPLACMENT_PLAN.md` - 
  * [ ] Write up a document that considers all of the considerations mentioned in this document
  * [ ] Make a recommendation on each
  * [ ] Language to use
  * [ ] Plot types to consider
  * [ ] Data Structures to use
  * [ ] data format translations
  * [ ] Graph Rendering 
  * [ ] Image formats


# Grand Perspective

This computer has the application installed:

```zsh
/Applications/GrandPerspective.app
/Applications/GrandPerspective.app/Contents/MacOS/GrandPerspective
```  

which scans directory hierarchies and generates box plots that represent files on disk (in terms of disk usage).


## Intermediate "Data" Format

GrandPerspective's Outputs (not rendered images)

* [ ] What does the data for those formats look like? Is it text? binary? 
  * [ ] Can it be represented in JSON?
  * [ ] Can it be represented in base64?
* [ ] What other apps can read/write that format?

GrandPerspective's Inputs
* [ ] It looks like GrandPerspective can load "scan data" files. What kind of format/standard is it expecting? 
  * [ ] Is this the same as the output format?



* [ ] Are there existing standards to represent disk usage / disk free data and how the storage is allocated throughout the dir hierarchies? 
* [ ] What are other modern apps and tools that do this kind of thing? 
  * [ ] Is there anything in homebrew?


* I really want to be able to control GrandPerspective from command line. EX: Launch and begin a scan on some directory. 
  * I can't figure out how to do that from a `zsh` script. There is no `--help`, no `man`, etc...
* [ ] how can i control GrandPerspective in this manner using zsh only?
* [ ] how can i control GrandPerspective in this manner using zsh + osascript?




# Graphing How Disk Space is Used / Free

The goal is to write up a new library that can do what GrandPerspective does plus some. 
The implementation is undecided so far, but I'd like:
<!-- 
* Scan result data to use well established file formats and conventions
* render a session from memory (after a scan)
* save the session to disk for loading later
* render a session from a file (after a scan)
* Be able to render the scan of the disk usage
* Be able to render a legend key 
* Be able to render styled text as (info panels)

 -->



## Programming Languages


* `zsh` - raw zsh scripting using:
  * cli tools that ship with `macOS`
  * Anythign we can install with `homebrew` on a mac
* `swift` package manager
  * make an executable target (swift argument parser) to provide a CLI interface & wrapper around the library
  * make a library target to do the disk space computing / crawling
  * library can depend on SwiftShell (a `zsh` bridge from `Swift`, allowing access to that world)
  * much more capable at handling JSON computations vs zsh
* `xcode` + `swift`. We could make a full macOS application. This is less desirable is it now limits users to macOS, and limits devs to `mac` + `xcode`, but doable
  * has a GUI
  * applicatoin menus
  * supports system menus / icon menus
  * roll our own graphs with `CoreGraphics` / `SwiftUI`
  * Display custom graphs with `SwiftCharts` (not sure if it supports the graph types)

I'd prefer not to use `python` for this project. i know it has great graphing libraries, but zsh and swift

## Graph Types
* [ ] `box plot` - Confirm this is the plot type the GrandPerspective uses to display?  Are there any aliases for this?
* [ ] What are some other graph types that can show how diskspace is consumed?

## Graphing Libraries

These are the graphing options that I am comfortable with considering for this project. 
For each, list if it is up to the job, 
* [ ] mermaid * display in markdown or other dedicated viewers
  * [ ] output markdown or mermaid files
  * [ ] Does not output rendered files, but I'm sure there are tools that can render mermaid
* [ ] plantUML - data stored in human readable `*.puml` files
  * [ ] outputs `*.puml` files
  * [ ] Can be rendered out to svg, pdf, png, etc...
  * [ ] Also from what I understand these can be converted to `dot` and `mermaid`. I have no experience though
* [ ] graphviz - I've done a lot with graphviz
  * [ ] outputs `*.dot` files
  * [ ] Can be rendered out to svg, pdf, png, etc...
* [ ] CoreGraphics / SwiftUI. We can graph our make our own if need be
* [ ] SwiftCharts. I'm not sure if this has the built in types we are after
* [ ] Other OpenSource swift graphing libraries which can render the plots we are after?


## Output File Types

* "Scan Data" (what ever GrandPerspective outputs), or equivalent
* Vector graphics iamge format (*.svg, *.pdf)
* Rasterized image format (*.png, *.jpg)
* ideally, a JSON/JSON5 representation of the scan session
* ideally, a text format of the plot. *.dot, *.puml, *.mermaid, etc... That  kind of a thing



## Library Options

I'd like you to dig into GrandPerspective and document all of it's features and options
Below are many screenshots that I took of GrandPerspective's UI which are stored under `~/.ai/docs/ideas/grandperspective/images`. The filepath and filename are suggestive of the content

* Select a staring dir to scan<br>
  * <img alt="Select a staring dir to scan" src="images/select_dir_to_scan/GrandPerspective_scan_select_start_dir_00.png" width="300"><br>
* Select a staring dir to scan<br>
  * <img alt="Select a staring dir to scan" src="images/select_dir_to_scan/GrandPerspective_scan_select_start_dir_01.png" width="300"><br>
* Select a staring dir to scan<br>
  * <img alt="Select a staring dir to scan" src="images/select_dir_to_scan/GrandPerspective_scan_select_start_dir_02.png" width="300"><br>
* Scanning in progress<br>
  * <img alt="Scanning in progress" src="images/scanning/GrandPerspective_scanning_03.png" width="300"><br>
* Scanning in progress<br>
  * <img alt="Scanning in progress" src="images/scanning/GrandPerspective_scanning_04.png" width="300"><br>
* Scanning in progress<br>
  * <img alt="Scanning in progress" src="images/scanning/GrandPerspective_scanning_05.png" width="300"><br>
* Scan Session - no file selected<br>
  * <img alt="Scan Session - no file selected" src="images/scan_session/GrandPerspective_scan_session_no_selection.png" width="300"><br>
* Scan Session - a file selected (file size, filepath)<br>
  * <img alt="Scan Session - a file selected (file size, filepath)" src="images/scan_session/GrandPerspective_scan_session_file_selected.png" width="300"><br>
* Scan Session - open selection with Quicklook<br>
  * <img alt="Scan Session - open selection with Quicklook" src="images/scan_session/GrandPerspective_scan_session_quicklook.png" width="300"><br>
* Scan Session - open selection in Finder<br>
  * <img alt="Scan Session - open selection in Finder" src="images/scan_session/GrandPerspective_scan_session_reveal_in_finder.png" width="300"><br>
* Scan Session - Show scan session in the context of entire disk volume<br>
  * <img alt="Scan Session - Show scan session in the context of entire disk volume" src="images/scan_session/GrandPerspective_scan_session_show_in_volume.png" width="300"><br>
* Scan Session - Select a file<br>
  * <img alt="Scan Session - Select a file" src="images/scan_session/select_files/GrandPerspective_selection_01.png" width="300"><br>
* Scan Session - Select a file<br>
  * <img alt="Scan Session - Select a file" src="images/scan_session/select_files/GrandPerspective_selection_02.png" width="300"><br>
* Scan Session - Before expand focus (highlight file's parent dir)<br>
  * <img alt="Scan Session - Before expand focus (highlight file's parent dir)" src="images/scan_session/focus/GrandPerspective_focus_01.png" width="300"><br>
* Scan Session - After expand focus (highlight file's parent dir)<br>
  * <img alt="Scan Session - After expand focus (highlight file's parent dir)" src="images/scan_session/focus/GrandPerspective_focus_02.png" width="300"><br>
* Scan Session Info - Display (Tab)<br>
  * <img alt="Scan Session Info - Display (Tab)" src="scan_info/display/GrandPerspective_scan_display.png" width="300"><br>
* Scan Session Info - Display (Tab) / Color (Options List)<br>
  * <img alt="Scan Session Info - Display (Tab) / Color (Options List)" src="images/scan_info/display/GrandPerspective_scan_display_color_by.png" width="300"><br>
  * [ ] Extract list of options from the image, document here
* Scan Session Info - Display (Tab) / Mask (Options List)<br>
  * <img alt="Scan Session Info - Display (Tab) / Mask (Options List)" src="images/scan_info/display/GrandPerspective_scan_display_mask.png" width="300"><br>
  * [ ] Extract list of options from the image, document here
* Scan Session Info - Display (Tab) / Palette (Options List)<br>
  * <img alt="Scan Session Info - Display (Tab) / Palette (Options List)" src="images/scan_info/display/GrandPerspective_scan_display_palette.png" width="300"><br>
  * [ ] Extract list of options from the image, document here
* Scan Session Info - Display (Tab) / Show (Options List)<br>
  * <img alt="Scan Session Info - Display (Tab) / Show (Options List)" src="images/scan_info/display/GrandPerspective_scan_display_show.png" width="300"><br>
  * [ ] Extract list of options from the image, document here
* Scan Session Info - Info (Tab) / Details and Statistics<br>
  * <img alt="Scan Session Info - Info (Tab) / Details and Statistics" src="images/scan_info/info/GrandPerspective_scan_info_pane.png" width="300"><br>
* Scan Session Info - Focus (Tab) / Details and Statistics<br>
  * <img alt="Scan Session Info - Focus (Tab) / Details and Statistics" src="images/scan_info/focus/GrandPerspective_scan_focus.png" width="300"><br>
* Grand Perspective Menu / View / Display Focus (Options List)<br>
  * <img alt="Grand Perspective Menu / View / Display Focus (Options List)" src="images/menu/view/GrandPerspective_menu_view_display_focus.png" width="300"><br>
  * [ ] Extract list of options from the image, document here
* Grand Perspective Menu / View / Selection Focus (Options List)<br>
  * <img alt="Grand Perspective Menu / View / Selection Focus (Options List)" src="images/menu/view/GrandPerspective_menu_view_selection_focus.png" width="300"><br>
  * [ ] Extract list of options from the image, document here
* Grand Perspective Menu / View / Zoom Focus (Options List)<br>
  * <img alt="Grand Perspective Menu / View / Zoom Focus (Options List)" src="images/menu/view/GrandPerspective_menu_view_zoom.png" width="300"><br>
  * [ ] Extract list of options from the image, document here
* App Settings / Actions (Group) / After Closing Last View (Options List)<br>
  * <img alt="App Settings / Actions (Group) / After Closing Last View (Options List)" src="images/settings/actions/GrandPerspective_settings_actions_after_closing_last_view.png" width="300"><br>
  * [ ] Extract list of options from the image, document here
* App Settings / Actions (Group) / After Full Rescan (Options List)<br>
  * <img alt="App Settings / Actions (Group) / After Full Rescan (Options List)" src="images/settings/actions/GrandPerspective_settings_actions_after_full_rescan.png" width="300"><br>
  * [ ] Extract list of options from the image, document here
* App Settings / Actions (Group) / Enable Deletion Of (Options List)<br>
  * <img alt="App Settings / Actions (Group) / Enable Deletion Of (Options List)" src="images/settings/actions/GrandPerspective_settings_actions_enable_deletion_of.png" width="300"><br>
  * [ ] Extract list of options from the image, document here
* App Settings / Display (Group) / Color (Options List)<br>
  * <img alt="App Settings / Display (Group) / Color (Options List)" src="images/settings/display/GrandPerspective_settings_display_color_by.png" width="300"><br>
  * [ ] Extract list of options from the image, document here
* App Settings / Display (Group) / Display Focus (Options List)<br>
  * <img alt="App Settings / Display (Group) / Display Focus (Options List)" src="images/settings/display/GrandPerspective_settings_display_display_focus.png" width="300"><br>
  * [ ] Extract list of options from the image, document here
* App Settings / Display (Group) / Mask (Options List)<br>
  * <img alt="App Settings / Display (Group) / Mask (Options List)" src="images/settings/display/GrandPerspective_settings_display_mask.png" width="300"><br>
  * [ ] Extract list of options from the image, document here
* App Settings / Display (Group) / Palette (Options List)<br>
  * <img alt="App Settings / Display (Group) / Palette (Options List)" src="images/settings/display/GrandPerspective_settings_display_pallette.png" width="300"><br>
  * [ ] Extract list of options from the image, document here
* App Settings / Display (Group) / Show (Options List)<br>
  * <img alt="App Settings / Display (Group) / Show (Options List)" src="images/settings/display/GrandPerspective_settings_display_show.png" width="300"><br>
  * [ ] Extract list of options from the image, document here
* App Settings / Scanning (Group) / Default Filter (Options List)<br>
  * <img alt="App Settings / Scanning (Group) / Default Filter (Options List)" src="images/settings/scanning/GrandPerspective_settings_scanning_default_filter.png" width="300"><br>
  * [ ] Extract list of options from the image, document here
* App Settings / Scanning (Group) / File Measure Size (Options List)<br>
  * <img alt="App Settings / Scanning (Group) / File Measure Size (Options List)" src="images/settings/scanning/GrandPerspective_settings_scanning_file_measure_size.png" width="300"><br>
  * [ ] Extract list of options from the image, document here
* App Settings / Scanning (Group) / File Unit Measure System (Options List)<br>
  * <img alt="App Settings / Scanning (Group) / File Unit Measure System (Options List)" src="images/settings/scanning/GrandPerspective_settings_scanning_file_size_unit_system.png" width="300"><br>
  * [ ] Extract list of options from the image, document here






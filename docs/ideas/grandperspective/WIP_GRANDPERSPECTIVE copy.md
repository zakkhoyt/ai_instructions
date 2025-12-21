

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


## Graphing How Disk Space is Used / Free

### Graph Types
* `box plot` - Confirma this is the plot type the GrandPerspective uses to display?  Are there any aliases for this?
* What are some other graph types that can show how diskspace is consumed?

### Graphing Libraries
* mermaid * display in markdown or other dedicated viewers
* plantUML - data stored in human readable `*.puml` files
  * These can be rendered out to svg, pdf, png, etc...
  * Also from what I understand these can be converted to `dot` and `mermaid`. I have no experience though
* graphviz - 

### Programming Languages

* `zsh` - raw zsh scripting using:
  * cli tools that ship with `macOS`
  * Anythign we can install with `homebrew` on a mac
* `swift` package manager
  * make an executable target (swift argument parser) to provide a CLI interface & wrapper around the library
  * make a library target to do the disk space computing / crawling
  * library can depend on SwiftShell (a `zsh` bridge from `Swift`, allowing access to that world)
  * much more capable at handling JSON computations vs zsh
* xcode + swift. We could make a full macOS application:
  * has a GUI
  * applicatoin menus
  * supports system menus / icon menus
  * roll our own graphs with `CoreGraphics` / `SwiftUI`
  * Display custom graphs with `SwiftCharts` (not sure if it supports the graph types)

* Once we have a list of graph types, I'd like some lists generated

```

## Build own script to do GrandPerspective type things

* [ ] what's that graph style called?
* [ ] what's the file format that GP uses? 
  * [ ] are they any json equivalent formats?
  * [ ] how to generate one from shellscript?
  * [ ] how to generate one from swift?
  * [ ] which is more performant?
* [ ] what are our output options?:
  * 





* Below are many screenshots that I took of GrandPerspective's UI
* Files are organized into folders to indicate how they relate to each other
* On the left is the relative filepath which indicates something about what the image contains
* On the right (after `#`) is a comment about what the file shows

```zsh
$ cd ~/.ai/docs/ideas/grandperspective/images && find . -type f -name "*.png" | sort

./select_dir_to_scan/GrandPerspective_scan_select_start_dir_00.png                  # Select a staring dir to scan                                                             
./select_dir_to_scan/GrandPerspective_scan_select_start_dir_01.png                  # Select a staring dir to scan                                                             
./select_dir_to_scan/GrandPerspective_scan_select_start_dir_02.png                  # Select a staring dir to scan                                                              
./scanning/GrandPerspective_scanning_03.png                                         # Scanning in progress                                                             
./scanning/GrandPerspective_scanning_04.png                                         # Scanning in progress                                                             
./scanning/GrandPerspective_scanning_05.png                                         # Scanning in progress                                                             
./scan_session/GrandPerspective_scan_session_no_selection.png                       # Scan Session - no file selected                                                         
./scan_session/GrandPerspective_scan_session_file_selected.png                      # Scan Session - a file selected (file size, filepath)                                                          
./scan_session/GrandPerspective_scan_session_quicklook.png                          # Scan Session - open selection with Quicklook                                                      
./scan_session/GrandPerspective_scan_session_reveal_in_finder.png                   # Scan Session - open selection in Finder                                                             
./scan_session/GrandPerspective_scan_session_show_in_volume.png                     # Scan Session - Show scan session in the context of entire disk volume                                                          
./scan_session/select_files/GrandPerspective_selection_01.png                       # Scan Session - Select a file                                               
./scan_session/select_files/GrandPerspective_selection_02.png                       # Scan Session - Select a file                                               
./scan_session/focus/GrandPerspective_focus_01.png                                  # Scan Session - Before expand focus (highlight file's parent dir)
./scan_session/focus/GrandPerspective_focus_02.png                                  # Scan Session - After expand focus (highlight file's parent dir)                                    
./scan_info/display/GrandPerspective_scan_display.png                               # Scan Session Info - Display (Tab)
./scan_info/display/GrandPerspective_scan_display_color_by.png                      # Scan Session Info - Display (Tab) / Color (* [ ] Extract Options from Image, document)                                                             
./scan_info/display/GrandPerspective_scan_display_mask.png                          # Scan Session Info - Display (Tab) / Mask (* [ ] Extract Options from Image, document)                                                             
./scan_info/display/GrandPerspective_scan_display_palette.png                       # Scan Session Info - Display (Tab) / Palette (* [ ] Extract Options from Image, document)                                                             
./scan_info/display/GrandPerspective_scan_display_show.png                          # Scan Session Info - Display (Tab) / Show (* [ ] Extract Options from Image, document)                                                             
./scan_info/info/GrandPerspective_scan_info_pane.png                                # Scan Session Info - Info (Tab) / Details and Statistics
./scan_info/focus/GrandPerspective_scan_focus.png                                   # Scan Session Info - Focus (Tab) / Details and Statistics
./menu/view/GrandPerspective_menu_view_display_focus.png                            # Grand Perspective Menu / View / Display Focus (* [ ] Extract Options from Image, document)                                           
./menu/view/GrandPerspective_menu_view_selection_focus.png                          # Grand Perspective Menu / View / Selection Focus (* [ ] Extract Options from Image, document)                                                                                                        
./menu/view/GrandPerspective_menu_view_zoom.png                                     # Grand Perspective Menu / View / Zoom Focus (* [ ] Extract Options from Image, document)                                                                                                        
./settings/actions/GrandPerspective_settings_actions_after_closing_last_view.png    # App Settings / Actions (Group) / After Closing Last View (* [ ] Extract Options from Image, document)                                                              
./settings/actions/GrandPerspective_settings_actions_after_full_rescan.png          # App Settings / Actions (Group) / After Full Rescan (* [ ] Extract Options from Image, document)                                                             
./settings/actions/GrandPerspective_settings_actions_enable_deletion_of.png         # App Settings / Actions (Group) / Enable Deletion Of (* [ ] Extract Options from Image, document)                                                             
./settings/display/GrandPerspective_settings_display_color_by.png                   # App Settings / Display (Group) / Color (* [ ] Extract Options from Image, document)                                                             
./settings/display/GrandPerspective_settings_display_display_focus.png              # App Settings / Display (Group) / Display Focus (* [ ] Extract Options from Image, document)                                                             
./settings/display/GrandPerspective_settings_display_mask.png                       # App Settings / Display (Group) / Mask (* [ ] Extract Options from Image, document)                                                             
./settings/display/GrandPerspective_settings_display_pallette.png                   # App Settings / Display (Group) / Palette (* [ ] Extract Options from Image, document)                                                             
./settings/display/GrandPerspective_settings_display_show.png                       # App Settings / Display (Group) / Show (* [ ] Extract Options from Image, document)                                                             
./settings/scanning/GrandPerspective_settings_scanning_default_filter.png           # App Settings / Scanning (Group) / Default Filter (* [ ] Extract Options from Image, document)                                                             
./settings/scanning/GrandPerspective_settings_scanning_file_measure_size.png        # App Settings / Scanning (Group) / File Measure Size (* [ ] Extract Options from Image, document)                                                             
./settings/scanning/GrandPerspective_settings_scanning_file_size_unit_system.png    # App Settings / Scanning (Group) / File Unit Measure System (* [ ] Extract Options from Image, document)                                                             
```

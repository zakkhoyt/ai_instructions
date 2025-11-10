
# Markdown

* Add `mermaid` graphs where useful. For example: sequence diagrams or dependency graphs for code, timeline diagrams for git history, etc.. That kind of thing
* When overlaying colors (text, graphs, diagrams, images, etc...) choose colors that will be legible when overlapping. 
  * BAD: yellow text on a white image (low relative contast)
  * GOOD: black text on a white image (higher relative contast)
* When adding or selecting colors (text, graphs, etc...) prefer colors that will work well in both dark mode and light mode

* Prefer lists when the context is about choices, options, etc...
```markdown
<!-- Bad: there are 3 points of data here with a common subject -->
To make the configuration specific to the project, store your instuctions at `/Users/zakkhoyt/code/repositories/hatch/hatch_sleep/.ai_preferences.json5`. This is useful if preferences vary between projects.
```
```markdown
<!-- Good: related pieces of data should be displayed as lists. The common subject is the root bullet and subpoints as a sub-list -->
- `/Users/zakkhoyt/code/repositories/hatch/hatch_sleep/.ai_preferences.json5` (in project root)
  - Makes the configuration specific to the project
  - Useful if preferences vary between projects
```



# Link formatting

# Table of contents
# References

# Format Tables

* add padding and alignment like VScode extension "Format Table"

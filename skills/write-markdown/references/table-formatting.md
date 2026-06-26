# Table Formatting: Extended Examples and Anti-Patterns

This reference provides detailed examples of the mandatory rectangular table formatting rule. Read this when you need to verify table formatting or understand the anti-patterns.

## The Rule

Every markdown table MUST be formatted with padded columns to form a literal 2D rectangle in the source code. Every row must have identical character width. No exceptions.

## Extended Example 1: Multi-Column Data Table

### Correct (REQUIRED format)

```markdown
| Logic Pro Command    | Logic Shortcut   | REAPER Command                     | REAPER Shortcut                |
| -------------------- | ---------------- | ---------------------------------- | ------------------------------ |
| Show Smart Tempo     | Track menu       | Create Measure from Time Selection | Alt+Shift+C                    |
| Enable Flex          | Cmd+F            | Add Stretch Marker                 | Shift+W                        |
| Flex Tool            | Opt+Pointer      | Stretch Marker Drag                | Hover+Drag                     |
| Split at Cursor      | Cmd+T            | Split at Cursor                    | S                              |
| Quantize Audio       | Region Inspector | Quantize Items to Grid             | Right-click → Item Processing  |
| Navigate Transients  | (varies)         | Next Transient                     | Tab                            |
| Navigate Transients  | (varies)         | Previous Transient                 | Shift+Tab                      |
| Open Item Properties | (Inspector)      | Item Properties                    | F2                             |
| Insert Track         | Cmd+Opt+N        | Insert Track                       | Cmd+T                          |
```

### Incorrect (FORBIDDEN — jagged table)

```markdown
<!-- FORBIDDEN: Each line has different number of characters. Lines end at different column numbers. -->
| Logic Pro Command | Logic Shortcut | REAPER Command | REAPER Shortcut |
|-------------------|----------------|----------------|-----------------|
| Show Smart Tempo | Track menu | Create Measure from Time Selection | Alt+Shift+C |
| Enable Flex | Cmd+F | Add Stretch Marker | Shift+W |
| Flex Tool | Opt+Pointer | Stretch Marker Drag | Hover+Drag |
| Split at Cursor | Cmd+T | Split at Cursor | S |
| Quantize Audio | Region Inspector | Quantize Items to Grid | Right-click → Item Processing |
```

## Extended Example 2: Command Comparison Table

### Correct (REQUIRED format)

```markdown
| Cut-Like Task                           | `cut` Example                | Equivalent `awk`                                         | Notes                                                                                                 |
| --------------------------------------- | ---------------------------- | -------------------------------------------------------- | ----------------------------------------------------------------------------------------------------- |
| Extract field by delimiter              | `cut -d: -f1,3 /etc/passwd` | `awk -F: '{print $1 ":" $3}' /etc/passwd`               | `awk` lets you reorder and add text.                                                                  |
| Select tab-separated columns            | `cut -f2 file.tsv`          | `awk -F"\t" '{print $2}' file.tsv`                      | Quote the tab (`$'\t'` also works).                                                                   |
| Handle multiple delimiters              | *(requires `tr`/`perl`)*    | `awk -F'[,:]' '{print $1, $3}' data.txt`                | `cut` can't use regex separators; `awk` can.                                                          |
| Conditional extraction                  | *(needs pipeline)*          | `awk -F, '$4 == "CA" {print $1, $2}' addresses.csv`     | `cut` cannot add conditions.                                                                          |
| Preserve spacing when delimiter repeats | `cut -d, -f2` (collapses)  | `awk -F, '{print $2}'`                                  | `awk` can inspect empty fields even with consecutive delimiters by setting `FS` and optionally `OFS`. |
| Trim whitespace around fields           | *(needs `sed`)*             | `awk -F, '{gsub(/^ *| *$/,"", $2); print $2}' data.csv` | Use `gsub` to clean before printing.                                                                  |
| Print field ranges                      | `cut -d: -f2-4`            | `awk -F: '{print $2 ":" $3 ":" $4}'`                    | `awk` can also loop over fields if range length varies.                                               |
```

### Incorrect (FORBIDDEN — jagged table)

```markdown
| Cut-Like Task | `cut` Example | Equivalent `awk` | Notes |
| --- | --- | --- | --- |
| Extract field by delimiter | `cut -d: -f1,3 /etc/passwd` | `awk -F: '{print $1 ":" $3}' /etc/passwd` | `awk` lets you reorder and add text. |
| Select tab-separated columns | `cut -f2 file.tsv` | `awk -F"\t" '{print $2}' file.tsv` | Quote the tab (`$'\t'` also works). |
| Handle multiple delimiters | *(requires `tr`/`perl`)* | `awk -F'[,:]' '{print $1, $3}' data.txt` | `cut` can't use regex separators; `awk` can. |
```

## Implementation Notes

- Use VS Code extension "Format Tables" or similar tools to automatically format tables
- Manually pad tables when creating or editing if auto-formatting is unavailable
- The separator row (`| --- |`) must also be padded to match column widths using dashes
- Trailing whitespace inside cells is required to maintain the rectangle

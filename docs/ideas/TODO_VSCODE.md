# Extension for relative file (markdown & html) links
* autocompletion menu
* auto-populate `title` and `url`


# Extension for markdown validation
Check all relative links to see if anything is broken
* file links
* <a></a>`
* image links
* `<img>` 


# Extension for TOC / Refs / Sibling Files
* build a better CLI tool with `swift`
* wrapper around new command line tool




# Snippets

## Footnote Snippet

```markdown
Here is a simple footnote[^1].

A footnote can also have multiple lines[^2].

[^1]: My reference.
[^2]: To add line breaks within a footnote, add 2 spaces to the end of a line.  
This is a second line.
```



## Alerts Snippets

```markdown
> [!NOTE]
> Useful information that users should know, even when skimming content.

> [!TIP]
> Helpful advice for doing things better or more easily.

> [!IMPORTANT]
> Key information users need to know to achieve their goal.

> [!WARNING]
> Urgent info that needs immediate user attention to avoid problems.

> [!CAUTION]
> Advises about risks or negative outcomes of certain actions.



> [!${10:NOTE|TIP|IMPORTANT|WARNING|CAUTION}]
> ${20:message}


```





I'm looking to convert, fact check, and then migrate some AI instruction files to a new location.




Read & Understand these files:
* `/Users/zakkhoyt/Documents/notes/ai/**/*.md` - may have links to offical documentation
* Source: Instruction files: `~/.ai/instructions/**/*.md`
  * These files were written by/for `VSCode` AI engines
* The destination is: `~/.claude/rules/*.md`
  * These files should be formatted to best work with `Claude` / `Conductor`


# Action Items
## Phase 1
* Move a copy of all instructions from source to dest. 
  * Read / inventory all data from the instruction files
  * Blob all of that data together, then re-organized it into an outline (representing files/h1/h2/h3, etc...)
  * We do not need to keep the file names/count/content 1:1. Meaning, if it makes more sense to write the data to different files (more, less, etc...) that's definitely okay
* Propose final filenames and what they contain to me for confirmation
* Write the files after confirmation


## Phase 2
* Let's refine the contents of those rule files
  * Proofread the content. 
    * Grammatical errors
    * Markdown syntax errors
    * Are URLs valid?
    * Are disk filepaths/dirpaths valid? Detect any invalid / outdated paths and repair them
  * Fact checking the content, 
    * FACTS ONLY, no assumptions on anything. 
    * Backed by official documentation and cited links to documentation
    * Is the file content factual? 
* Recommended additions / Changes
  * For each rules file, create a sibling file derived from the basename:
    * `RULES_FILE.md` -> `.RULES_FILE_RECOMMENDATIONS.md`
    * I assume that claude will ignore these files because of the leadin `.`? That's the intent
    * populate the file with recommendations for ways to improve and  make more efficient:
      * Missing topics? Reseearch the topic and recommend anything that's missing but ought to be included
      * file getting too big? Recommend how to split it up
  
* The instrutions about markdown are most important to me immediately
  * I keep notes abotu markdown here: `/Users/zakkhoyt/Documents/notes/markdown/**/*.md`
  

I have added symlinks to all files/dirs referenced in this document:

```zsh
~/.ai/docs/ai/planning/planning_references on  zakk/script_overhaul_ai_files! ⌚ 19:51:26
$ ls -al
total 0
drwxr-xr-x  6 zakkhoyt  staff  192 Apr 27 19:51 .
drwxr-xr-x  4 zakkhoyt  staff  128 Apr 27 19:49 ..
lrwxr-xr-x  1 zakkhoyt  staff   34 Apr 27 19:50 notes-ai -> /Users/zakkhoyt/Documents/notes/ai
lrwxr-xr-x  1 zakkhoyt  staff   40 Apr 27 19:50 notes-markdown -> /Users/zakkhoyt/Documents/notes/markdown
lrwxr-xr-x  1 zakkhoyt  staff   19 Apr 27 19:51 user-ai-repo -> /Users/zakkhoyt/.ai
lrwxr-xr-x  1 zakkhoyt  staff   23 Apr 27 19:51 user-claude -> /Users/zakkhoyt/.claude

```
  


# compiled/binary shell executables
* ~/.zsh_home/bin
* ~/code/repositories/hatch/hatch_sleep/scripts/shell/bin
* ~/.hatch/bin

# scripts dir (subdirs for langauges)





completions
defaults
docs
functions
logs
README.md
restore.sh
scripts
snippets
tokens
utilities
zsh_functions






config
logs
man
preferences
README.md
scripts
source
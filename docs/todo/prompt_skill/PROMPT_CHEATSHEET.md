* [ ] re-read ai instructions. Apply below. 

* [ ] Write a document of type <format>: <cheatsheet, for dummies, overview, deep-dive>
  * [ ] What each of these mean
* [ ] Write up a new document at <path> (basename derived from <format>)

* [ ] References:
  * [ ] Use only official product documentation (man pages, pdf manuals, online documentation, `man` pages, `-h/--help` args)
  * [ ] About `~/Documents/notes/**`
    * If you are writing a new document somwhere under `~/Documents/notes/**`, it's likely because you are filling in a gap in those documents and won't find relevant information in those existing files.  
    * GOOD: Extract URLs to official documentation and similar
    * GOOD: Extract commands for `man` pages, `-h/--help` pages, etc..
    * BAD: Treating files under `~/Documents/notes/**` as a source of truth. These are largely hand written by a human and are likely to contains errors and mistakes
      * Additionaly, if you are being asked to supplement these files, then you will need to find that data elsewhere then import it via new documentatiopn
    * BAD: Modeling new documents after existing documents under `~/Documents/notes/**`. Only use the formatting described in AI instructions and descriptions above

Be sure to document references according to AI instructions


Include at least these sections and topics

* Related commands and aliases (typeset, local, readonly, etc...)
* official documentation (where to find in zsh's man pages, help, etc...). Example commands for each related command
* arguments: Where to look or display a list of arguments? Example commands for each related command
* Where to find help? `typeset -h` doesn't give you help, but it gives you a list of variables of some kind. 


* Overview - explain what type, scope, etc.. are 

* arg categories (declaration)
  * declaring variables (scalar types, int, string, float, etc....). Include examples for each/all arg variants.. Which flags to use for which types, examples 
  * declaring collection variables (array, associative arrays, etc...) Include examples for each/all arg variants.. Which flags to use for which types, examples 
  * declaring reference variables (aka pointers to other variables, or reference by name) Include examples for each/all arg variants. Which flags to use for which types, examples 
  * Specifying variable scope of the declartion: global, exported "default", local to a function, etc... How to change scooing of a var that's already 
  * Augmenting a variaable (marking as readonly, forcing unique hiding values, (how/where hiding works, where it doesn't work, etc...). 

* allocating, initializing, deallocating, resetting, reallocating, etc... Are there cases where this is not possible?

* formatting / augmenting values of variables (lowercase, uppercase, zero fill, hex, decimal, binary, treat as file paths )








* best practices section: IE: always allocate and init together


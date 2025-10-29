
I mispoke previously. Please re-read this. 

I just added some new copilot instructions under `/Users/zakkhoyt/code/repositories/hatch/hatch_sleep/scripts/.github/instructions/*` (aka `A`)
* These mainly consist of `zsh` and `markdown` conventions  . 

However there is a pre-existing file `/Users/zakkhoyt/code/repositories/hatch/hatch_sleep/scripts/.github/copilot-instructions.md` (aka `B`) 
* This file also defines some `zsh` conventions. 

Let's clean this up by moving anything zsh related out of B and either:
* into A 
* delete it. 

First, break the data down into these cases. 
* A and B both have detail on a subject: Prompt me. They might both say the same thing, or they may compliment, etc...
* A mentions a subject, B doesn't: Probably nothing to do here, but Prompt me. 
* B mentions a subject, A doesn't: Prompt me. We will handle these case by case. 

Then we can go through each of the 3 lists together. 

Make sense?
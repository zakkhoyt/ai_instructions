* I was reviewing `scripts/HELP_OUTPUT_PROPOSED.md` and found that there are some issues.
* There are many actions that a `--prompt <action>` can target, not just config/settings. This document seems to only address the new settings selectors/schemes and is missing all of the current actions that this script supports.
* [ ] Let's modify all of the "settings" related actions (the ones that are currently documented) to reflect that they are related to config/settings. I think we should prepend `config-` to the scope token of each:
    * EX: `--prompt user:settings` -> `--prompt config-user:settings`
    * EX: `--prompt workspace:settings` -> `--prompt config-workspace:settings`
    * this will still allows for the selector scheme, but groups these together as "config" actions
* [ ] Update `scripts/HELP_OUTPUT_PROPOSED.md` and `scripts/CONFIGURE_AI_INSTRUCTIONS_OVERHAUL.md` to support all of the missing actions. I'm not 100% on the syntax but:
    * EX: `--prompt instructions`
    * etc... We need to document and support all of the existing functionality under this new argument scheme
* [ ] Update `scripts/HELP_OUTPUT_PROPOSED.md` and `scripts/CONFIGURE_AI_INSTRUCTIONS_OVERHAUL.md` to reflect everthing above
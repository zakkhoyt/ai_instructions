OVERVIEW

  echo_pretty can be considered an extension of `echo` with support for `ANSI` codes via command line arguments. Makes it easy to decorate terminal output without having to remember or look up ANSI codes.

USAGE

  echo_pretty [echo flags] [options] text [options] [meta flags]

OPTIONS (ECHO)

  Support for echo arguments in zsh. To learn more: man zshbuiltins

  -n                                                Do not print the trailing newline character. (echo argument)
  -E                                                Disable escape character sequences. In other words treat them as string literals.

OPTIONS

  Insert ANSI codes using the following.

  Resetting back to default

  --default                                         Reset everything to default values. This includes foreground, background, font, etc...
  -d | --d | --defaultForeground                    Reset the foreground color to its default value
  -D | --D | --defaultBackground                    Reset the foreground color to its default value

    EXAMPLES

    $ echo_pretty  --bold "bold font" --default " default font"
    $ echo_pretty  --GREEN --red "GREEN background & red foreground" --defaultBackground "default background & red foreground" --default


  Font Modifiers that are not color relates

  --bold                                            Bold font 
  --faint                                           Faint font 
  --italic                                          Italic font 
  --underline                                       Underline 
  --double-underline                                Double underline 
  --blink                                           Blink <= 150 Hz 
  --blinkFast                                       Blink > 150 Hz. Rarely supported 
  --invert | --swap                                 Invert font 
  --hide                                            Hide font 
  --strikeout                                       Strikeout 


  -d | --d | --defaultForeground                    Default foreground color
  -black                                            Black foreground color
  -red                                              Red foreground color 
  -green                                            Green foreground color 
  -yellow                                           Yellow foreground color 
  -blue                                             Blue foreground color 
  -magenta                                          Magenta foreground color 
  -cyan                                             Cyan foreground color 
  -white                                            White foreground color 
  --black                                           Bright black foreground color 
  --red                                             Bright red foreground color 
  --green                                           Bright green foreground color 
  --yellow                                          Bright yellow foreground color 
  --blue                                            Bright blue foreground color 
  --magenta                                         Bright magenta foreground color 
  --cyan                                            Bright cyan foreground color 
  --white                                           Bright white foreground color 
  --orange                                          Orange foreground color.
  --8-bit <value>                                   8-bit RGB foreground color
  --rgb <r> <g> <b>, --24-bit <r> <g> <b>           RGB foreground color (24-bit)
  
  -D | --D | --defaultBackground                    Default background color 
  -BLACK                                            Black background color 
  -RED                                              Red background color 
  -GREEN                                            Green background color 
  -YELLOW                                           Yellow background color 
  -BLUE                                             Blue background color 
  -MAGENTA                                          Magenta background color 
  -CYAN                                             Cyan background color 
  -WHITE                                            White background color 
  --BLACK                                           Bright black background color 
  --RED                                             Bright red background color 
  --GREEN                                           Bright green background color 
  --YELLOW                                          Bright yellow background color 
  --BLUE                                            Bright blue background color 
  --MAGENTA                                         Bright magenta background color 
  --CYAN                                            Bright cyan background color 
  --WHITE                                           Bright white background color 
  --ORANGE                                          Orange background color

  # 8 bit color
  --8-BIT <value>                                   8-bit background color  

  # 24 bit color, webcolors, etc...
  --RGB <r> <g> <b>, --24-BIT <r> <g> <b>           RGB background color (24-bit)



  --clearScreen                                     Clear screen
  --eraseLine                                       Erase line
  --up <count>                                      Move cursor up
  --down <count>                                    Move cursor down
  --right <count>                                   Move cursor right
  --left <count>                                    Move cursor left
  --cursor-hide                                     Hide the cursor
  --cursor-show                                     Show (unhide) the cursor

META OPTIONS

  For help, demos, references, etc...

  --help                                            Print the help/usage message (this message)
  --demo                                            A demonstration comparing echo_pretty syntax vs ANSI codes using echo
  --demo-basics                                     Prints common ANSI escape code (litearls) for use in shell scripts
  --demo-8-bit                                      A demonstration of 8-bit color flags
  --demo-24-bit                                     A demonstration of 24-bit color flags
  --demo-web-colors                                 Prints escape codes for (litearls) for use in shell scripts
  --show                                            Print pre-encoded ANSI strings. This is useful to generate/copy/paste decorated strings and debugging.
  --show-bash                                       Encode ANSI string for bash, write to stdout, and copy to pasteboard.
  --show-swift                                      Encode ANSI string for swift, write to stdout, and copy to pasteboard.
  --show-zsh                                        Encode ANSI string for zsh, write to stdout, and copy to pasteboard.
  --version                                         Prints the semantic version of the current build
  --dump                                            Write ProcessInfo arugments and environment to stderr
  --debug                                           Write debug info to stderr & os.logger.
    View stream: log stream --predicate='category == echo_pretty --level=debug --style=compact

ENVIRONMENTAL VARIABLES

  ECHO_PRETTY_NO_TRAILING_DEFAULT_FLAG       If set, the --default argument will be postfixed automatically

REFERENCES

  * American National Standards Institute: https://en.wikipedia.org/wiki/ANSI_(disambiguation)
  * 3-bit_and_4-bit color codes: https://en.wikipedia.org/wiki/ANSI_escape_code#3-bit_and_4-bit
  * 8-bit color codes: https://en.wikipedia.org/wiki/ANSI_escape_code#8-bit
  * 24-bit (RGB) color codes: https://en.wikipedia.org/wiki/ANSI_escape_code#24-bit
  * Article: https://tldp.org/HOWTO/Bash-Prompt-HOWTO/x361.html
  * Video Terminal Programmer Info: https://vt100.net/docs/vt510-rm/DECSCUSR





# TODO in echo_pretty --help

* [ ] Refine overview:
  * `echo_pretty` can be considered an extension of `echo` with support for `ANSI` codes via command line arguments. Makes it easy to decorate terminal output without having to remember or look up ANSI codes.
* [ ] Examples. Add several examples




# Configuration persistance

The idea here is to introduce the concept of capturing the current configuration, persisting it, recalling it, then re-applying it. 
Think: a stack, pushing, popping, and persistance of the values. `git stash` comes to mind as well. 


## ANSI Configuration
This is how echo_pretty currently works:
* iterates through the command line arguments categorizing them into differnt lists. the ones we are interested in are 
  * "ansi args": those that will be converted to ANSI codes and 
  * "string args": the strings which those ANSI codes will decorate. 
  * "meta args": Things like `--debug`, `--help`, `--demo` (not relevant to this convo)
* maps "ansi args" to `[ANSI]` (or is it `[ANSI.Item]`? Double check)
* maps `[ANSI.Item]` to the final ANSI escape code text (EX: red foreground is `\x1B[31m`)
* Sequences the final ANSI escape codes and the "string args" together to form the output string. 
* Writes the output string to `stdout`. 

**example**
```zsh
$ echo_pretty -red --GREEN "xmas time" --default "... Jan Feb March April May June " -BLUE -red "July" -white " 4th" --default " is next" --debug
# # generates this string:
# "\x1B[31m\x1B[102mxmas time\x1B[0m... Jan Feb March April May June \x1B[44m\x1B[31mJuly\x1B[37m 4th\x1B[0m"
```

These args are kept then converted to ANSI codes
* `-red`: `\x1B[31m`
* `--GREEN`: `\x1B[102m`
* `--default`: `\x1B[0m`
* `-BLUE`: `\x1B[44m`
* `-red`: `\x1B[31m`
* `-white`: `\x1B[37m`
* `--default`: `\x1B[0m`

These args don't have any impact on the ANSI codes
* `"xmas time"` 
* `"... Jan Feb March April May June "` 
* `"July"` 
* `" 4th"` 
* `" is next"` 
* `--debug`


### What's missing?

As you can see, there is no concept of a "current state" that can be saved and recalled. The closest we have is the output string, but that contains noise (text)

### Solution

* [ ] First we will need to make ANSI.Item implement `Codable`
* [ ] In `main.swift`, implement a new struct to serve as a configuration state
```swift
struct ANSIConfiguration: Codable {
  var ansiItems: [ANSI.Item]
}
```
* allocate a new script var: `var currentConfiguration = ANSIConfiguration()` which will populated as we process the command line arguments
* allocate a new script var: `var configurationStack = [ANSIConfiguration]()
* in `main.swift` as the "ansi args" are mapped to `ANSI.Item`, append them to `currentConfiguration`
* We now have something that can represent the current configuration, but no way to use it (yet)
  

## --push, --pop, and ECHO_PRETTY_STACK (environmental variable)

Since echo_pretty's runtime is ephemeral, we will need to store `configurationStack` somewhere besides stack/heap. 
The most performant would be an environmental variable. Let's use `ECHO_PRETTY_STACK` for this. 

### `ECHO_PRETTY_STACK` will either be empty or will contain the value of `configurationStack`, expressed as (currently undecided)
* a json representation of `[ANSIConfiguration].self`
* a base64 encoded json representation of `[ANSIConfiguration].self`
* some other convention (basic authentication style? csv style? )
At first let's go with the former

### Push
* add a a new cli argument `--push` which will:* add a a new cli argument `--push` which will:
* push `currentConfiguration` (as is) onto `configurationStack`
    * which will write it's encoded version into env var `ECHO_PRETTY_STACK`
        * we may need to use SwiftyShell for this. I think processInfo.environment is read-only.
* apply `--default` in place of `--pop` (which that engine doesn't know about or understand)
* continue processing the remaininig CLI args (which might contain more --push or --pop)

* add a a new cli argument `--push` which will:* add a a new cli argument `--push` which will:
    * push `currentConfiguration` (as is) onto `configurationStack`
        * which will write it's encoded version into env var `ECHO_PRETTY_STACK`
            * we may need to use SwiftyShell for this. I think processInfo.environment is read-only.
    * apply `--default` in place of `--pop` (which that engine doesn't know about or understand)
    * continue processing the remaininig CLI args (which might contain more --push or --pop)

* EX: echo_pretty --red --GREEN "xmas time" --push
* [ ] TODO: how will this work?

## Pop
* add a a new cli argument `--pop` which will pop `configurationStack` onto `currentConfiguration`
* [ ] TODO: how will this work?
* at `echo_pretty` startup, read env var `ECHO_PRETTY_STACK`. If populated, it will be a base64 representation of an encoded `ANSIConfiguration`.
* Convert the base64 String -> Data, then decode Data as `ANSIConfiguration.Self`. push onto `configurationStack` (see below)
* at `echo_pretty` startup, allocate a stack/array ('var configurationStack: [ANSIConfiguration]') of max size `ECHO_PRETTY_STACK_DEPTH` (or default value of `3`). initialize with value from previous step || `[]`.

* at `echo_pretty` startup.
* `encode`: at the end of execution, quick serialize (json? base64?, etc..)
* `push`: write current ansiConfig to
*
* --push: write current options to stderr in a json format
* --pop


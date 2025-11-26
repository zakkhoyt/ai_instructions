



# thesaurus / dictionary idea. Get AI to help
A js (node?) based script that takes looks up definitions, synonyms, antinyms, etc... by scraping HTML from several webites, refine the date, then write to stdout

## ARGS

```zsh
# SYNOPSIS
$0 [--mode <mode>] <term> [term ...]
```

```zsh
zparseopts -D -E -- \
    {-transform,-mode}:=opt_mode

    opt_mode="${opt_mode[-1]}"
```



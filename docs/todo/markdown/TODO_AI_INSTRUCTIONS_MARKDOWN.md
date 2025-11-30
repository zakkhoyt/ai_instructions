
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
```zsh
# if >= 2 path components 
"[${domain_title}: ${paths_components[1]} - ${paths_components[2]}]($url)"

# if only 1 path component
"[${domain_title}: ${paths_components[1]}]($url)"

# if 0 path components
"[${domain_title}]($url)"


```
* clean_domain_name: 
  * To lean up domain names we will just use the domain name mostly as is
    * Drop the leading `www.`
    * EX: `https://www.amazon.com/Atlantic-Salmon-Portion-Center-Cut/dp/B09Y5W11J1?sr=8-1`
      * `amazon.com` 
    * EX: `https://github.com/hatch-baby/mobile`
      * `github.com` 
    * EX: `https://docs.github.com/en/rest/guides/scripting-with-the-rest-api-and-javascript`
      * `docs.github.com`
      * `GitHub Docs`
    * EX: `https://docs.google.com/accounts/SetOSID?authuser=0&continue=https://docs.google.com/document/d/1O2y-zlIm5kCagM_PhlvJizF3Puj-mvJruM0P964UirQ/edit?tab%253Dt.bxh44nhlto8v%2526pli%253D1%2526authuser%253D0%26osidt%3DALWU2ctmBV_szULAjQy0WbjdLT6nKLUpDXviJvTHBTw0KIECHhYNZdhuOSSxmgd6Ev_WLZSV2IeStkdg4E0zg8nbydQbIup-uPQhNf7HJJqsf_7VVOql_0v4XiWuTeV5opa77htweLIJ6fpmldVYqlfet46lx7fQD3HezBqZO0TAPfJvEhlQKV2aifkb4YGIjH3Unys-BkY5Q4nkjnUWkpKNmJDsRnNJ81XdHriQNwglTrF-gyjCZ6cvEAocmg2d82uz9r6xsKkgBBHr_hlQ9LE_9l6VHQTrLQTKsTbpx6UgbKLWODxwyFaQhGr0wjOQFqomTAaEf9v5aOyq8-3KrITGklFiER-LOWuE7HvBH4o0_ZrI0-h96qpVksz98RIh1qNi2BIoHtMLsQlvYteUCBKIQxJc62i-TaUHQNGJBzVzUoC7AR-t9HOsgjHG19mv9Uhjr3_wRSChAazAjJW8OJ41Hp37OH8uB6FQ6UtHh7w5-HNGZ6H-QJ8%26ifkv%3DAfYwgwXpIuzdAU1qB68nwF_EEMSYrGL_8ursxfoF7uD6v-1z_BT14aaH6YQlefPBigZ5YTBEU4nG%26pli%3D1%26authuser%3D0&osidt=ALWU2cuw03WUaS2_1PrC5qROhR1J1_eTqmC-R2au5ii3leWN_DqbViAGEUMv4vr3U8-EE09X2db8VTPxlQASbwnntMEvctrOF4lvUSUyEIeCChMwpBlEC4kgitPgAymwk-4f34N2BK95FfLLKWLz0p9yTSHeagbe6vZ-9r26WGPXtf-d2zHmtn0LY9nlHnb3uvl4Af6YZYk9vAl6OqELFsR9vXjLOgxrNra07O6bR8zmNfILgSkPZkTyCuLVopm55zyL1TWpuH0-sG7Vok4rwPk6UK6Eq3p3W-eTEf5IwqOhr5PAGBfI84ldk-H08goyS71qAAjh68PLbKgW-VLHh-7TuArwZgSp2wr6qiK-azX9Q3YK13DY84TXnohB-L9U92EMi3c5hUQo8HYS4Fxl_2UP1Zn7PiN1YeG6iKMb55l9SDH8dRxrjVZteHAeV7DVQEMlLcBCR1i27NQWKV3e-ZVpy8VLkrC9FOM5rP_2zsyH1AhGyLL_oSA&ifkv=ARESoU1hl4tozVMRHKWIUytEJmFydqlKM18Ze9NpqgXpjqrP4keAsNHaclOOluLQzpukMdV07H3qSw#heading=h.8y0fmktk8a0w` 
      * `docs.google.com`
      * `Google Docs` 
    * EX: `https://console.cloud.google.com/`
      * `console.cloud.google.com`
      * `Google: Cloud Console`
        


## `domain_name` to `domain_title`
```swift


/// Converts domain names into human readable:
/// * `docs.google.com` -> `Google Docs`
/// * `docs.github.com` -> `GitHub Docs` 
/// * `console.cloud.google.com` -> `Google Console Cloud`
/// * `docs.google.com` -> `Google: Docs`
/// * `docs.github.com` -> `GitHub: Docs` 
/// * `console.cloud.google.com` -> `Google: Console Cloud`
func domainTitle(
  domainName: String) -> String {
  //let components: [String] = domainName.replacing("www.", "").split(`.`).map { titleCase($0) }.join(" ")
  let components: [String] = domainName
    .split(`.`)
    .filter { "www" } 
    .map { titleCase($0) }

    let divisor = ": "
    let divisor = ""
    switch components.count {
      case ...0: return ""
      case 1: "\(components[components.count - 1])"
      case 2...: "\(components[components.count - 1])\(divisor))\(components[0..<components.count - 2].joined(separator: " "))"
    }        
}

extension [String] {
  var domainTitle: String {
    if isEmpty { return "" }
    
    switch count {
      case 0: return ""
      case 1: "\(self[count-1])"
      case 2: "\(self[count-1]): \(self[1..<count-2].joined(separator: " "))"
    }
    
  }
}

```
        * `[last]: {1, 2, 3 ...}` As Title Case
  <!-- * For other domain names (a specified list) we will use a particular "domain_name_format"
    * Split by `.` then discard the last one (the .com, .net, etc...)
    * If in this look up table, use it
      * `github.com` -> `GitHub` -->

* domain_title: 
    * EX: `https://github.com/hatch-baby/mobile` -> `GitHub` 
  * EX: `https://github.com/hatch-baby/mobile` -> `GitHub`
* topic: A human readable description about the webpage
  * This can be synthesized from 1 or 2 of the first path components of the URL (depending on how many there are and what domain)
    * Ignore 3rd, 4th, et... path components.
    * Ignore query items
    * EX: `https://github.com/hatch-baby/mobile` -> `HatchBaby - mobile`
    * EX: `https://github.com/hatch-baby/mobile/tree/main/.claude` -> `HatchBaby - mobile`
  * This can also be grabbed from the webpage it self (page title), thought this would require fetching that HTML then parsing it. 

## Examples (github.com)

* `https://github.com/settings/profile` => [GitHub: Settings - Profile](https://github.com/settings/profile)
* `https://github.com/settings/tokens` => [GitHub: Settings - Tokens](https://github.com/settings/tokens)
* `https://github.com/hatch-baby/mobile` -> `[GitHub: HatchBaby - mobile](https://github.com/hatch-baby/mobile)`
* `https://github.com/hatch-baby/mobile/tree/main/.claude` -> `[GitHub: HatchBaby - mobile](https://github.com/hatch-baby/mobile)`



* `https://docs.github.com/en/rest?apiVersion=2022-11-28` => [GitHub: RESTful API](https://docs.github.com/en/rest?apiVersion=2022-11-28)
* `https://docs.github.com/en/rest/authentication/keeping-your-api-credentials-secure` => [GitHub: Keeping your API credentials secureFollow these best practices to keep your API credentials and tokens secure.](https://docs.github.com/en/rest/authentication/keeping-your-api-credentials-secure)
* `https://docs.github.com/en/rest/guides/scripting-with-the-rest-api-and-javascript` => [GitHub: Scripting with the REST API and JavaScriptWrite a script using the Octokit.js SDK to interact with the REST API.](https://docs.github.com/en/rest/guides/scripting-with-the-rest-api-and-javascript)

* `https://cli.github.com/).` => [GitHub: GH CLI](https://cli.github.com/). 
* `https://cli.github.com/manual/gh_api` => [GitHub: GH CLI Manual](https://cli.github.com/manual/gh_api)






<!-- 
# Table Formatting

```md
| Syntax          | Type            | Example      | Purpose                          |
| --------------- | --------------- | ------------ | -------------------------------- |
| `${(flags)var}` | Parameter flags | `${(qq)arr}` | Control expansion behavior       |
| `${var[sub]}`   | Subscript       | `${arr[1]}`  | Array indexing (square brackets) |
| `${var:mod}`    | Modifier        | `${path:t}`  | Path/string modification (colon) |
| `*(qual)`       | Glob qualifier  | `*(/)`       | Filter files in globbing         |
| `${var(???)}`   | ❌ INVALID       | -            | Not valid syntax                 |
``` 



* [X] ~~Add rectangular table example to markdown instructions~~ (2025-11-30)




-->


# References

Any time a markdown link is added to a document it must 

# Table of contents
## Footnotes
* [GitHub Flavored Markdown: Footnotes](https://docs.github.com/en/get-started/writing-on-github/getting-started-with-writing-and-formatting-on-github/basic-writing-and-formatting-syntax#footnotes)




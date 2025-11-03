# Comments
Add succinct but informative comments throughout. 

## Contents
* Always include reference links to documentation, language specs, APIs, manuals, popular articles, etc... when ever there is an opportunity. 
  * In this case (javascript, html, violentmonkey, css, and firefox)
* Comments for `variables` and `functions` should always include the data type(s) for all expected values, along reference links to those types.
  * EX: A variable is initialized to `nil` at first, but will contain an array of donkeys later
* For `JavaScript` and `HTML`, prefer referencing `mozilla` documentation where available and sufficient. Fall back to other vendor/domains as appropriate. 
  * [html example](https://developer.mozilla.org/en-US/docs/Web/HTML/Reference/Elements/details#creating_an_open_disclosure_box)
  * [javascript example](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array)
* Always include references & short discussion on every and any Violentmonkey API call, interaction, places where violentmonkey rules influence logic decisions. Here are a few
  * [GitHub Pages: Violentmonkey](https://violentmonkey.github.io/)
  * [GitHub Pages: Violentmonkey - User your preferred IDE](https://violentmonkey.github.io/posts/how-to-edit-scripts-with-your-favorite-editor/)
  * [GitHub Pages: Violentmonkey - Metadata Block](https://violentmonkey.github.io/api/metadata-block/)
  * [GitHub: violentmonkey source code](https://github.com/violentmonkey/violentmonkey)
  * [GitHub: ja-ka - violentmonkey scripts](https://github.com/ja-ka/violentmonkey)

## Format
* Format the comments for the perspective of a seasoned developer who is learning the relevant software stack: as tertiary language(s)
  * javascript, html, css, and violentmonkey
* When comments will contain multiple "subjects" arrange them in this preferred order:
  1. idea/concept
  2. data type(s)
  3. references


## Action Items

* [ ] Add a header comment (after shebang, if any)
* [ ] Above root/globally scoped variable in the file / scope
* [ ] Above each function in the file / scope
  * [ ] To key variables and key concepts within the function
* [ ] Anywhere else where additional comments can provide more information than reading the code. 
  * [ ] Tricky Spots: EX: Race conditions
  * [ ] Work-Arounds: works around some problem or limitation
  * [ ] There is a lesson to be learned, etc...






# [ ] String Composition

* Prefer string composition with this sytnax
```js
let name = "bill"
let intro = `hello my name is ${name}`
````

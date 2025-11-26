


#

# Why is there no builtin named `help`?
* Also run-help is just an alias to `man`
* https://www.codestudy.net/blog/how-can-i-read-documentation-about-built-in-zsh-commands/#1-understanding-zsh-built-ins-vs-external-commands


# Learn about zsh modules
# Learn about zsh Autoload
`autoload -Uz run-help`
* args
* when to use it, when it's implied
* debuggging, seeeing what's loaded



# Computed variables?

In `zsh` scripting, is thare a way that my script can watch a variable for changes and react to them? 
## Example in Swift:
```swift
private var _myVar: String = "Value"
var myVar: String { 
  get { _myVar }
  set(newValue) { _myVar = newValue }
}
var myVar2: String = "value2" { 
  willSet(newValue) {
    print("willSet myVar2: \(myVar2) -> \(newValue)")
  }
  didSet(oldValue) {
    print("didSet myVar2: \(oldValue) -> \(myVar2)")
  }
}
```




# oh-my-zsh vs zi
* https://ohmyz.sh/
* https://wiki.zshell.dev/docs/getting_started/installation
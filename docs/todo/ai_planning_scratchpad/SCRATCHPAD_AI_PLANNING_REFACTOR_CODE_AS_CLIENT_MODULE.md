# TODO: Refactoring code as a `Client Module` under HatchModules
* [ ] references:
  * [ ] point to documentation about what a client module is
  * [ ] point to some examples of clients  * [ ] 



## Coordinator
* [ ] `live` implementation is to use backing coordinator (usually going to be a variant of the original legacy code)
  * [ ] Typically the main legacy class/manager will become the main logic in the client. In otherwords, it will become the `Coordinator`.
  * [ ] Rename main legacy class/manager to `___Coordinator`, to follow established convention

* [ ] the main legacy class/manager must be **encapsulated** in the client module. 
  * the coordinator must not have `public` scoping and should instead be scoped as `internal` (no scope == `internal`)


* [ ] publish events over combine
  * [ ] Create associated value enum(s) to represent the events and any data that needs to be passed along
    * Name the enum to include the word `Event`, and use namespacing. EX:
      * `enum ___Client.Event`
      * `enum ___Client.\(SomeCategory)Event`
      * [ ] point to examples
  * See: namespacing (below)
  * Serious error events should terminate the combine stream
  * Non-serious error should not terminate the comnine stream and shoudl be part of the 

* [ ] Minimal Mutability

* [ ] Use namespacing for data structs, models, etc...
  * `enum ___Client.Event`
  * `enum ___Client.Error: LocalizedError`









<!-- 
properties, clients, closures, etc... should be minimally mutable
 -->

* [ ] no singletons

<!-- 
One of the main points of client modules is to replace singletons. You must remove `public static var shared: ArgumentKitClient `. 
* Update the app to retain an instance of `ArgumentKitClient`, a normal instance. Look around for how/where other clients are retained if need be. 
  * Pass that instance into HatchLogger if needed, or other workarounds, but no more singletons 
  -->

## Macros
* [ ] @Dependency
* [ ] #LogAll
* [ ] @NamedClientClosure
<!-- 
* Next, regarding ther rest of  `iOS/hatch-sleep-app/HatchModules/Modules/Clients/ArgumentKitClient/Sources/ArgumentKitClient+Legacy.swift`. There is no need to do this as we have a Swift Macro that does exactly this same thing, `@NamedClientClosure`. 
  * Read the docs: `iOS/hatch-sleep-app/HatchModules/Macros/Client/HatchClientMacros/Sources/HatchClientMacros.docc`
  * Search for `@NamedClientClosure`` under  `iOS/hatch-sleep-app/HatchModules/Modules` for several examples 
 -->

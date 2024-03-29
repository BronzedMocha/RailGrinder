# Changelogs

Any changes that hold a value should be listed here under the Version that they will be released under.

## V0.2
* `Vinum.JustOk` was renamed to `Vinum.AlwaysTrue` for a more descriptive API for begineers
* `Observe:onBind`, which fires the provided function, and then returns a connection disconnector.
* `Vinum.Mirror` object, which is used for directly mirroring Objects' values, as opposed to `Vinum.Match`, which perform a computation instead.
* `Vinum.Reflect` object, which is used directly to mirror a specific object's value. Useful for creating readonly clones of a state object.
* `Vinum.Wrap` object, which is used to derive state objects from a luau-pure signal/RBXScriptSignal.
* A fix for Match, which is to fix an error that can occur when working with self-contained `Vinum.Group` keys.
* `Vinum.Record` object, which is used to store "records" of a specific object's value. 
* `Vinum.Version`  table, which is used to identify the version that this module is built on
* `Vinum.Destroy` function, which enables you to destroy state objects.
## V0.1
Initial Release.
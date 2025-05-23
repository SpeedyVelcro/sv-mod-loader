# Example Mod: 2x Bullet Speed
This mod increases the default speed of bullets to 2x its original value by
changing the value of the exported variable `speed` in `bullet.tscn`. It is a
good example of a mod that changes a file that has dependencies.

The project includes two dependencies - the texture and script - that aren't
actually meant to be modified by the mod (although here they've been replaced
with minimal dummy files) because Godot would otherwise throw an error on
build.

The export preset uses
`Export > YOUR PRESET > Resources > Export Mode > Export selected resources (and dependencies)`,
but also filters out dependencies using
`Export > YOUR PRESET > Resources > Filters to exclude files/folders from project`.
This way, dependencies can be included in the project to avoid errors and make
editing easier, but can be omitted from the exported .pck file to reduce file
size and also improve compatibility with other mods that edit those files. This
approach is a bit finicky, and will ideally be superseded once
[Godot issue #5992](https://github.com/godotengine/godot-proposals/issues/5992)
is resolved.

This approach may result in less conflicts, but it will still conflict with any
mod that modifies `bullet.tscn`.

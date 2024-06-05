extends Tree
## UI Element for oganizing the load order of mods
##
## This UI element displays a list of mods, and allows re-ordering and enabling
## or disabling them.


# Override
func _ready() -> void:
	set_column_expand(0, false) # Checkbox
	set_column_expand(1, true) # File name
	
	# TODO: test code, remove
	for i in 100:
		var item = create_item(null, i)
		item.set_cell_mode(0, TreeItem.CELL_MODE_CHECK)
		item.set_editable(0, true)
		item.set_checked(0, false)
		item.set_text(1, "Mod " + str(i + 1))


# Override
func _can_drop_data(at_position: Vector2, data) -> bool:
	if data is TreeItem:
		set_drop_mode_flags(DROP_MODE_INBETWEEN)
		return true
	
	return false


# Override
func _drop_data(at_position: Vector2, data) -> void:
	if not data is TreeItem:
		return
	
	# Only accept data from this mod list
	if data.get_tree() != self:
		return
	
	var target_item: TreeItem = get_item_at_position(at_position)
	
	if get_drop_section_at_position(at_position) == -1:
		data.move_before(target_item)
	else:
		data.move_after(target_item)


# Override
func _get_drag_data(at_position: Vector2):
	var data: TreeItem = get_item_at_position(at_position)
	set_drag_preview(_create_drag_preview(data))
	
	return data


## Creates and returns a drag preview for the given TreeItem
func _create_drag_preview(tree_item: TreeItem) -> Control:
	var label: Label = Label.new()
	label.text = tree_item.get_text(1)
	label.modulate = Color(1, 1, 1, 0.5)
	
	return label

## Returns the load order as an array
func get_mod_array() -> Array[Mod]:
	var mod_array: Array[Mod] = []
	
	for tree_item in get_root().get_children():
		var mod = _get_mod(tree_item)
		mod_array.append(mod)
	
	return mod_array


## Set an array of mods to be displayed and edited
func set_mod_array(mod_array: Array[Mod]) -> void:
	clear()
	
	for mod in mod_array:
		_add_mod(mod.filename, mod.enabled)

## Adds a mod to the end of the list. Returns the resulting TreeItem
func _add_mod(filename: String = "", enabled: bool = false) -> TreeItem:
	var item = create_item()
	
	item.set_cell_mode(0, TreeItem.CELL_MODE_CHECK)
	item.set_editable(0, true)
	item.set_checked(0, enabled)
	item.set_text(1, filename)
	
	return item

## Gets the mod represented by the specified TreeItem
func _get_mod(tree_item: TreeItem) -> Mod:
	var mod = Mod.new()
	
	mod.filename = tree_item.get_text(1)
	mod.enabled = tree_item.is_checked(0)
		
	return mod

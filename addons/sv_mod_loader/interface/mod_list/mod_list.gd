extends Tree
## UI Element for oganizing a mod list
##
## This UI element displays all the mods in the mod folder using Godot's Tree
## node. The mods can be organised and enabled or disabled to form a load order.
## Functions are provided to support serializing and deserializing the load
## order to a dictionary (i.e. JSON)


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

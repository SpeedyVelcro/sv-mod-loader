extends Tree
## UI Element for editing an array of mods
##
## This UI element displays an array of mods, and allows re-ordering and enabling
## or disabling them. A purely cosmetic list of mod requirements can be
## displayed at the beginning of the list. These mod requirements are
## un-editable and don't have any really useful data associated with them
## (because the consumer of this node should already know that data)

enum Column {CHECK = 0, NAME = 1}


## Returns the load order as an array
func get_mod_array() -> Array[Mod]:
	var mod_array: Array[Mod] = []
	
	for tree_item in get_root().get_children():
		if _is_required(tree_item):
			continue
		
		var mod = _get_mod(tree_item)
		mod_array.append(mod)
	
	return mod_array


## Set an array of mods to be displayed and edited
func set_mod_array(mod_array: Array[Mod]) -> void:
	_clear_mods()
	
	for mod in mod_array:
		_append_mod(mod)


## Sets mod requirements to be displayed - uneditable - at the beginning of the
## list
func set_mod_requirements(mod_requirements: Array[ModRequirement]) -> void:
	_clear_requirements()
	
	for mod_requirement in mod_requirements:
		_append_mod_requirement(mod_requirement)

## Updates the current mod array to match the given mod array. Does not add new
## mods. Disables mods that aren't present in the given mod array. Reorders mods
## to match the given mod array.
func update_mod_array(mod_array: Array[Mod]) -> void:
	for tree_item in get_root().get_children():
		if not _is_required(tree_item):
			tree_item.set_checked(Column.CHECK, false)
	
	var last_requirement = _get_last_mod_requirement()
	var first_index_after_requirements = last_requirement.get_index() + 1 if last_requirement != null else 0
	
	for i in mod_array.size():
		var mod = mod_array[i]
		var tree_item = _find_tree_item(mod.filename)
		
		if tree_item == null:
			continue
		
		if (_is_required(tree_item)):
			continue
		
		tree_item.set_checked(Column.CHECK, mod.enabled)
		_move(tree_item, first_index_after_requirements + i)


# Override
func _init() -> void:
	create_item() # Root


# Override
func _ready() -> void:
	set_column_expand(Column.CHECK, false) # Checkbox
	set_column_expand(Column.NAME, true) # File name


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
	
	# Mod requirements cannot be re-ordered
	if _is_required(data):
		return
	
	var target_item: TreeItem = get_item_at_position(at_position)
	
	if target_item == null:
		return
	
	if get_drop_section_at_position(at_position) == -1:
		data.move_before(target_item)
	else:
		data.move_after(target_item)


# Override
func _get_drag_data(at_position: Vector2):
	var data: TreeItem = get_item_at_position(at_position)
	
	# Mod requirements cannot be re-ordered
	if _is_required(data):
		data = null
	
	if data != null:
		set_drag_preview(_create_drag_preview(data))
	
	return data


## Creates and returns a drag preview for the given TreeItem
func _create_drag_preview(tree_item: TreeItem) -> Control:
	var label: Label = Label.new()
	label.text = tree_item.get_text(1)
	label.modulate = Color(1, 1, 1, 0.5)
	
	return label


## Adds a mod to the end of the list. Returns the resulting TreeItem
func _append_mod(mod: Mod) -> TreeItem:
	var item = create_item(get_root())
	
	item.set_cell_mode(Column.CHECK, TreeItem.CELL_MODE_CHECK)
	item.set_editable(Column.CHECK, true)
	item.set_checked(Column.CHECK, mod.enabled)
	item.set_text(Column.NAME, mod.filename)
	
	return item


## Appends the given mod requirement to the list of requirements at the
## beginning of the array. Returns the resulting TreeItem
func _append_mod_requirement(mod_requirement: ModRequirement) -> TreeItem:
	var item = create_item(get_root())
	
	var last = _get_last_mod_requirement()
	if last != null:
		item.move_after(_get_last_mod_requirement())
	else:
		_move(item, 0)
	
	item.set_cell_mode(Column.CHECK, TreeItem.CELL_MODE_CHECK)
	item.set_editable(Column.CHECK, false)
	item.set_checked(Column.CHECK, true)
	item.set_text(Column.NAME, mod_requirement.display_name)
	
	return item


## Gets the tree item representing the last mod requirement in the mod list.
## Returns null if there are no mod requirements.
func _get_last_mod_requirement() -> TreeItem:
	var tree_items = get_root().get_children()
	var index = tree_items.rfind_custom(_is_required.bind())
	
	if index == -1:
		return null
	
	else:
		return tree_items[index]


## Gets the mod represented by the specified TreeItem
func _get_mod(tree_item: TreeItem) -> Mod:
	if (_is_required(tree_item)):
		push_error("Attempted to get mod from a tree item which was actually a mod requirement: " + tree_item.get_text(Column.NAME))
	
	var mod = Mod.new()
	
	mod.filename = tree_item.get_text(Column.NAME)
	mod.enabled = tree_item.is_checked(Column.CHECK)
		
	return mod


## Finds the TreItem corresponding to the given mod name. Returns null if the
## search fails
func _find_tree_item(mod_name: String) -> TreeItem:
	for tree_item in get_root().get_children():
		if mod_name == tree_item.get_text(Column.NAME):
			return tree_item
	return null


## Moves the given tree item to the given position. Position must be
## positive, and is indexed from 0. If the position is impossibly high, mod is
## placed at the end.
func _move(tree_item: TreeItem, pos: int) -> void:
	if tree_item == null:
		return
	
	var last_index = get_root().get_child_count() - 1
	
	if pos < 0:
		return
	
	if pos >= last_index:
		tree_item.move_after(get_root().get_child(-1))
		return
	
	tree_item.move_before(get_root().get_child(pos + 1))


## Removes all required mods from the tree
func _clear_requirements() -> void:
	for tree_item: TreeItem in get_root().get_children():
		if (_is_required(tree_item)):
			get_root().remove_child(tree_item)


## Removes all non-required mods from the tree
func _clear_mods() -> void:
	for tree_item: TreeItem in get_root().get_children():
		if (not _is_required(tree_item)):
			get_root().remove_child(tree_item)


## True if the given tree item represents a required mod
func _is_required(tree_item: TreeItem):
	return not tree_item.is_editable(Column.CHECK)

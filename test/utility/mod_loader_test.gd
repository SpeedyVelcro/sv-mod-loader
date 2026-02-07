class_name ModLoaderTest
extends GdUnitTestSuite

var temp_mods_dir: String


func before():
	temp_mods_dir = create_temp_dir("mods")


func after_test():
	# Clear mod directory
	var dir := DirAccess.open(temp_mods_dir)
	for filename in dir.get_files():
		dir.remove(filename)


func test_init_creates_mod_dir_if_doesnt_exist(path: String, _test_parameters := [
	[temp_mods_dir + "foo"],
	[temp_mods_dir + "bar"]
]):
	# Precondition
	assert_that(DirAccess.dir_exists_absolute(path)).is_false()
	
	# Arrange / Act
	ModLoader.new(path)
	
	# Assert
	assert_that(DirAccess.dir_exists_absolute(path)).is_true()


func test_get_mod_filenames(files: Array[String], expected: Array[String], _test_parameters := [
	[[], []],
	[["foo.pck"], ["foo.pck"]],
	[["foo.PCK"], ["foo.PCK"]],
	[["foo.pck", "bar.pck", "baz.pck"], ["foo.pck", "bar.pck", "baz.pck"]],
	[["foo.txt"], []],
	[["foo.pck", "bar.txt", "baz.pck", "foobar.txt"], ["foo.pck", "baz.pck"]]
]):
	# Arrange
	var target := ModLoader.new(temp_mods_dir)
	_create_files(files)
	
	# Act
	var result := target.get_mod_filenames()
	
	# Assert
	assert_array(result).callv("contains_exactly_in_any_order", expected) # callv workaround because I can't spread the expected array for some reason


func test_get_mods(files: Array[String], expected: Array[String], _test_parameters := [
	[[], []],
	[["foo.pck"], ["foo.pck"]],
	[["foo.PCK"], ["foo.PCK"]],
	[["foo.pck", "bar.pck", "baz.pck"], ["foo.pck", "bar.pck", "baz.pck"]],
	[["foo.txt"], []],
	[["foo.pck", "bar.txt", "baz.pck", "foobar.txt"], ["foo.pck", "baz.pck"]]
]):
	# Arrange
	var target := ModLoader.new(temp_mods_dir)
	_create_files(files)
	
	# Act
	var result := target.get_mods()
	
	# Assert
	assert_array(result.map(func (mod: Mod): return mod.filename)).callv("contains_exactly_in_any_order", expected) # callv workaround because I can't spread the expected array for some reason
	assert_bool(result.all(func (mod: Mod): return not mod.enabled)).is_true()


func test_get_mods_enabled(files: Array[String], expected: Array[String], _test_parameters := [
	[[], []],
	[["foo.pck"], ["foo.pck"]],
	[["foo.PCK"], ["foo.PCK"]],
	[["foo.pck", "bar.pck", "baz.pck"], ["foo.pck", "bar.pck", "baz.pck"]],
	[["foo.txt"], []],
	[["foo.pck", "bar.txt", "baz.pck", "foobar.txt"], ["foo.pck", "baz.pck"]]
]):
	# Arrange
	var target := ModLoader.new(temp_mods_dir)
	_create_files(files)
	
	# Act
	var result := target.get_mods(true)
	
	# Assert
	assert_array(result.map(func (mod: Mod): return mod.filename)).callv("contains_exactly_in_any_order", expected) # callv workaround because I can't spread the expected array for some reason
	assert_bool(result.all(func (mod: Mod): return mod.enabled)).is_true()


func test_load_nothing():
	# Arrange
	var mocked_load_wrapper: LoadResourcePackWrapper = mock(LoadResourcePackWrapper)
	var target := ModLoader.new(temp_mods_dir, ModLoaderUserSettings.new(), mocked_load_wrapper)
	
	# Act
	var result := target.load_all([], [])
	
	# Assert
	verify_no_interactions(mocked_load_wrapper)
	assert_array(result).is_empty()


func test_load_mod(filename: String, _test_parameters := [
	["foo.pck"],
	["bar.pck"]
]):
	# Arrange
	var mocked_load_wrapper: LoadResourcePackWrapper = mock(LoadResourcePackWrapper)
	do_return(true).on(mocked_load_wrapper).load_resource_pack(any_string())
	var target := ModLoader.new(temp_mods_dir, ModLoaderUserSettings.new(), mocked_load_wrapper)
	
	var mod := Mod.new()
	mod.filename = filename
	
	_create_file(filename)
	
	# Act
	var result := target.load_mod(mod, false)
	
	# Assert
	verify(mocked_load_wrapper).load_resource_pack(temp_mods_dir + "/" + filename)
	verify_no_more_interactions(mocked_load_wrapper)
	
	assert_str(result.display_name).is_equal(filename)
	assert_str(result.absolute_path).is_equal(ProjectSettings.globalize_path(temp_mods_dir + "/" + filename))
	assert_int(result.status).is_equal(ModLoadResult.Status.SUCCESS)


func test_load_mod_calls_hook():
	# Arrange
	var target := ModLoader.new(temp_mods_dir)
	
	var mod := Mod.new()
	mod.filename = "test1.pck"
	_create_test_hook_mods()
	
	var previous_called_times = TestHookTracker.hook_1_calls
	
	# Act
	target.load_mod(mod, false)
	
	# Assert
	assert_int(TestHookTracker.hook_1_calls - previous_called_times).is_equal(1)


func test_load_mod_requirement(display_name: String, filename: String, _test_parameters := [
	["Foo Mod", "foo.pck"],
	["Bar Mod", "bar.pck"]
]):
	# Arrange
	var mocked_load_wrapper: LoadResourcePackWrapper = mock(LoadResourcePackWrapper)
	do_return(true).on(mocked_load_wrapper).load_resource_pack(any_string())
	var target := ModLoader.new(temp_mods_dir, ModLoaderUserSettings.new(), mocked_load_wrapper)
	
	var requirement := ModRequirement.new()
	requirement.display_name = display_name
	requirement.path = temp_mods_dir + "/" + filename
	
	_create_file(filename)
	
	# Act
	var result := target.load_requirement(requirement, false)
	
	# Assert
	verify(mocked_load_wrapper).load_resource_pack(temp_mods_dir + "/" + filename)
	verify_no_more_interactions(mocked_load_wrapper)
	
	assert_str(result.display_name).is_equal(display_name)
	assert_str(result.absolute_path).is_equal(ProjectSettings.globalize_path(temp_mods_dir + "/" + filename))
	assert_int(result.status).is_equal(ModLoadResult.Status.SUCCESS)


func test_load_mod_requirement_calls_hook():
	# Arrange
	var target := ModLoader.new(temp_mods_dir)
	
	var requirement := ModRequirement.new()
	requirement.path = temp_mods_dir + "/test1.pck"
	_create_test_hook_mods()
	
	var previous_called_times = TestHookTracker.hook_1_calls
	
	# Act
	target.load_requirement(requirement, false)
	
	# Assert
	assert_int(TestHookTracker.hook_1_calls - previous_called_times).is_equal(1)


# This test basically confirms only the hook for the most recently loaded mod is called each time
func test_calls_multiple_hooks():
	# Arrange
	var settings = ModLoaderUserSettings.new()
	settings.hide_untrusted_warning = true
	var target := ModLoader.new(temp_mods_dir, settings)
	
	var previous_called_times_1 := TestHookTracker.hook_1_calls
	var previous_called_times_2 := TestHookTracker.hook_2_calls
	var previous_called_times_3 := TestHookTracker.hook_3_calls
	
	_create_test_hook_mods()
	
	var requirements: Array[ModRequirement] = [ModRequirement.new()]
	requirements[0].path = temp_mods_dir + "/test1.pck"
	
	var mods: Array[Mod] = [Mod.new(), Mod.new()]
	mods[0].filename = "test2.pck"
	mods[1].filename = "test3.pck"
	
	# Act
	target.load_all(mods, requirements, false)
	
	# Assert
	assert_int(TestHookTracker.hook_1_calls - previous_called_times_1).is_equal(1)
	assert_int(TestHookTracker.hook_2_calls - previous_called_times_2).is_equal(1)
	assert_int(TestHookTracker.hook_3_calls - previous_called_times_3).is_equal(1)


func test_does_not_double_call_hooks():
	# Arrange
	var settings = ModLoaderUserSettings.new()
	settings.hide_untrusted_warning = true
	var target := ModLoader.new(temp_mods_dir, settings)
	
	var previous_called_times_1 := TestHookTracker.hook_1_calls
	var previous_called_times_2 := TestHookTracker.hook_2_calls
	
	_create_test_hook_mods()
	var packer := PCKPacker.new()
	packer.pck_start(temp_mods_dir + "/test_no_hook.pck")
	packer.flush()
	packer = PCKPacker.new()
	packer.pck_start(temp_mods_dir + "/test_another_no_hook.pck")
	packer.flush()
	
	var requirements: Array[ModRequirement] = [ModRequirement.new(), ModRequirement.new()]
	requirements[0].path = temp_mods_dir + "/test1.pck"
	requirements[1].path = temp_mods_dir + "/test_no_hook.pck"
	
	var mods: Array[Mod] = [Mod.new(), Mod.new()]
	mods[0].filename = "test2.pck"
	mods[1].filename = "test_another_no_hook.pck"
	
	# Act
	target.load_all(mods, requirements, false)
	
	# Assert
	assert_int(TestHookTracker.hook_1_calls - previous_called_times_1).is_equal(1)
	assert_int(TestHookTracker.hook_2_calls - previous_called_times_2).is_equal(1)


func _create_file(file: String):
	_create_files([file])


## Creates test1.pck, test2.pck, and test3.pck with mod hooks that increment the TestHookTracker
func _create_test_hook_mods():
	for i in 3:
		var packer = PCKPacker.new()
		packer.pck_start(temp_mods_dir + "/test%d.pck" % (i + 1))
		packer.add_file("res://mod_hook.gd", "res://test/utility/data/test_hook_%d.gd" % (i + 1))
		packer.flush()
		


func _create_files(files: Array[String]):
	for filename in files:
		var file := FileAccess.open(temp_mods_dir + "/" + filename, FileAccess.WRITE)
		file.store_string("nonsense")
		file.close()

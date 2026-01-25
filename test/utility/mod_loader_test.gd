extends GdUnitTestSuite

var temp_mods_dir: String

func before_test():
	temp_mods_dir = create_temp_dir("mods")

func after_test():
	clean_temp_dir()

func test_get_mod_filenames(files: Array[String], expected: Array[String], _test_parameters := [
	[[], []],
	[["foo.pck"], ["foo.pck"]],
	[["foo.PCK"], ["foo.PCK"]],
	[["foo.pck", "bar.pck", "baz.pck"], ["foo.pck", "bar.pck", "baz.pck"]],
	[["foo.txt"], []],
	[["foo.pck", "bar.txt", "baz.pck", "foobar.txt"], ["foo.pck", "baz.pck"]]
]):
	# Arrange
	var target = ModLoader.new(temp_mods_dir)
	
	for filename in files:
		var file = FileAccess.open(temp_mods_dir + "/" + filename, FileAccess.WRITE)
		file.store_string("nonsense")
		file.close()
	
	# Act
	var result = target.get_mod_filenames()
	
	# Assert
	assert_array(result).callv("contains_exactly_in_any_order", expected) # callv workaround because I can't spread the expected array for some reason

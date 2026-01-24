extends GdUnitTestSuite


func test_filename_to_path(dir: String, filename: String, expected: String, _test_parameters := [
	["abc", "def", "abc/def"],
	["abc/", "def", "abc/def"],
	["res://", "foo", "res://foo"]
]):
	# Act
	var result = PathHelper.filename_to_path(filename, dir)
	
	# Assert
	assert_str(result).is_equal(expected)

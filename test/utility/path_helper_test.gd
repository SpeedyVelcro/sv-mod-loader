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


func test_file_path_to_containing_dir(path: String, expected: String, _test_parameters := [
	["abc/def", "abc"],
	["foo/bar/baz", "foo/bar"],
	["res://foo", "res://"]
]):
	# Act
	var result = PathHelper.file_path_to_containing_dir(path)
	
	# Assert
	assert_str(result).is_equal(expected)


func test_file_path_to_filename(path: String, expected: String, _test_parameters := [
	["abc/def", "def"],
	["foo/bar/baz", "baz"],
	["res://foo", "foo"]
]):
	# Act
	var result = PathHelper.file_path_to_filename(path)
	
	# Assert
	assert_str(result).is_equal(expected)

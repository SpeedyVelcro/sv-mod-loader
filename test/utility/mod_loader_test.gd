extends GdUnitTestSuite

var temp_mods_dir: String


func before():
	temp_mods_dir = create_temp_dir("mods")

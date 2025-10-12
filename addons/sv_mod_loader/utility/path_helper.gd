class_name PathHelper
extends Node
## Helper class for manipulating filepath strings.
##
## This class is quite minimal because most useful filepath manipulation
## functions are already found on the String class.


## Prepends the given directory path to the given file name to form the file's
## path.
static func filename_to_path(filename: String, dir: String) -> String:
	var base_path: String = dir if dir.ends_with("/") else dir + "/"
	
	return base_path + filename

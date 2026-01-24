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


## Given a path to a file, returns the path to that file's containing directory
## (i.e. strips the filename and trailing backslash off the path)
static func file_path_to_containing_dir(path: String) -> String:
	var dir = path.rsplit("/", true, 1)[0]
	
	# Repair base dirs like user:// or res://, which may now be missing a forward-slash.
	if dir.ends_with(":/"):
		dir = dir + "/"
	
	return dir


## Given a path to a file, returns only the filename
static func file_path_to_filename(path: String) -> String:
	return path.rsplit("/", true, 1)[1]

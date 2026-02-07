class_name BulletSpeedModifier
extends Node


func _ready()-> void:
	get_tree().node_added.connect(_on_scene_tree_node_added)


func _on_scene_tree_node_added(node: Node):
	if node.scene_file_path != "res://example/entity/bullet/bullet.tscn":
		return
	
	node.speed = 800

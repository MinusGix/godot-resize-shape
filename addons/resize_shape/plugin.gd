tool
extends EditorPlugin

var plugin

func _enter_tree():
	plugin = preload("res://addons/resize_shape/resize_inspector.gd").new(get_undo_redo())
	add_inspector_plugin(plugin)


func _exit_tree():
	remove_inspector_plugin(plugin)

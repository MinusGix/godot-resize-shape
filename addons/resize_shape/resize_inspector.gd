extends EditorInspectorPlugin

var undo_redo: UndoRedo

func _init(undo_redo_: UndoRedo):
	undo_redo = undo_redo_

func can_handle(object):
	# TODO: We could check if the object is the right type
	# so then we can use parse_end to add the control *after*
	# but, we have separate version for each object
	# and parse_end doesn't know what object it is?
	# Also, parse_end needs to hand the object over to the control..
	# I mean, we could store it in a variable, but that seems hacky
	# unless this is instantiated per-editor-thing
	return true

func parse_property(object: Object, type: int, path: String, hint: int, hint_text: String, usage: int):
	if object is CollisionShape:
		# TODO: It would be nice to have a better way of doing this automatically
		if path == "shape":
			add_custom_control(CollisionShapeResizer.new(undo_redo))
	# We never replace the property.
	return false

extends EditorProperty

class_name CollisionShapeResizer

var resize_control_hbc: = HBoxContainer.new();

# We sadly can't use the much nicer EditorSpinSlider for this
# because it doesn't expose the ability to hide the slider
# and/or we can't use the existing EditorTransform3D
# This is annoying for consistency + usability
# I thought of using SpinBox, but I believe it also has the arrows (annoying)
# and, at the very least, it is almost useless since it doesn't provide any
# utility functions for extracting the value.
var resize_control_x: = LineEdit.new();
var resize_control_y: = LineEdit.new();
var resize_control_z: = LineEdit.new();

var resize_control_button: = Button.new()

# Used to guard against activation while we're updating
var updating: = false;

# Needed so that we can register our actions so that they're undoable
var undo_redo: UndoRedo

func _init(undo_redo_: UndoRedo):
	undo_redo = undo_redo_
	
	# Initialize values
	label = "Resize"
	
	resize_control_x.set_text("1")
	resize_control_y.set_text("1")
	resize_control_z.set_text("1")
	
	resize_control_button.set_text("->")
	
	# Add listeners
	resize_control_button.connect("pressed", self, "_on_button_pressed")
	
	# TODO: Tooltip
	resize_control_hbc.add_child(resize_control_x)
	resize_control_hbc.add_child(resize_control_y)
	resize_control_hbc.add_child(resize_control_z)
	resize_control_hbc.add_child(resize_control_button)

	add_child(resize_control_hbc)

func get_tooltip_text() -> String:
	return "Allows you to resize the shape. This actually modifies the shape itself, and so is not the same as scaling it."

func _on_button_pressed():
	# Guard against issues where the button is pressed twice
	if updating:
		return

	updating = true
	
	var is_bad: bool = false
	
	if !resize_control_x.text.is_valid_float():
		print("Bad x-resize")
		is_bad = true
	if !resize_control_y.text.is_valid_float():
		print("Bad y-resize")
		is_bad = true
	if !resize_control_z.text.is_valid_float():
		print("Bad z-resize")
		is_bad = true
	
	if is_bad:
		updating = false
		return
	
	var x_res: float = resize_control_x.text.to_float()
	var y_res: float = resize_control_y.text.to_float()
	var z_res: float = resize_control_z.text.to_float()
	var res: = Vector3(x_res, y_res, z_res)
	
	if x_res <= 0:
		print("non-positive x-resize")
		is_bad = true
	if y_res <= 0:
		print("non-positive y-resize")
		is_bad = true
	if z_res <= 0:
		print("non-positive z-resize")
		is_bad = true
	
	if is_bad:
		updating = false
		return
		
	var cshape: = get_edited_object() as CollisionShape
	var shape: = cshape.get_shape()
	
	undo_redo.create_action("Resize shape")
	undo_redo.add_do_method(self, "_perform_resize", shape, res)
	undo_redo.add_undo_method(self, "_unperform_resize", shape, res)
	# TODO: If we could duplicate Shape, we might be able to use add_do_property here
	undo_redo.commit_action()
	
	updating = false

func _perform_resize(shape: Shape, res: Vector3):
	_resize_shape(shape, res)
	resize_control_x.set_text("1")
	resize_control_y.set_text("1")
	resize_control_z.set_text("1")

func _resize_shape(shape: Shape, res: Vector3):
	# I wish Godot had something like
	# if var thing is Type:
	# that autoset the variable inside the if and ran it if it was the given type..
	if shape is BoxShape:
		var box: = shape as BoxShape
		box.extents.x *= res.x
		box.extents.y *= res.y
		box.extents.z *= res.z
	elif shape is ConcavePolygonShape:
		var conc_poly: = shape as ConcavePolygonShape
		var faces: = conc_poly.get_faces()
		# TODO
		print("ConcavePolygonShape is not yet supported")
	elif shape is ConvexPolygonShape:
		var conv_poly: = shape as ConvexPolygonShape
		var points: = conv_poly.get_points()
		var size: = points.size()
		# Resize all the points
		# Sadly, I can't make Godot know that this is safe
		# Since it isn't smart enough to know that the size is fine
		# even if we move the size call into the range
		# As well, we can't just iter, since we're trying to modify
		# and vectors copy
		for i in range(size):
			var point: = points[i]
			point.x *= res.x
			point.y *= res.y
			point.z *= res.z
			points[i] = point
		# It is passed by value
		conv_poly.set_points(points)
	else:
		print("That shape is not currently supported. Sorry")
	
	# TODO: All of the below could be resolved / improved by making the resize
	# dependent on the shape that is currently active
	# That would require listening for changes in it so that it can be updated
	# As well, some of them might benefit from the ability to convert them to a
	# Concave/Convex polygon shape so then they can be resized as 'expected'
	
	# TODO: We might be able to support height maps?
	# TODO: Planes should be able to be supported but probably require some special handling
	# for their representation
	# TODO: Cylinder/Capsules have the issue of being uncertain of what to do with them
	# TODO: SphereShapes as well

func _unperform_resize(shape: Shape, res: Vector3):
	# The issue we have is that there is no easy way to duplicate
	# a shape. As far as I can tell, we'd have to special case each common
	# shape kind and clone them like that.
	# Thus, we do a simpler method, but that may be inexact.
	# We simply invert the resizing that we did to increase its size by the same level
	# This also manages to avoid special casing.. since we can simply use our
	# previous resizing method
	# The issue with this is that it may not return the exact values, especially for
	# abnormally large/small floating point values.
	_resize_shape(shape, Vector3(1.0/res.x, 1.0/res.y, 1.0/res.z))
	
	# Reset the resize options back to what they were, so that if they just were a bit off
	# then it is easier to fix
	# (This could be a bit off due to float rounding)
	resize_control_x.set_text(String(res.x))
	resize_control_y.set_text(String(res.y))
	resize_control_z.set_text(String(res.z))

extends Node2D

class_name InteractiveObject

@export var interact_range = 128
@export var player_scene: Node

# Create a custom override in this for child classes
func handle_primary_action(event: InputEvent):
	var player = get_node("/root/Main/Player")
	var distance = position.distance_to(player.position)
	if distance < interact_range:
		print("Unhandled primary action click event for object", distance)
	else:
		print("out of range")

func handle_click_release(event: InputEvent):
	pass

func handle_secondary_action(event: InputEvent):
	print("Unhandled secondary action click event for object")

func _on_static_body_2d_input_event(viewport, event: InputEvent, shape_idx):
	if event.is_action_pressed("action_primary"):
		handle_primary_action(event)
	elif event.is_action_pressed("action_secondary"):
		handle_secondary_action(event)

func _on_static_body_2d_mouse_entered():
	Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)
	$Sprite2D.material.set_shader_parameter("line_thickness", 1)

func _on_static_body_2d_mouse_exited():
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)
	$Sprite2D.material.set_shader_parameter("line_thickness", 0)

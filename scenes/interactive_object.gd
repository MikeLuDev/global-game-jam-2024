extends Node2D

class_name InteractiveObject

enum ItemStorageType {
	PocketInventory,
	Handheld,
}

@export var interact_range = 128
@export var player_scene: Node
@export var item_storage_type: ItemStorageType = ItemStorageType.PocketInventory
@export var item_name: String
@export var collision_disabled: bool = false
@export var texture: Texture2D

var attempts = 0

signal interaction_success
signal interaction_fail(attempts: int)

func _ready():
	$StaticBody2D/CollisionShape2D.disabled = collision_disabled
	if texture != null:
		$Sprite2D.texture = texture;
	$Label.text = item_name

# Create a custom override in this for child classes
func handle_primary_action(event: InputEvent):
	var distance = position.distance_to(Player.position)

	if distance < interact_range:
		interaction_success.emit()
		print("Unhandled primary action click event for object", distance)
		if item_storage_type == ItemStorageType.PocketInventory && item_name:
			Player.give_item(item_name)
			queue_free()
		
		if item_storage_type == ItemStorageType.Handheld:
			Player.give_hand_item(self)
	else:
		attempts += 1
		interaction_fail.emit(attempts)
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

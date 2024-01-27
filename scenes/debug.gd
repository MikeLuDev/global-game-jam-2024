extends CanvasLayer

const format_fps = "FPS: %s"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float):
	handle_visibility()
	$FPS.text = format_fps %[Engine.get_frames_per_second()]
	
func handle_visibility():
	if Input.is_action_just_pressed("debug_toggle"):
		visible = !visible

func _on_interactive_tile_interaction_fail(attempts):
	print("failed attempt", attempts)

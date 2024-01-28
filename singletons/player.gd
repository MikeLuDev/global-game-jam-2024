extends CharacterBody2D

@export var speed = 500
@export var zoom_amount = 0.5

@export var min_zoom = Vector2(1, 1)
@export var max_zoom = Vector2(1.25, 1.25)

var pockets = []
var hands: InteractiveObject

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if hands != null:
		hands.position = position + (Vector2.UP * 32);

func _physics_process(delta):
	handle_camera_zoom()
	handle_movement(delta)
	
func handle_movement(delta):
	var input_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	move_and_collide(input_direction * delta * speed)
	
func handle_camera_zoom():
	var new_zoom: Vector2 = $Camera2D.zoom
	
	if Input.is_action_just_pressed("zoom_in"):
		new_zoom = new_zoom + Vector2(zoom_amount, zoom_amount)
	if Input.is_action_just_pressed("zoom_out"):
		new_zoom = new_zoom - Vector2(zoom_amount, zoom_amount)
		
	$Camera2D.zoom = clamp(new_zoom, min_zoom, max_zoom)
	

func give_item(item: String):
	pockets.push_back(item)
	print(pockets)
	
func give_hand_item(item: InteractiveObject):
	if (hands != null):
		hands.get_node("StaticBody2D/CollisionShape2D").disabled = false;
		hands.position = item.position;
		#hands.visible = true;
		
	#item.visible = false;
	item.get_node("StaticBody2D/CollisionShape2D").disabled = true;
	hands = item;

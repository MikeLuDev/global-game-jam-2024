extends Node2D

var interactive_object = preload("res://scenes/interactive_object.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	if GameManager.game_state != GameManager.GameState.Started:
		GameManager.new_game()
	$King.generate_new_task()
	
	var x = 0;
	var y = 0;
	
	for item_name in GameManager.item_data:
		var instance = interactive_object.instantiate() as InteractiveObject
		
		instance.item_name = item_name
		instance.position = Vector2(x, y)
		instance.item_storage_type = 1
		x += 48
		
		add_child(instance)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

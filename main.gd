extends Node2D

var interactive_object = preload("res://scenes/interactive_object.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	GameManager.connect("start_new_round", handle_new_round)
	if GameManager.game_state != GameManager.GameState.Started:
		GameManager.new_game()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func handle_new_round():
	$King.generate_new_task()
	spawn_items()
	if GameManager.round_count == 1:
		Player.position = Vector2.ZERO
	
func spawn_items():
	var spawn_nodes = $ItemSpawnGroup.get_children()
	var spawn_index = 0
	
	for node in spawn_nodes:
		if !node.name.contains("ItemSpawnPoint"):
			node.queue_free()
	
	var randomized_items = GameManager.item_data.keys()
	randomized_items.shuffle()
	for item_name in randomized_items:
		var instance = interactive_object.instantiate() as InteractiveObject
		
		instance.item_name = item_name
		instance.position = spawn_nodes[spawn_index].position
		instance.item_storage_type = 1
		
		spawn_index += 1
		if spawn_index > spawn_nodes.size() - 1:
			break
		
		$ItemSpawnGroup.add_child(instance)

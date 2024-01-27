extends Node2D

var rng = RandomNumberGenerator.new()

@export var dialog_timeout_ms_per_char: int = 100
@export var dialog_display_min_ms: int = 1000
var dialog_timeout_total: int = 0
var time_since_last_dialog: int = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	time_since_last_dialog += delta * 1000
	if time_since_last_dialog >= dialog_timeout_total:
		$Label.visible = false


## Picks a mood for the king and an item the king wants based on that mood
func generate_new_task():
	print("## KING - Generating new task")
	
	# Pick a random mood
	var mood = GameManager.mood_options[rng.randi_range(0, GameManager.mood_options.size() - 1)]
	print("## King's mood - ", mood)
	
	# Get a list of items that match the mood
	var items_for_mood: Array[String] = []
	for item_name in GameManager.item_data:
		var moods = GameManager.item_data[item_name].moods
		
		if moods.has(mood):
			items_for_mood.push_back(item_name)
			
	# Pick an item, and pick an attribute hint
	var target_item = items_for_mood[rng.randi_range(0, items_for_mood.size() - 1)]
	var attributes_for_item = GameManager.item_data[target_item].attributes.keys()
	var item_attribute = attributes_for_item[rng.randi_range(0, attributes_for_item.size() - 1)]
	
	print("## King's target item - ", target_item)
	print("## King's attribute hint: ", item_attribute)
	
	GameManager.current_target_item_name = target_item
	
	var hint_string = "I'm feeling {mood}. Bring me something {attribute}!"
	var hint_string_fmt = hint_string.format({ "mood": mood, "attribute": item_attribute })
	
	print("## King's hint string: ", hint_string_fmt)
	say(hint_string_fmt)

## Attempt to given an item to the king to satisfy his request
## TODO this method is entirely untested
func give_item_to_king(item_name: String):
	Player.hands.queue_free()
	Player.hands = null
	
	print("## KING - presenting ", item_name, " to the King")
	
	if !GameManager.item_data.has(item_name):
		print("Invalid item name ", item_name, " passed into give_item_to_king()")
		return
	
	if !GameManager.current_target_item_name:
		print("No target item name is set")
		return
	
	# TODO: If the item is an exact match, we should do something special
	if item_name == GameManager.current_target_item_name:
		print("The item was an exact match! Wohoo!")
	
	# Otherwise, see how many King happiness points the player earned
	var happiness_earned = 0
	var target_item_data = GameManager.item_data.get(GameManager.current_target_item_name)
	var target_item_attributes = target_item_data.attributes.keys()
	var given_item_data = GameManager.item_data.get(item_name)
	
	for attribute in target_item_attributes:
		var points_for_attribute = given_item_data.attributes.get(attribute)
		
		if points_for_attribute:
			happiness_earned += points_for_attribute
	
	# TODO: If the item doesn't match the attribute the king specified at all, no points are awarded
	# And we'll have to increment the "failure" counter
	if happiness_earned <= 0:
		GameManager.current_failures_count += 1
	else:
		GameManager.king_current_happiness += happiness_earned
		
	# If failures are excessive, the game is over
	if GameManager.current_failures_count >= GameManager.max_failed_attempts:
		GameManager.game_over()
		
	print("New king happiness: ", GameManager.king_current_happiness)
	
	say("Thanks!")

func _on_static_body_2d_input_event(viewport, event: InputEvent, shape_idx):
	if event.is_action_pressed("action_primary"):
		print("click")
		print(Player.hands)
		
		if Player.hands != null:
			var item_name = Player.hands.item_name
			give_item_to_king(item_name)

func say(text: String):
	$Label.text = text
	$Label.visible = true
	time_since_last_dialog = 0
	dialog_timeout_total = (dialog_timeout_ms_per_char * text.length()) + dialog_display_min_ms

extends Node2D

var rng = RandomNumberGenerator.new()

## The number of attempts a player can fail to deliver an item before the game is over
@export var max_failed_attempts: int = 3
var current_failures_count: int = 0

@export var king_initial_happiness: float = 0.5
@export var king_max_happiness: float = 3.0
var king_current_happiness: float = 0

var item_data: Dictionary = {}
var mood_options: Array[String] = []
var attribute_options: Array[String] = []

var current_target_item_name: String

# TODO: this data will not persist between scene changes if the king is unloaded.
# We should abstract shared data into singletons:
# https://docs.godotengine.org/en/stable/tutorials/scripting/singletons_autoload.html

func _init():
	load_item_data()
	king_current_happiness = king_initial_happiness

## Picks a mood for the king and an item the king wants based on that mood
func generate_new_task():
	print("## KING - Generating new task")
	
	# Pick a random mood
	var mood = mood_options[rng.randi_range(0, mood_options.size() - 1)]
	print("## King's mood - ", mood)
	
	# Get a list of items that match the mood
	var items_for_mood: Array[String] = []
	for item_name in item_data:
		var moods = item_data[item_name].moods
		
		if moods.has(mood):
			items_for_mood.push_back(item_name)
			
	# Pick an item, and pick an attribute hint
	var target_item = items_for_mood[rng.randi_range(0, items_for_mood.size() - 1)]
	var attributes_for_item = item_data[target_item].attributes.keys()
	var item_attribute = attributes_for_item[rng.randi_range(0, attributes_for_item.size() - 1)]
	
	print("## King's target item - ", target_item)
	print("## King's attribute hint: ", item_attribute)
	
	var hint_string = "I'm feeling {mood}. Bring me something {attribute}!"
	var hint_string_fmt = hint_string.format({ "mood": mood, "attribute": item_attribute })
	
	print("## King's hint string: ", hint_string_fmt)

## Loads all item data on init of this scene into memory
func load_item_data():
	var file = FileAccess.open("data/items.json", FileAccess.READ)
	var contents = file.get_as_text()

	item_data = JSON.parse_string(contents)
	
	for item_name in item_data:
		var attributes = item_data[item_name].attributes
		
		# Add attributes to master list
		for attr_name in attributes:
			if !attribute_options.has(attr_name):
				attribute_options.push_back(attr_name)
		
		var moods = item_data[item_name].moods
		
		for mood in moods:
			if !mood_options.has(mood):
				mood_options.push_back(mood)
		
	print("## ALL ATTRIBUTES - ", attribute_options)
	print("## ALL MOODS - ", mood_options)

## Attempt to given an item to the king to satisfy his request
## TODO this method is entirely untested
func give_item_to_king(item_name: String):
	print("## KING - presenting an item to the King")
	
	# TODO: If the item is an exact match, we should do something special
	if item_name == current_target_item_name:
		print("The item was an exact match! Wohoo!")
	
	# Otherwise, see how many King happiness points the player earned
	var happiness_earned = 0
	var target_item_data = item_data[current_target_item_name]
	var target_item_attributes = target_item_data.attributes.keys()
	var given_item_data = item_data[item_name]

	for attribute in target_item_attributes:
		var points_for_attribute = given_item_data.attributes[attribute]
		
		if points_for_attribute:
			happiness_earned += points_for_attribute
	
	# TODO: If the item doesn't match the attribute the king specified at all, no points are awarded
	# And we'll have to increment the "failure" counter
	if happiness_earned <= 0:
		current_failures_count += 1
	else:
		king_current_happiness += happiness_earned
	
	# If failures are excessive, the game is over
	if current_failures_count >= max_failed_attempts:
		game_over()
	
## TODO: handle game over state
func game_over():
	print("Game over :'(")

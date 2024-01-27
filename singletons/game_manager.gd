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

var round_started: bool = true
var round_count: int = 0
var round_time_ms: float = 0
var round_max_time_ms: float = 42

func _init():
	load_item_data()
	king_current_happiness = king_initial_happiness

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
	
func _process(delta):
	if (round_started):
		round_time_ms += delta
		if round_time_ms >= round_max_time_ms:
			game_over()
	
func init_round():
	round_count += 1
	round_time_ms = 0
	round_started = true
	print("Starting Round #{round_count}".format({ "round_count": round_count }))
	
## TODO: handle game over state
func game_over():
	round_started = false
	round_count = 0
	print("Game over :'(")

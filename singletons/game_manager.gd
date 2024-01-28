extends Node2D

var rng = RandomNumberGenerator.new()

enum GameState {
	NotStarted,
	Started,
	Win,
	Lose
}

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
var current_hint: String = ""

var game_state: GameState = GameState.NotStarted
var game_score: int = 0
var round_count: int = 0
@export var max_rounds: int = 3
var round_time_secs: float = 0
@export var round_max_time_secs: float = 42
var round_total_secs_played: float = 0

signal start_new_round

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
	if (game_state == GameState.Started):
		round_time_secs += delta
		round_total_secs_played += delta
		if round_time_secs >= round_max_time_secs:
			end_game(false)

func init_round():
	cleanup_game()
	round_count += 1
	king_current_happiness = 0
	
	if round_count >= max_rounds:
		end_game(true)
	else:
		start_new_round.emit()
		print("Starting Round #{round_count}".format({ "round_count": round_count }))

func new_game():
	cleanup_game()
	game_state = GameState.Started
	round_count = 0
	game_score = 0
	init_round()

## TODO: handle game over state
func end_game(won: bool):
	if won:
		game_score += (round_max_time_secs - round_time_secs) * 3
		game_state = GameState.Win
	else:
		game_state = GameState.Lose
	cleanup_game()

func cleanup_game():
	current_hint = ""
	current_target_item_name = ""
	round_time_secs = 0
	current_failures_count = 0

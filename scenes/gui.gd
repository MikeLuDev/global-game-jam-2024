extends CanvasLayer

const SECONDS_PER_MINUTE = 60.0

func format_time(seconds: float):
	var mins = floor(seconds / SECONDS_PER_MINUTE)
	var secs = floor(fmod(seconds, SECONDS_PER_MINUTE))
	var format_str = "{m}m{s}s"
	var time_left = format_str.format({ "m": mins, "s": secs })
	
	return time_left

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	handle_visibility()
	set_time_remaining()
	set_objective()
	set_win_loss()

# TODO: also hide this if the game is over
func handle_visibility():
	if GameManager.game_state == GameManager.GameState.NotStarted:
		visible = false
		return
	else:
		visible = true
		
	var round_over = GameManager.game_state == GameManager.GameState.Win || GameManager.game_state == GameManager.GameState.Lose
	
	if round_over:
		$Objective.visible = false
		$TimeLeft.visible = false
		$WinLoseContainer.visible = true
	else:
		$Objective.visible = true
		$TimeLeft.visible = true
		$WinLoseContainer.visible = false

func set_time_remaining():	
	$TimeLeft.text = "Time Remaining: " + format_time(GameManager.round_max_time_secs - GameManager.round_time_secs)

func set_objective():
	$Objective.text = GameManager.current_hint

func set_win_loss():
	var round_over = GameManager.game_state == GameManager.GameState.Win || GameManager.game_state == GameManager.GameState.Lose
	var won = GameManager.game_state == GameManager.GameState.Win

	if round_over != true:	
		return
	
	# Default to win conditions
	var main_text =  "The King is pleased! You Win!"
	
	if won == false:
		main_text = "You have failed your king and country"
		
	$WinLoseContainer/WinLoseText.text = main_text
	$WinLoseContainer/RoundsPlayed.text = "Rounds Played: " + str(GameManager.round_count)
	$WinLoseContainer/TimePlayed.text = "Time Played: " + format_time(GameManager.round_total_secs_played)


func _on_new_game_button_pressed():
	GameManager.new_game()

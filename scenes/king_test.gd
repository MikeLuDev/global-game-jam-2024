extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	$King.generate_new_task()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

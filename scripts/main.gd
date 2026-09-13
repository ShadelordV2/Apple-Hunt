extends Node2D
@onready var fade: ColorRect = $HUD/Fade
@onready var score_label: Label = $HUD/ScorePanel/ScoreLabel
@onready var full_score_label: Label = $HUD/FullScorePanel/FullScoreLabel


var score: int = 0
var level_score: int = 0
var level: int = 1
var current_level_root: Node = null

func _ready() -> void:
	# setup the level
	fade.modulate.a = 1.0
	current_level_root = get_node("LevelRoot")
	await _load_level(level, false)

# --------------------
# LEVEL MANAGEMENT
# --------------------

func _load_level(level_number: int, reset_score: bool) -> void:
	
	# Fade out
	await _fade(1.0)
	
	if reset_score:
		level_score = 0
		score_label.text = "SCORE: 0"
	
	if current_level_root:
		current_level_root.queue_free()
	
	# Change level
	var level_path = "res://scenes/levels/level%s.tscn" % level_number
	current_level_root = load(level_path).instantiate()
	add_child(current_level_root)
	current_level_root.name = "LevelRoot"
	_setup_level(current_level_root)
	await _fade(0.0)
	
func _setup_level(level_root: Node) -> void:
	#connect exit
	var exit = level_root.get_node_or_null("exit")
	if exit:
		exit.body_entered.connect(_on_exit_body_entered)
	#connect apples
	var apples = level_root.get_node_or_null("apples")
	if apples:
		for enemy in apples.get_children():
			enemy.collected.connect(increase_score)
	#connect snails
	var snails = level_root.get_node_or_null("snails")
	if snails:
		for snail in snails.get_children():
			snail.player_died.connect(_on_player_died)

# --------------------
# SIGNAL HANDLERS
# --------------------

func _on_exit_body_entered(body: Node2D) -> void:
	# Make sure the node triggering the exit is actually the player
	if body.name == "player":
		level += 1
		body.can_move = false
		increase_full_score()
		await _load_level(level, false)
		

func _on_player_died(body):
	body.die()
	await _load_level(level, true)

func increase_score() -> void:
	level_score += 1
	score_label.text = "SCORE: %s" % level_score

func increase_full_score() -> void:
	score += level_score
	full_score_label.text = "FULLSCORE: %s" % score
	level_score = 0
	score_label.text = "SCORE: 0"
	
# ---------------
# FADE
# ---------------

func _fade(to_alpha: float) -> void:
	var tween := create_tween()
	tween.tween_property(fade, "modulate:a", to_alpha, 1.0)
	await tween.finished

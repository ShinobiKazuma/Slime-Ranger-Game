extends Control

signal game_over
@onready var player := get_tree().get_first_node_in_group("player")
@onready var enemy := get_tree().get_nodes_in_group("enemy")
@onready var health_bar: TextureProgressBar = %HealthBar
@onready var game_over_label: Label = %GameOverLabel
@onready var retry_button: Button = %RetryButton
@onready var quit_button: Button = %QuitButton
@onready var gameover: ColorRect = %gameover
@onready var score_label: Label = %ScoreLabel
@onready var highscore_label: Label = %HighscoreLabel
@onready var gameover_score := %GameoverHighscoreLabel
@onready var joystick := %VirtualJoystick
@onready var fire_button := %FireTouchButton
@onready var dodge_button := %DodgeTouchButton
var show_buttons := false : set = set_button_visibility
var button_idle_time := 2.0
var _time := 0.0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_button_visibility(false)
	gameover.visible = false
	get_tree().paused = false
	health_bar.max_value = player.maxHp
	game_over.connect(func():
		gameover.visible = true
		get_tree().paused = true
	)
	player.player_down.connect(func():
		game_over.emit())


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	_time += _delta
	var health = player.health
	health_bar.value = health
	score_label.text = "Score: " + str(Global.score)
	highscore_label.text = "High Score: " + str(Global.highscore)
	gameover_score.text = highscore_label.text

	if joystick.is_pressed or fire_button.is_pressed() or dodge_button.is_pressed():
		if !show_buttons:
			set_button_visibility(true)
	elif _time >= button_idle_time:
		set_button_visibility(false)



func _on_retry_button_pressed() -> void:
	get_tree().reload_current_scene()


func _on_quit_button_pressed() -> void:
	get_tree().quit()

func set_button_visibility(new_value:bool)->void:
	_time = 0.0
	show_buttons = new_value
	fire_button.visible = show_buttons
	dodge_button.visible = show_buttons
	match show_buttons:
		true:
			var _tween := create_tween()
			_tween.tween_property(joystick,"self_modulate:a",1.0,0.8)
		false:
			var _tween := create_tween()
			_tween.tween_property(joystick,"self_modulate:a",0.0,0.8)

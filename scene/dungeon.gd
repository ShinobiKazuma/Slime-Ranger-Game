extends Node2D
@onready var spawn_timer: Timer = %SpawnTimer
@onready var spawn_path_2d: Path2D = %SpawnPath2D
@onready var spawn_path_follow_2d: PathFollow2D = %SpawnPathFollow2D
@onready var enemies : Array[PackedScene] = [
	preload("res://scene/giant_slime.tscn"),
	preload("res://scene/medium_slime.tscn"),
	preload("res://scene/slime.tscn"),]
var level :float=0.0
@onready var player := get_tree().get_first_node_in_group("player")
@onready var audio_stream_player: AudioStreamPlayer = %AudioStreamPlayer2
@onready var game_over_music := %GameOverMusic
@onready var game_ui := %UI
var songs : Array[AudioStream] = [
	preload("res://Music/BoxManBattle2.wav"),
	preload("res://Music/GameOver.wav"),
]
func _ready() -> void:
	game_ui.game_over.connect(_change_song)
	Global.score = 0
	spawn_slime()


func _process(_delta: float) -> void:
	level = (round(Global.score/10))
	level = clampf(level,0.0,15.0)
	spawn_timer.wait_time = 15.0 - level
	
func _on_spawn_timer_timeout() -> void:
	spawn_slime()


func spawn_slime()->void:
	var spawn_path := PathFollow2D.new()
	spawn_path_2d.add_child(spawn_path)
	spawn_path.progress_ratio = randf()
	for enemy in enemies:
		var new_slime = enemies.pick_random().instantiate()
		new_slime.global_position = spawn_path.global_position
		add_child(new_slime)
	spawn_path.queue_free.call_deferred()

func _change_song()->void:
	audio_stream_player.stop()
	game_over_music.play()
func _on_ui_game_over() -> void:
	pass

class_name EnigmaNerveLogoAnimation extends Control

@onready var enigma_nerve : TextureRect = %EnigmaNerveLogo
@onready var enigma_nerve_logo: AtlasTexture = %EnigmaNerveLogo.texture

var end_animation: int = 4224
var animation_frame: int = 128
@export var load_scene : PackedScene
@export var in_time : float = 0.5
@export var fade_in : float = 1.5
@export var pause_time:=1.5
@export var fade_out: float = 1.5
@export var out_time : float = 0.5

@export var vfx_loader:Array[PackedScene]=[]

func _ready() -> void:
	_fire_effects()
	logo_animation()

func logo_animation()->void:
	enigma_nerve.modulate.a = 0.0
	var fade_in_tween = self.create_tween()
	fade_in_tween.tween_interval(in_time)
	fade_in_tween.tween_property(enigma_nerve, "modulate:a",1.0,fade_in)
	await fade_in_tween.finished
	for i in range(33):
		await get_tree().create_timer(.08).timeout
		enigma_nerve_logo.region = Rect2(i*animation_frame,0,128,128)
	var fade_out_tween = self.create_tween()
	fade_out_tween.tween_interval(out_time)
	fade_out_tween.tween_property(enigma_nerve, "modulate:a",0.0,fade_out)
	await fade_out_tween.finished
	get_tree().change_scene_to_packed(load_scene)

func _fire_effects()->void:
	for effect in vfx_loader:
		var effect_player := effect.instantiate()
		effect_player["time"]["one_shot"] = true
		add_child(effect_player)
		effect_player.emitting = true
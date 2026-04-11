extends CharacterBody2D

const SPEED = 400.0
var health := 3

@onready var player := get_tree().get_first_node_in_group("player")
@onready var slime : PackedScene = preload("res://scene/slime.tscn")
@onready var hurtbox : Area2D = $hurtbox
@onready var movement_timer := Timer.new()
@onready var pause_timer := Timer.new()
@export var is_destroyed := false
var current_scale : Vector2

signal pop_the_slime

func _ready() -> void:
	set_physics_process(false)
	var med_random_size := randf_range(2.3,3.0)
	current_scale = Vector2(med_random_size,med_random_size)
	scale = current_scale
	add_child(movement_timer)
	add_child(pause_timer)
	movement_timer.wait_time = .8
	pause_timer.wait_time = 0.8
	movement_timer.one_shot = true
	pause_timer.one_shot = true
	pop_the_slime.connect(_slime_death)
	pause_timer.timeout.connect(func():
		movement_timer.start())
	await get_tree().create_timer(0.2).timeout
	set_physics_process(true)





func _physics_process(delta: float) -> void:
	if player != null:
		var direction = global_position.direction_to(player.global_position)
		if not movement_timer.is_stopped() and pause_timer.is_stopped():
			velocity = direction * SPEED * delta
			_slime_movement(movement_timer.wait_time/2)
		if movement_timer.is_stopped():
			velocity = Vector2.ZERO
			if pause_timer.is_stopped():
				await get_tree().process_frame
				pause_timer.start()

		rotation = direction.angle()
	else: 
		velocity.x = 0.0
		velocity.y = 0.0
	move_and_slide()



func _on_hurtbox_area_entered(area: Area2D) -> void:
	if not is_destroyed:
		if area.is_in_group("player"):
			set_physics_process(false)
			set_collision_layer_value(1,false)
			hurtbox.monitorable = false
			hurtbox.monitoring = false
			_slime_hit(0.2)
			is_destroyed = true

		
		if area.is_in_group("projectile"):
			var knockback_direction = (global_position - area.global_position).normalized()
			var knockback = knockback_direction * 2000.0
			velocity = knockback
			move_and_slide()
			set_physics_process(false)
			set_collision_layer_value(1,false)
			hurtbox.monitorable = false
			hurtbox.monitoring = false
			Global.score += 3
			_slime_hit(0.2)
			is_destroyed = true

func _burst_into_slimes()->void:
	var new_slime = slime.instantiate()
	var random_angle := randf_range(0.0,2.0 * PI)
	var random_direction := Vector2(1.0,0.0).rotated(random_angle)
	var random_distance := randf_range(20.0,40.0)
	new_slime.global_position = global_position + (random_direction * random_distance)
	add_sibling(new_slime)

func _slime_movement(time:float)->void:
	var _tween := create_tween()
	_tween.tween_property(self,"scale",Vector2(current_scale.x*1.1,current_scale.y*0.8),time)
	_tween.tween_property(self,"scale",Vector2(current_scale.x,current_scale.y),time)

func _slime_hit(time:float)->void:
	var _tween := create_tween()
	_tween.tween_property(self,"scale",Vector2(current_scale.x*1.1,current_scale.y*0.8),time)
	_tween.tween_property(self,"scale",Vector2(current_scale.x*0.8,current_scale.y*1.1),time)
	_tween.tween_property(self,"scale",Vector2(current_scale.x*1.2,current_scale.y*0.6),time)
	_tween.tween_property(self,"scale",Vector2(current_scale.x*0.6,current_scale.y*1.2),time)
	_tween.tween_property(self,"scale",Vector2(current_scale.x,current_scale.y),time)
	_tween.finished.connect(pop_the_slime.emit)


func _slime_death()->void:
	for i in randi_range(2,4):
		_burst_into_slimes()
	var _fade_tween := create_tween()
	_fade_tween.tween_property($Sprite2D,"self_modulate:a",0.0,0.3)
	$SlimePop.emitting = true
	$SlimePop.finished.connect(func():
		queue_free.call_deferred()
		)
		
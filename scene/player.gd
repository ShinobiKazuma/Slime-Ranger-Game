class_name PlayerBody extends CharacterBody2D

signal player_down
signal take_damage

enum States {IDLE, RUNNING, ATTACKING, DAMAGED, DYING, DODGING}
var state: States = States.IDLE
const SPEED = 300.0
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var player_hurtbox := %hurtbox
@onready var run_trail := %RunTrail
@onready var dodge_timer := Timer.new()
var steering_factor := 5.0
@export var dagger : PackedScene = preload("res://scene/dagger.tscn")
@export var health := 3
@export var i_frame_time := 1.5
var maxHp:= 10
var _time := 0.0
var direction : Vector2

func _ready() -> void:
	add_child(dodge_timer)
	dodge_timer.wait_time = 3.0
	dodge_timer.one_shot = true
	animated_sprite_2d.animation_finished.connect(_on_animation_finished.bind("death"))
	animated_sprite_2d.animation_finished.connect(_on_animation_finished.bind("hit"))
	animated_sprite_2d.animation_finished.connect(_on_animation_finished.bind("attack"))
	take_damage.connect(_take_damage)
	set_state(States.IDLE)
	health = 10

func _physics_process(delta: float) -> void:
	# Add the gravity.

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	direction = Input.get_vector("left","right","up","down").normalized()

	match state:
		States.RUNNING:
			_process_running_state(delta)
		States.IDLE:
			_process_idle_state(delta)
		States.ATTACKING:
			_process_attacking_state(delta)
		States.DAMAGED:
			_process_damaged_state(delta)
		States.DODGING:
			_process_dodging_state(delta)

	var screen_size := get_viewport_rect().size
	position.x = wrapf(position.x,0,screen_size.x)
	position.y = wrapf(position.y,0,screen_size.y)
	
	move_and_slide()


func _take_damage()->void:
	if health <= 0:
		return
	set_state(States.DAMAGED)
	health -= 1
	
	if health <= 0:
		set_state(States.DYING)

func _process_idle_state(_delta:float)->void:
	velocity.y = move_toward(direction.y,0,_delta)
	velocity.x = move_toward(direction.x,0,_delta)
	if direction != Vector2.ZERO:
		set_state(States.RUNNING)
	if Input.is_action_just_pressed("fire"):
		set_state(States.ATTACKING)
	if Input.is_action_just_pressed("dodge") and dodge_timer.is_stopped():
		set_state(States.DODGING)

func _process_running_state(_delta:float)->void:
	var desired_velocity := SPEED * direction
	var steering_vector := desired_velocity - velocity
	velocity += steering_vector * steering_factor * _delta
	if direction != Vector2.ZERO:
		rotation = direction.angle()
	if direction == Vector2.ZERO:
		set_state(States.IDLE)
	if Input.is_action_just_pressed("fire"):
		set_state(States.ATTACKING)
	if Input.is_action_just_pressed("dodge") and dodge_timer.is_stopped():
		set_state(States.DODGING)

func _process_attacking_state(_delta:float)->void:
	var attack_frames := animated_sprite_2d.frame
	if attack_frames >= 2:
		set_state(States.IDLE)

func _process_damaged_state(_delta:float)->void:
	var hit_frames := animated_sprite_2d.frame
	if hit_frames >= 2:
		set_state(States.IDLE)

func _process_dodging_state(_delta:float)->void:
	var i_frames := animated_sprite_2d.frame
	if i_frames >= 7:
		set_state(States.IDLE)
	
	velocity *= 1.005


func set_state(new_state: States)->void:
	var previous_state := state
	state = new_state
	

	match state:
		States.IDLE:
			animated_sprite_2d.play("default")
		States.RUNNING:
			animated_sprite_2d.play("run")
			run_trail.emitting = true
		States.ATTACKING:
			animated_sprite_2d.play("attack")
			_throw_dagger()
		States.DAMAGED:
			animated_sprite_2d.play("hit")
		States.DYING:
			set_physics_process(false)
			animated_sprite_2d.play("death")
		States.DODGING:
			dodge_timer.start()
			start_i_frames()
			set_collision_layer_value(1,false)
			animated_sprite_2d.play("dodge")
	
	match previous_state:
		States.IDLE:
			pass
		States.RUNNING:
			run_trail.emitting = false
		States.ATTACKING:
			pass
		States.DAMAGED:
			pass
		States.DYING:
			pass
		States.DODGING:
			velocity *= 1
			end_i_frames()
			set_collision_layer_value(1,true)
			pass

func _throw_dagger()->void:
	var flying_dagger := dagger.instantiate()
	add_sibling(flying_dagger)
	flying_dagger.global_position = self.global_position
	flying_dagger.global_rotation = self.global_rotation


func _on_hurtbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemy"):
		take_damage.emit()
		print(health)

func _on_animation_finished(_anim_name:String)->void:
	if _anim_name == "attack":
		set_state(States.IDLE)
	if _anim_name == "hit":
		set_physics_process(true)
	if _anim_name == "death":
		if health <= 0:
			print("player down!")
			player_down.emit()

func start_i_frames()->void:
	player_hurtbox.monitorable = false
	player_hurtbox.monitoring = false

func end_i_frames()->void:
	player_hurtbox.monitorable = true
	player_hurtbox.monitoring = true
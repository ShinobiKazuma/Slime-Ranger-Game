extends Area2D

@export var speed := 300.0
@export var max_distance := 1200.0
var _distance_traveled : float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var direction := Vector2.RIGHT.rotated(rotation)
	position += direction * speed * delta
	_distance_traveled += speed * delta
	if _distance_traveled >= max_distance:
		queue_free()



func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemy"):
		queue_free()

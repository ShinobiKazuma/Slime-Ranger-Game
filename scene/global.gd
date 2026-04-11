extends Node
var highscore :int=0
var score:int=0
var points:=0
signal gain_points(points)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	score = 0


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if score > highscore:
		highscore = score

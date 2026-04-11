extends Node
const DUNGEON="res://scene/dungeon.tscn"


func _on_button_pressed() -> void:
	get_tree().change_scene_to_file(DUNGEON)

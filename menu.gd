extends Control

@export var scenes: Array[PackedScene] = [
	preload("res://Boids/Boids.tscn"),
	preload("res://Line_Marcher/line_marcher.tscn")
]
@export var button_min_size: Vector2 = Vector2(240, 48)
@export var spacing: int = 12

func _ready() -> void:
	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", spacing)
	center.add_child(box)

	for scene in scenes:
		if scene == null:
			continue
		var button := Button.new()
		button.text = _name_from_path(scene.resource_path)
		button.custom_minimum_size = button_min_size
		button.pressed.connect(_on_scene_button_pressed.bind(scene))
		box.add_child(button)

func _name_from_path(path: String) -> String:
	return path.get_file().get_basename().capitalize()

func _on_scene_button_pressed(scene: PackedScene) -> void:
	get_tree().change_scene_to_packed(scene)

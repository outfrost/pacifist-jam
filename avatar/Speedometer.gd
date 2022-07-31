extends Control

export var speed: float = 0.0 setget set_speed

func set_speed(value: float) -> void:
	$Label.text = "%03d" % (value * 100.0) as int

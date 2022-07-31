# Copyright 2021 Outfrost
# This work is free software. It comes without any warranty, to the extent
# permitted by applicable law. You can redistribute it and/or modify it under
# the terms of the Do What The Fuck You Want To Public License, Version 2,
# as published by Sam Hocevar. See the LICENSE file for more details.

class_name Game
extends Node

onready var main_menu: Control = $UI/MainMenu
onready var transition_screen: TransitionScreen = $UI/TransitionScreen
onready var level = $Level

var debug: Reference

func _ready() -> void:
	randomize()

	if OS.has_feature("debug"):
		var debug_script = load("res://debug.gd")
		if debug_script:
			debug = debug_script.new(self)
			debug.startup()

	main_menu.connect("start_game", self, "on_start_game")
	main_menu.get_node("MouseSensSlider").connect("value_changed", level, "mouse_sens_changed")
	main_menu.get_node("MouseSensSlider").connect("value_changed", self, "mouse_sens_changed")
	main_menu.get_node("VolumeSlider").connect("value_changed", self, "volume_changed")

func _process(delta: float) -> void:
	DebugOverlay.display("fps %d" % Performance.get_monitor(Performance.TIME_FPS))

	if Input.is_action_just_pressed("menu"):
		back_to_menu()

func on_start_game() -> void:
	main_menu.hide()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	level.start()

func back_to_menu() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	level.stop()
	main_menu.show()

func volume_changed(value: float):
	AudioServer.set_bus_volume_db(0, linear2db(value))
	main_menu.get_node("VolumeEdit").text = "%.2f" % value

func mouse_sens_changed(value: float):
	main_menu.get_node("MouseSensEdit").text = "%.2f" % value

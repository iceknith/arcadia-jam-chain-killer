extends Node

const settings_packed_scene := preload('res://src/gui/pause_menu.tscn')
const end_game_packed_scene := preload('res://src/gui/end_menu.tscn')

var settings_scene:Control
var settings_scene_tween:Tween

var world:Node3D
var is_in_world:bool = false

func _ready():
	world = $World
	world.process_mode = Node.PROCESS_MODE_DISABLED
	
	$CanvasLayer/MainMenu/VBoxContainer/Play.pressed.connect(launch_game)
	$CanvasLayer/MainMenu/VBoxContainer/HBoxContainer/Options.pressed.connect(toggle_settings)
	$CanvasLayer/MainMenu/VBoxContainer/HBoxContainer/Exit.pressed.connect(get_tree().quit)
	Globals.settingsToggle.connect(toggle_settings)
	Globals.restart.connect(get_tree().reload_current_scene)
	Globals.gameEnd.connect(end_game)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed('esc'):
		toggle_settings()

func toggle_settings():
	if settings_scene_tween && settings_scene_tween.is_running(): return
	
	settings_scene_tween = create_tween()
	settings_scene_tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)
	if settings_scene:
		if world && is_in_world:
			world.process_mode = Node.PROCESS_MODE_INHERIT
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			
		settings_scene_tween.tween_property(settings_scene, 'modulate', Color.TRANSPARENT, 0.3)
		settings_scene_tween.tween_callback(settings_scene.queue_free)
		settings_scene = null
	else:
		if world && is_in_world:
			world.process_mode = Node.PROCESS_MODE_DISABLED
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		
		settings_scene = settings_packed_scene.instantiate()
		settings_scene.modulate = Color.TRANSPARENT
		$CanvasLayer.add_child(settings_scene)
		settings_scene_tween.tween_property(settings_scene, 'modulate', Color.WHITE, 0.3)

func launch_game():
	world.process_mode = Node.PROCESS_MODE_INHERIT
	is_in_world = true
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)
	tween.tween_property($CanvasLayer/MainMenu, 'modulate', Color.TRANSPARENT, 0.3)
	tween.tween_callback($CanvasLayer/MainMenu.queue_free)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func end_game():
	await get_tree().process_frame
	world.process_mode = Node.PROCESS_MODE_DISABLED
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	var end_scene = end_game_packed_scene.instantiate()
	end_scene.modulate = Color.TRANSPARENT
	var tween = create_tween()
	$CanvasLayer.add_child(end_scene)
	tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(end_scene, 'modulate', Color.WHITE, 1)
	

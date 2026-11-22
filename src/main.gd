extends Node

const settings_packed_scene := preload('res://src/gui/pause_menu.tscn')

var settings_scene:Control
var settings_scene_tween:Tween

var world:Node3D

func _ready():
	world = $PlayerDebugScene
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _process(delta: float) -> void:
	if Input.is_action_just_pressed('esc'):
		toggle_settings()

func toggle_settings():
	if settings_scene_tween && settings_scene_tween.is_running(): return
	
	settings_scene_tween = create_tween()
	settings_scene_tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)
	if settings_scene:
		if world:
			world.process_mode = Node.PROCESS_MODE_INHERIT
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			
		settings_scene_tween.tween_property(settings_scene, 'modulate', Color.TRANSPARENT, 0.3)
		settings_scene_tween.tween_callback(settings_scene.queue_free)
		settings_scene = null
	else:
		if world:
			world.process_mode = Node.PROCESS_MODE_DISABLED
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		
		settings_scene = settings_packed_scene.instantiate()
		settings_scene.modulate = Color.TRANSPARENT
		add_child(settings_scene)
		settings_scene_tween.tween_property(settings_scene, 'modulate', Color.WHITE, 0.3)

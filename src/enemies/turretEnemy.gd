class_name TurretEnemy
extends Enemy

@export var detection_range:Area3D
@export var shooting_sound_player:AudioStreamPlayer3D
@export var bullet_scene:PackedScene
@export var SHOOTING_DURATION:float = 2

var shoot_timer:Timer
var player:Player = null

func _ready() -> void:
	super()
	if detection_range:
		detection_range.body_entered.connect(_on_detection_range_entered)
		detection_range.body_exited.connect(_on_detection_range_exited)
	
	shoot_timer = Timer.new()
	shoot_timer.wait_time = SHOOTING_DURATION
	shoot_timer.timeout.connect(_on_shoot)
	add_child(shoot_timer)

func _on_detection_range_entered(body:Node3D):
	if body as Player:
		shoot_timer.start()
		player = body

func _on_detection_range_exited(body):
	if body as Player:
		shoot_timer.stop()
		player = null

func _on_shoot():
	if player && !is_stunned():
		var bullet:BulletEnemy = bullet_scene.instantiate()
		bullet.position = global_position
		bullet.direction = global_position.direction_to(player.global_position)
		get_parent().add_child(bullet)
		if shooting_sound_player:
			shooting_sound_player.play()

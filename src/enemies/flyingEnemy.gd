class_name FlyingEnemy
extends Enemy

@export var detection_range:Area3D
@export var ambiant_sound_player:AudioStreamPlayer3D
@export var SPEED:float = 6
@export var ACCELERATION:float = 3

var player:Player = null

func _ready() -> void:
	super()
	if detection_range:
		detection_range.body_entered.connect(_on_detection_range_entered)
		detection_range.body_exited.connect(_on_detection_range_exited)

func _physics_process(delta: float) -> void:
	var direction:Vector3
	if player && !is_stunned():
		direction = global_position.direction_to(player.global_position)
	else:
		direction = Vector3.ZERO
	velocity = lerp(velocity, direction * SPEED, delta * ACCELERATION)
	move_and_slide()

func _on_detection_range_entered(body:Node3D):
	if body as Player:
		player = body
		ambiant_sound_player.play()

func _on_detection_range_exited(body):
	if body as Player:
		player = null
		ambiant_sound_player.stop()

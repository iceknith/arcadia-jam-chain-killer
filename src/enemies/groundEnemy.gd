class_name GroundEnemy
extends Enemy

@export var detection_range:Area3D
@export var navigation_agent:NavigationAgent3D
@export var ambiant_sound_player:AudioStreamPlayer3D
@export var SPEED:float = 6
@export var ACCELERATION:float = 3

const PATH_UPDATE_TIME = 0.5

var pathUpdateTimer:Timer
var player:Player = null

func _ready() -> void:
	super()
	if detection_range:
		detection_range.body_entered.connect(_on_detection_range_entered)
		detection_range.body_exited.connect(_on_detection_range_exited)
	
	pathUpdateTimer = Timer.new()
	pathUpdateTimer.wait_time = PATH_UPDATE_TIME
	pathUpdateTimer.timeout.connect(_on_path_update)
	add_child(pathUpdateTimer)

func _physics_process(delta: float) -> void:
	var direction:Vector3
	
	if player && !is_stunned():
		direction = global_position.direction_to(navigation_agent.get_next_path_position())
	else:
		direction = Vector3.ZERO
	velocity = lerp(velocity, direction * SPEED, delta * ACCELERATION)
	move_and_slide()

func _on_detection_range_entered(body:Node3D):
	if body as Player:
		pathUpdateTimer.start()
		player = body

func _on_detection_range_exited(body):
	if body as Player:
		pathUpdateTimer.stop()
		player = null

func _on_path_update():
	if player:
		navigation_agent.target_position = player.global_position

class_name LaserBeam
extends Area3D

const length = 100.0

@export var player:Player
@export var startPoint:Vector3
@export var duration:float
@export var SPEED:float = 10
@export var ACCELERATION:float = 0.5
@export var DAMAGE:float = 5
@export var FADE_IN_DURATION := 3.0
@export var FADE_OUT_DURATION := 1.5

var endPoint:Vector3
var velocity:Vector3
var is_removing:bool

func _ready() -> void:
	$MeshInstance3D.transparency = 1
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CIRC)
	tween.tween_property($MeshInstance3D, 'transparency', 0, FADE_IN_DURATION)
	
	endPoint = player.position + Vector3.LEFT * 50
	body_entered.connect(_on_body_entered)
	
	get_tree().create_timer(duration - FADE_OUT_DURATION).timeout.connect(delete)

func _physics_process(delta: float) -> void:
	var direction = endPoint.direction_to(player.global_position)
	velocity = lerp(velocity, direction * SPEED, ACCELERATION * delta)
	endPoint += velocity * delta
	
	global_position = startPoint
	look_at(endPoint)

func _on_body_entered(body:Node3D):
	if body as Player && !is_removing:
		player.damage(DAMAGE)

func delete():
	is_removing = true
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CIRC)
	tween.tween_property($MeshInstance3D, 'transparency', 1, FADE_OUT_DURATION)
	tween.tween_callback(queue_free)
	

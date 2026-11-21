class_name Chain
extends MeshInstance3D

signal contact
signal deleted

@export var SPEED:float = 60
@export var texture_size:float = 1
@export var player:Player

@export var goal_pos:Vector3
@export var goal_enemy:Node3D

@onready var plane_mesh:PlaneMesh = mesh
@onready var mesh_material:StandardMaterial3D = plane_mesh.material

var speed:float
var head_pos:Vector3
var has_reached_end:bool
var is_retracting:bool = false

func _ready() -> void:
	head_pos = player.get_chain_origin()

func _process(delta: float) -> void:
	var real_goal_pos := goal_enemy.global_position if goal_enemy != null else goal_pos
	
	if is_retracting:
		var direction := (player.get_chain_origin() - head_pos).normalized()
		var velocity := direction * delta * SPEED
		head_pos += velocity
		if player.get_chain_origin().distance_squared_to(head_pos) <= delta * SPEED * 5:
			delete()
	elif !has_reached_end:
		var direction := (real_goal_pos - player.get_chain_origin()).normalized()
		var velocity := direction * delta * SPEED
		head_pos += velocity
		if player.get_chain_origin().distance_squared_to(head_pos) >= player.get_chain_origin().distance_squared_to(real_goal_pos):
			has_reached_end = true
			head_pos = real_goal_pos
			contact.emit()
			$DeleteTimer.stop()
	else:
		head_pos = real_goal_pos
	
	position = (player.get_chain_origin() + head_pos)/2
	plane_mesh.size.y = player.get_chain_origin().distance_to(head_pos)
	mesh_material.uv1_scale.y = plane_mesh.size.y / texture_size
	
	look_at(player.get_chain_origin())

func retract() -> void:
	is_retracting = true

func delete() -> void:
	deleted.emit()
	queue_free()

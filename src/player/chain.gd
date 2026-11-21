class_name Chain
extends MeshInstance3D

signal grab

@export var SPEED:float = 60
@export var ACCELERATION_TIME:float = 1
@export var texture_size:float = 1
@export var player:Player

@export var goal_pos:Vector3
@export var goal_enemy:Node3D

@onready var plane_mesh:PlaneMesh = mesh
@onready var mesh_material:StandardMaterial3D = plane_mesh.material

var speed:float
var head_pos:Vector3
var has_reached_end:bool

func _ready() -> void:
	head_pos = player.get_chain_origin()
	

func _process(delta: float) -> void:
	var real_goal_pos := goal_enemy.global_position if goal_enemy != null else goal_pos
	
	if !has_reached_end:
		var direction := (real_goal_pos - player.get_chain_origin()).normalized()
		head_pos += direction * delta * SPEED
		if player.get_chain_origin().distance_squared_to(head_pos) >= player.get_chain_origin().distance_squared_to(real_goal_pos):
			has_reached_end = true
			head_pos = goal_pos
			grab.emit()
			$DeleteTimer.stop()
	else:
		head_pos = goal_pos
	
	position = (player.get_chain_origin() + head_pos)/2
	plane_mesh.size.y = player.get_chain_origin().distance_to(head_pos)
	mesh_material.uv1_scale.y = plane_mesh.size.y / texture_size
	
	look_at(head_pos)

func delete() -> void:
	queue_free()

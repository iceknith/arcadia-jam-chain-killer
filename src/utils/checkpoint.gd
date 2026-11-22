class_name Checkpoint
extends Area3D

var respawn_point:Vector3
var respawn_rotation:float

func _ready() -> void:
	collision_layer = 0
	collision_mask = 0b10
	
	for child in get_children():
		if child as Marker3D:
			respawn_point = child.global_position
			respawn_rotation = child.rotation.y
			break
	
	body_entered.connect(_on_body_enter)

func _on_body_enter(body:Node3D) -> void:
	var player := body as Player
	if player:
		player.respawn_point = respawn_point
		player.respawn_rotation = respawn_rotation

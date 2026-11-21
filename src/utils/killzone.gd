class_name Killzone
extends FogVolume

func _ready() -> void:
	var area = Area3D.new()
	area.collision_layer = 0
	area.collision_mask = 0b10
	area.body_entered.connect(_on_body_entered)
	add_child(area)
	
	var rect_collision = BoxShape3D.new()
	rect_collision.size = size
	rect_collision.size.y = 5
	
	var collision = CollisionShape3D.new()
	collision.shape = rect_collision
	area.add_child(collision)

func _on_body_entered(body:Node3D):
	var player := body as Player
	if player:
		player.damage(10000000000000, Vector3.ZERO)

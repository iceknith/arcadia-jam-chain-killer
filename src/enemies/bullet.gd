class_name BulletEnemy
extends Enemy

@export var MAX_LIVE_TIME:float = 10
@export var direction:Vector3
@export var speed:float

func _ready() -> void:
	super()
	get_tree().create_timer(MAX_LIVE_TIME).timeout.connect(queue_free)
	if contact_damage_area:
		contact_damage_area.body_entered.connect(_on_bullet_contact)

func _physics_process(delta: float) -> void:
	if !is_stunned():
		velocity = direction * speed
		move_and_slide()

func _on_bullet_contact(_body:Node) -> void:
	await get_tree().process_frame
	queue_free()

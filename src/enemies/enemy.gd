class_name Enemy
extends CharacterBody3D

@export var contact_damage_area:Area3D
@export var damage_sound_player:AudioStreamPlayer3D
@export_group('Attack')
@export var MAX_HEALTH:float = 10
@export var STUN_TIME:float = 1
@export var CONTACT_DAMAGE:float = 10
@export_group('Visuals')
@export var sprite:SpriteBase3D
@export var DAMAGE_COLOR_1:Color = Color(1,0.2,0.2)
@export var DAMAGE_COLOR_2:Color = Color(0.5,0,0)
@export var DAMAGE_FLICKER_COUNT:int = 2
@export var DAMAGE_FLICKER_DURATION:float = 0.3
@export var GRABBED_COLOR:Color = Color(0.2, 0, 0)

@onready var health = MAX_HEALTH

signal die

var stun_timer:SceneTreeTimer

var damage_tween:Tween

func _ready() -> void:
	if contact_damage_area:
		contact_damage_area.body_entered.connect(on_contact_body_enter)

func damage(damage_delt:float):
	if health <= 0: return
	
	if damage_sound_player:
		damage_sound_player.play()
	health -= damage_delt
	if health <= 0:
		death_animation()
	else:
		damage_animation()

func damage_animation():
	if sprite == null: return
	
	if damage_tween: damage_tween.kill()
	damage_tween = create_tween()
	damage_tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CIRC)
	for i in DAMAGE_FLICKER_COUNT:
		damage_tween.tween_property(sprite, 'modulate', DAMAGE_COLOR_1, DAMAGE_FLICKER_DURATION)
		damage_tween.tween_property(sprite, 'modulate', DAMAGE_COLOR_2, DAMAGE_FLICKER_DURATION)
	damage_tween.tween_property(sprite, 'modulate', Color.WHITE, DAMAGE_FLICKER_DURATION)

func death_animation():
	die.emit()
	if sprite != null:
		stun_timer = get_tree().create_timer(10000)
		if damage_tween: damage_tween.kill()
		damage_tween = create_tween()
		damage_tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CIRC)
		damage_tween.tween_property(sprite, 'modulate', DAMAGE_COLOR_1, DAMAGE_FLICKER_DURATION)
		damage_tween.tween_property(sprite, 'modulate', Color.TRANSPARENT, DAMAGE_FLICKER_DURATION)
		damage_tween.tween_callback(queue_free)
	else:
		queue_free()

func grab():
	if health <= 0: return
	
	if damage_tween: damage_tween.kill()
	damage_tween = create_tween()
	damage_tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CIRC)
	damage_tween.tween_property(sprite, 'modulate', GRABBED_COLOR, 0.1)
	
	stun_timer = get_tree().create_timer(STUN_TIME)

func ungrab():
	damage_tween = create_tween()
	damage_tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CIRC)
	damage_tween.tween_property(sprite, 'modulate', Color.WHITE, 0.1)

func on_contact_body_enter(body:Node3D):
	var player := body as Player
	if player && !is_stunned():
		player.damage(CONTACT_DAMAGE, global_position)

func is_stunned() -> bool:
	return stun_timer != null && stun_timer.time_left > 0

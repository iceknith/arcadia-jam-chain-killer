extends Control
class_name PlayerUI

@export var DOT_RADIUS:float = 2
@export var BAR_HEIGHT:float = 3.5
@export var BAR_WIDTH:float = 1.5
@export var BAR_DISTANCE:float = 2
@export var COLOR := Color.AZURE

var grab:bool
var can_grab:bool
var can_shoot:bool = false

func _ready() -> void:
	$AnimationPlayer.play_backwards("can_grab")
	$SwooshPlayer.play()

func on_shoot():
	$AnimatedSprite2D.play("shoot")
	$SwooshPlayer.stop()

func on_shoot_end():
	$AnimatedSprite2D.play("idle")
	$SwooshPlayer.play()

func on_can_grab():
	if (can_grab != true && grab != true):
		can_grab = true
		if $AnimationPlayer.is_playing() && $AnimationPlayer.current_animation != 'can_grab':
			await $AnimationPlayer.animation_finished
		$AnimationPlayer.play("can_grab")

func on_cannot_grab():
	if (can_grab != false && grab != true):
		can_grab = false
		if $AnimationPlayer.is_playing() && $AnimationPlayer.current_animation != 'can_grab':
			await $AnimationPlayer.animation_finished
		$AnimationPlayer.play_backwards("can_grab")

func on_grab():
	if !grab:
		grab = true
		can_grab = false
		$AnimationPlayer.play("on_grab")
		$AnimatedSprite2D.play("grab_launch")
		$SwooshPlayer.stop()

func on_grab_retract():
	$AnimatedSprite2D.play("grab_retract")
	$SwooshPlayer.stop()

func on_ungrab():
	if grab:
		grab = false
		can_grab = false
		$AnimationPlayer.play("on_ungrab")
		$AnimatedSprite2D.play("idle")
		$SwooshPlayer.play()

func on_damage(new_helth_perc:float):
	$HpBar.value = new_helth_perc

func on_heal(new_helth_perc:float):
	$HpBar.value = new_helth_perc

func on_respawn():
	$HpBar.value = 1

func _draw() -> void:
	# Draw 
	var screen_center := size / 2.0
	draw_circle(screen_center, DOT_RADIUS, COLOR, true)
	
	draw_rect(Rect2(
			screen_center - Vector2(BAR_WIDTH / 2, BAR_HEIGHT + DOT_RADIUS + BAR_DISTANCE), 
			Vector2(BAR_WIDTH, BAR_HEIGHT)
		), COLOR, true)
	draw_rect(Rect2(
			screen_center - Vector2(BAR_WIDTH / 2, - DOT_RADIUS - BAR_DISTANCE), 
			Vector2(BAR_WIDTH, BAR_HEIGHT)
		), COLOR, true)
	draw_rect(Rect2(
			screen_center - Vector2(BAR_HEIGHT + DOT_RADIUS + BAR_DISTANCE, BAR_WIDTH / 2), 
			Vector2(BAR_HEIGHT, BAR_WIDTH)
		), COLOR, true)
	draw_rect(Rect2(
			screen_center - Vector2(- DOT_RADIUS - BAR_DISTANCE, BAR_WIDTH / 2),
			Vector2(BAR_HEIGHT, BAR_WIDTH)
		), COLOR, true)

func _process(_delta: float) -> void:
	queue_redraw()

class_name Boss
extends Enemy

const attacks = [
	[
		'laser',
		'bullets'
	],
	[
		'laser',
		'spawn_enemies',
		'bullets'
	]
]
const PHASES_COUNT = 2
const laser_beam_scene = preload('res://src/enemies/boss/laser_beam.tscn')
const boss_bullet_scene = preload('res://src/enemies/boss/boss_bullet.tscn')
const pillar_scene = preload('res://src/enemies/boss/pillar.tscn')

@export var ATTACK_HEIGHT:float = 10
@export var ATTACK_TRANSITION_TIME:float = 5
@export var pillar_spawn_locations:Array[Marker3D]

@export_group('bullets')
@export var bullets_wave_amount:int = 5
@export var bullets_per_wave:int = 24
@export var bullet_boss_distance:float = 15

@export_group('spawn_enemies')
@export var enemies_boss_min_distance:float = 15
@export var enemies_boss_max_distance:float = 50
@export var enemies_boss_max_distance_y:float = 20
@export var player_min_distance:float = 10
@export var enemies:Array[PackedScene]
@export var MOB_AMOUNT:int = 3
@export var MAX_MOB_AMOUNT:int = 6

@onready var default_pos = global_position

var player:Player

var phase:int = 0
var attack:String 

var pillar_count:int 
var mob_count:int = 0

var laser_beam:LaserBeam

func _ready():
	super()
	$DetectionRange.body_entered.connect(_on_detection_range_entered)
	$AttackTimer.timeout.connect(on_attack_end)
	$IdleTimer.timeout.connect(launch_attack)
	$CanvasLayer/Control.modulate = Color.TRANSPARENT
	%Shield.transparency = true
	%ShieldCollisionShape.disabled = true

func _on_detection_range_entered(body:Node3D):
	if body as Player:
		player = body
		$IdleTimer.start()
		
		var intro_tween = create_tween()
		intro_tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)
		intro_tween.tween_property($CanvasLayer/Control, 'modulate', Color.WHITE, 3)

func launch_attack():
	attack = attacks[phase].pick_random()
	
	if attack != 'spawn_enemies':
		var tween := create_tween()
		tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
		tween.tween_property(self, 'global_position', default_pos + ATTACK_HEIGHT * Vector3.UP, ATTACK_TRANSITION_TIME)
		await tween.finished
	
	$AttackTimer.start()
	if attack == 'bullets':
		launch_bullets()
	elif attack == 'laser':
		launch_laser()
	elif attack == 'spawn_enemies':
		launch_spawn_enemies()

func launch_laser():
	laser_beam = laser_beam_scene.instantiate()
	laser_beam.startPoint = $LaserSpawnPoint.global_position
	laser_beam.player = player
	laser_beam.duration = $AttackTimer.wait_time
	get_parent().add_child(laser_beam)

func launch_bullets():
	for i in bullets_wave_amount:
		var radius := i%2 * PI / float(bullets_per_wave)
		$ShootStreamPlayer.play()
		for _i in bullets_per_wave:
			radius += 2 * PI / float(bullets_per_wave)
			var bullet:BulletEnemy = boss_bullet_scene.instantiate()
			var bullet_direction := Vector2.from_angle(radius)
			bullet.direction = Vector3(bullet_direction.x, 0, bullet_direction.y)
			bullet.position = position
			bullet.position.y = player.global_position.y + 0.5
			
			if bullet.position.y <= default_pos.y:
				bullet.position += bullet_boss_distance * bullet.direction
			
			get_parent().add_child(bullet)
		
		await get_tree().create_timer($AttackTimer.wait_time / bullets_wave_amount).timeout

func launch_spawn_enemies():
	for _i in MOB_AMOUNT:
		if (mob_count <= MAX_MOB_AMOUNT):
			mob_count += 1
			var enemy:Enemy = enemies.pick_random().instantiate()
			enemy.position = player.global_position
			while player.global_position.distance_squared_to(enemy.position) <= player_min_distance ** 2:
				var distance := randf_range(enemies_boss_min_distance, enemies_boss_max_distance)
				var pos2d := Vector2.from_angle(randf_range(-PI, PI)) * distance
				var height := enemies_boss_max_distance_y * randf_range(-1, 1)
				enemy.position = Vector3(pos2d.x, height, pos2d.y) + global_position
				enemy.die.connect(func(): mob_count -= 1)
			
			get_parent().add_child(enemy)
			await get_tree().create_timer($AttackTimer.wait_time / MOB_AMOUNT).timeout 

func on_attack_end():
	var tween := create_tween()
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BOUNCE)
	tween.tween_property(self, 'global_position', default_pos, ATTACK_TRANSITION_TIME)
	await tween.finished
	
	$IdleTimer.start()

func damage(damage_delt:float):
	super(damage_delt)
	%HpBar.value = health/MAX_HEALTH
	
	if phase == 0 && health <= MAX_HEALTH/2:
		phase = 1
		launch_phase_2()
	
	if health <= 0:
		Globals.gameEnd.emit()
		if laser_beam && laser_beam.is_inside_tree():
			laser_beam.queue_free()

func launch_phase_2():
	$AttackTimer.stop()
	$IdleTimer.stop()
	
	pillar_count = pillar_spawn_locations.size()
	for marker in pillar_spawn_locations:
		var pillar:Enemy = pillar_scene.instantiate()
		pillar.position = marker.global_position
		pillar.die.connect(_on_pillar_destroyed)
		get_parent().add_child(pillar)
	
	var player_kb_direction := global_position.direction_to(player.global_position)
	player.knockback_speed = Vector2(player_kb_direction.x, player_kb_direction.z) * 50
	player.velocity.y = 18
	
	%ShieldCollisionShape.disabled = false
	var tween := create_tween()
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(self, 'global_position', default_pos, 1)
	tween.tween_property(%Shield, 'transparency', 0.75, 1)
	await tween.finished
	
	$AttackTimer.start()
	launch_spawn_enemies()

func _on_pillar_destroyed():
	pillar_count -= 1
	
	if pillar_count <= 0:
		%ShieldCollisionShape.disabled = true
	
		var tween := create_tween()
		tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
		tween.tween_property(%Shield, 'transparency', 1, 1)

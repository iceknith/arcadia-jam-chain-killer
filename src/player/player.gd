class_name Player
extends CharacterBody3D

@export_group('Movement')
@export var SPEED:float = 6
@export var JUMP_FORCE:float = 6.5
@export var GRAVITY:float = 0.17
@export var LOOK_SENSITIVITY:float = 6
@export var FLOOR_ACCELERATION: float = 15
@export var AIR_ACCELERATION: float = 5
@export var JUMP_ACCELERATION_MULT: float = 1.3
@export var SPEED_CHANGE_ACCELERATION: float = 1

@export_group('Dash')
@export var DASH_ACCELERATION_DURATION:float = 0.2
@export var DASH_DECELERATION_DIRATION:float = 3
@export var DASH_PEAK_SPEED:float = 12

@export_group('Visuals')
@export var MIN_FOV:float = 75
@export var FOV_SPEED_MULT:float = 0.5

@export_group('Grab')
@export var GRAB_DISTANCE:float = 30
@export var GRAB_RELEASE_DISTANCE:float = 0.5
@export var GRAB_MAX_SPEED:float = 30
@export var GRAB_ACCELERATION_DURATION:float = 2
@export var GRAB_DAMAGE:float = 3

@export_group('Attack')
@export var SHOOT_DAMAGE:float = 2
@export var SHOOT_MAX_DISTANCE:float = 100
@export var SHOOT_LAUNCH_SPEED_MULT:float = 2

const chain_scene := preload('res://src/player/chain.tscn')

var current_speed := SPEED
var current_acceleration := FLOOR_ACCELERATION
var movementSpeed:Vector2
var direction: Vector3
var movement_tween: Tween

var is_dashing := false

var chain:Chain
var is_grab_chain:bool

var is_in_grab := false
var chain_goal_enemy:Enemy
var chain_goal_pos:Vector3

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	%GraplingHookRayCast.target_position.z = -GRAB_DISTANCE
	%ShootRayCast.target_position.z = -SHOOT_MAX_DISTANCE

func _process(delta: float) -> void:
	%Camera.fov = lerp(%Camera.fov, MIN_FOV + velocity.length() * FOV_SPEED_MULT, 5 * delta)
	
	attack_handler()

func _physics_process(delta: float) -> void:
	coyote_time_handler()
	dash_handler()
	grab_handler()
	movement_handler(delta)

func _unhandled_input(event: InputEvent) -> void:
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			rotation.y -= event.relative.x * LOOK_SENSITIVITY / 1000 # tourne le perso sur l'axe droite/gauche
			%Camera.rotation.x -=  + event.relative.y * LOOK_SENSITIVITY / 1000 	# tourne la caméra de haut en bas
			
			# contraint la rotation de la caméra pour éviter que le joueur puisse se tordre le cou
			%Camera.rotation.x = clamp(%Camera.rotation.x, deg_to_rad(-90), deg_to_rad(90))

func coyote_time_handler() -> void:
	if (is_on_floor()):
		%CoyoteTimer.start()

func can_jump() -> bool:
	return !%CoyoteTimer.is_stopped() && !is_gravity_overrided()

func stop_coyote_time() -> void:
	%CoyoteTimer.stop()

func dash_handler() -> void:
	if can_jump() && Input.is_action_just_pressed("dash") && %DashCooldown.is_stopped():
		%CameraAnimator.play("dash_crouch")
		is_dashing = true
		if movement_tween: movement_tween.kill()
		movement_tween = create_tween()
		movement_tween.set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_OUT)
		movement_tween.tween_property(self, 'current_speed', DASH_PEAK_SPEED, DASH_ACCELERATION_DURATION)
		movement_tween.tween_property(self, 'current_speed', 0, DASH_DECELERATION_DIRATION)
	
	if is_dashing && Input.is_action_just_released("dash"):
		%DashCooldown.start()
		%CameraAnimator.play("dash_uncrouch")
		is_dashing = false
		movement_tween.kill()

func grab_handler() -> void:
	var collider = %GraplingHookRayCast.get_collider()
	if collider != null && %GraplingHookCooldown.is_stopped() && chain == null:
		if Input.is_action_just_pressed("grab"):
			if collider as Enemy:
				chain_goal_enemy = collider
				chain_goal_enemy.is_grabbed()
			else:
				chain_goal_enemy = null
				chain_goal_pos = %GraplingHookRayCast.get_collision_point()
			is_grab_chain = true
			%PlayerUi.on_grab()
			
			chain = chain_scene.instantiate()
			chain.player = self
			if collider as Enemy:
				chain.goal_enemy = chain_goal_enemy
			else:
				chain.goal_pos = chain_goal_pos
			chain.contact.connect(begin_grab_movement)
			get_parent().add_child(chain)
		else:
			%PlayerUi.on_can_grab()
	else:
		%PlayerUi.on_cannot_grab()
	
	if is_in_grab:
		var goal_pos := chain_goal_enemy.global_position if chain_goal_enemy != null else chain_goal_pos 
		var force_release := global_position.distance_squared_to(goal_pos) < GRAB_RELEASE_DISTANCE ** 2
		
		if Input.is_action_just_released("grab") || force_release:
			if force_release:
				current_speed = SPEED
				if chain_goal_enemy != null:
					chain_goal_enemy.damage(GRAB_DAMAGE)
				
			%GraplingHookCooldown.start()
			is_in_grab = false
			direction = Vector3.ZERO
			velocity.y = sqrt(velocity.y)
			movement_tween.kill()
			
			%PlayerUi.on_ungrab()
			chain.delete()
			chain = null
		else:
			direction = global_position.direction_to(goal_pos)
			velocity = direction * current_speed
	elif chain != null:
		if Input.is_action_just_released("grab"):
			chain.delete()
			chain = null

func begin_grab_movement():
	is_in_grab = true
	if movement_tween: movement_tween.kill()
	movement_tween = create_tween()
	movement_tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	movement_tween.tween_property(self, 'current_speed', GRAB_MAX_SPEED, GRAB_ACCELERATION_DURATION)

func attack_handler() -> void:
	if Input.is_action_pressed('shoot') && chain == null && %PlayerUi.can_shoot:
		var collider = %ShootRayCast.get_collider()
		is_grab_chain = false
		if collider as Enemy:
			chain_goal_enemy = collider
		else:
			chain_goal_enemy = null
			chain_goal_pos = %ShootRayCast.get_collision_point()
			if chain_goal_pos == global_position:
				chain_goal_pos += %ShootRayCast.target_position
			
		%PlayerUi.on_shoot()
	
		chain = chain_scene.instantiate()
		chain.player = self
		if collider as Enemy:
			chain.goal_enemy = chain_goal_enemy
		else:
			chain.goal_pos = chain_goal_pos
		chain.deleted.connect(func (): chain = null)
		chain.contact.connect(on_attack_land)
		get_parent().add_child(chain)

func on_attack_land():
	if chain_goal_enemy != null:
		chain_goal_enemy.damage(SHOOT_DAMAGE)
	chain.retract()

func movement_handler(delta:float) -> void :
	if !is_gravity_overrided():
		velocity.y -= GRAVITY
	
	if Input.is_action_pressed("jump") and can_jump():
		stop_coyote_time()
		velocity.y += JUMP_FORCE
		current_speed *= JUMP_ACCELERATION_MULT
	
	if !is_acceleration_overrided():
		if is_on_floor():
			current_acceleration = FLOOR_ACCELERATION
		else:
			current_acceleration = AIR_ACCELERATION
	
	if !is_direction_overrided():
		# Get the input direction and handle the movement/deceleration.
		# As good practice, you should replace UI actions with custom gameplay actions.
		var input_dir := Input.get_vector("left", "right", "up", "down")
		direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		if direction.length_squared() >= 1: direction = direction.normalized()
	
	if !is_speed_overrided():
		current_speed = lerp(current_speed, SPEED, SPEED_CHANGE_ACCELERATION * delta)
	
	if !is_movement_overrided():
		movementSpeed = lerp(movementSpeed, Vector2(direction.x, direction.z) * current_speed, current_acceleration * delta)
	
	if !is_velocity_overrided():
		velocity.x = movementSpeed.x
		velocity.z = movementSpeed.y
	
	move_and_slide()

### CONSTS FUNCS ###

func is_gravity_overrided() -> bool:
	return is_in_grab

func is_speed_overrided() -> bool:
	return is_dashing || is_in_grab

func is_direction_overrided() -> bool:
	return is_in_grab

func is_movement_overrided() -> bool:
	return is_in_grab

func is_acceleration_overrided() -> bool:
	return is_dashing || is_in_grab

func is_velocity_overrided() -> bool:
	return is_in_grab

func get_chain_origin() -> Vector3:
	return %GrabOrigin.global_position if is_grab_chain else %AttackOrigin.global_position

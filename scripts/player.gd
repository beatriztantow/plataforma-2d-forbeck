extends CharacterBody2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var reload_timer: Timer = $ReloadTimer

@export var aceleration = 400
@export var deceleration = 300
@export var slide_deceleration = 50
@export var max_speed = 100.0

const JUMP_VELOCITY = -250.0

var status: PlayerState
var direction = 0
var jump_count = 0
var max_jump_count = 2

enum PlayerState {
	idle, 
	walk,
	jump,
	fall,
	ducking,
	slide,
	dead
}

func _ready() -> void:
	go_to_idle_state()

func move(delta: float):
	update_direction()

	if direction:
		velocity.x = move_toward(velocity.x, direction * max_speed, aceleration * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, deceleration * delta)

func _physics_process(delta: float) -> void:	
	if not is_on_floor():
		velocity += get_gravity() * delta

	match status:
		PlayerState.idle:
			idle_state(delta)
		PlayerState.walk:
			walk_state(delta)
		PlayerState.jump:
			jump_state(delta)
		PlayerState.fall:
			fall_state(delta)
		PlayerState.ducking:
			ducking_state(delta)
		PlayerState.slide:
			slide_state(delta)
		PlayerState.dead:
			dead_state(delta)

	move_and_slide()


func update_direction():
	direction = Input.get_axis("left", "right")

	if direction < 0:
		animated_sprite.flip_h = true
	elif direction > 0:
		animated_sprite.flip_h = false

func go_to_idle_state():
	status = PlayerState.idle
	animated_sprite.play("idle")

func go_to_walk_state():
	status = PlayerState.walk
	animated_sprite.play("walk")

func go_to_jump_state():
	status = PlayerState.jump
	animated_sprite.play("jump")
	velocity.y = JUMP_VELOCITY
	jump_count += 1

func go_to_fall_state():
	status = PlayerState.fall
	animated_sprite.play("fall")

func go_to_ducking_state():
	status = PlayerState.ducking
	animated_sprite.play("ducking")
	set_small_collider()

func go_to_slide_state():
	status = PlayerState.slide
	animated_sprite.play("slide")
	set_small_collider()

func go_to_dead_state():
	status = PlayerState.dead
	animated_sprite.play("dead")
	velocity = Vector2.ZERO
	reload_timer.start()

func exit_from_ducking_state():
	set_large_collider()

func exit_from_slide_state():
	set_large_collider()

func idle_state(delta: float):
	move(delta)
	if velocity.x != 0:
		go_to_walk_state()
		return

	if Input.is_action_just_pressed("jump"):
		go_to_jump_state()
		return

	if Input.is_action_pressed("ducking"):
		go_to_ducking_state()
		return

func walk_state(delta: float):
	move(delta)
	if velocity.x == 0:
		go_to_idle_state()
		return
		
	if !is_on_floor():
		jump_count += 1
		go_to_fall_state()
		return

	if Input.is_action_just_pressed("jump"):
		go_to_jump_state()
		return

	if Input.is_action_just_pressed("slide"):
		go_to_slide_state()
		return

func jump_state(delta: float):
	move(delta)

	if Input.is_action_just_pressed("jump") && can_jump():
		go_to_jump_state()
		return

	if velocity.y > 0:
		go_to_fall_state()
		return

func fall_state(delta: float):
	move(delta)

	if is_on_floor():
		jump_count = 0
		if velocity.x == 0:
			go_to_idle_state()
			return
		else:
			go_to_walk_state()
			return

	if Input.is_action_just_pressed("jump") && can_jump():
		go_to_jump_state()
		return

func ducking_state(_delta: float):
	update_direction ()
	if Input.is_action_just_released("ducking"):
		exit_from_ducking_state()
		go_to_idle_state()
		return

func slide_state(delta: float):
	velocity.x = move_toward(velocity.x, 0, delta * slide_deceleration)

	if Input.is_action_just_released("slide"):
		exit_from_slide_state()
		go_to_walk_state()
		return

	if velocity.x == 0:
		exit_from_slide_state()
		go_to_ducking_state()
		return

func dead_state(_delta: float):
	pass

func can_jump() -> bool:
	return jump_count < max_jump_count
	
func set_small_collider():
	collision_shape.shape.radius = 5
	collision_shape.shape.height = 10
	collision_shape.position.y = 3

func set_large_collider():
	collision_shape.shape.radius = 6
	collision_shape.shape.height = 16
	collision_shape.position.y = 0


func _on_hitbox_area_entered(area: Area2D) -> void:
	if velocity.y > 0:
		area.get_parent().take_damage()
		go_to_jump_state()
	else:
		if status != PlayerState.dead:
			go_to_dead_state()

func _on_reload_timer_timeout() -> void:
	get_tree().reload_current_scene()

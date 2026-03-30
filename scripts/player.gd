extends CharacterBody2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D


const SPEED = 80.0
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
	ducking
}

func _ready() -> void:
	go_to_idle_state()

func _physics_process(delta: float) -> void:	
	if not is_on_floor():
		velocity += get_gravity() * delta

	match status:
		PlayerState.idle:
			idle_state()
		PlayerState.walk:
			walk_state()
		PlayerState.jump:
			jump_state()
		PlayerState.fall:
			fall_state()
		PlayerState.ducking:
			ducking_state()

	move_and_slide()

func move():
	update_direction()

	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

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
	collision_shape.shape.radius = 5
	collision_shape.shape.height = 10
	collision_shape.position.y = 3

func exit_from_ducking_state():
	collision_shape.shape.radius = 6
	collision_shape.shape.height = 16
	collision_shape.position.y = 0
	

func idle_state():
	move()
	if velocity.x != 0:
		go_to_walk_state()
		return

	if Input.is_action_just_pressed("jump"):
		go_to_jump_state()
		return

	if Input.is_action_pressed("ducking"):
		go_to_ducking_state()
		return

func walk_state():
	move()
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

func jump_state():
	move()
	
	if Input.is_action_just_pressed("jump") && can_jump():
		go_to_jump_state()
		return

	if velocity.y > 0:
		go_to_fall_state()
		return

func fall_state():
	move()

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

func ducking_state():
	update_direction ()
	if Input.is_action_just_released("ducking"):
		exit_from_ducking_state()
		go_to_idle_state()
		return
		
func can_jump() -> bool:
	return jump_count < max_jump_count
	

extends CharacterBody2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

const SPEED = 80.0
const JUMP_VELOCITY = -250.0


enum PlayerState {
	idle, 
	walk,
	jump
}
var status: PlayerState

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

	move_and_slide()

func move():
	var direction := Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

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

func idle_state():
	move()
	if velocity.x != 0:
		go_to_walk_state()
		return

	if Input.is_action_just_pressed("jump"):
		go_to_jump_state()
		return

func walk_state():
	move()
	if velocity.x == 0:
		go_to_idle_state()
		return

	if Input.is_action_just_pressed("jump"):
		go_to_jump_state()
		return

func jump_state():
	move()
	if is_on_floor():
		if velocity.x == 0:
			go_to_idle_state()
			return
		else:
			go_to_walk_state()
			return

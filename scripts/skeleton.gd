extends CharacterBody2D

const SPEED = 10.0
const JUMP_VELOCITY = -400.0

enum SkeletonState {
	walk,
	dead
}

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox: Area2D = $Hitbox
@onready var wall_detector: RayCast2D = $WallDetector
@onready var ground_detector: RayCast2D = $GroundDetector

var status: SkeletonState
var direction = 1

func _ready() -> void:
	go_to_walk_state()

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	match status:
		SkeletonState.walk:
			walk_state(delta)
		SkeletonState.dead:
			dead_state(delta)

	move_and_slide()

func go_to_walk_state():
	status = SkeletonState.walk
	animated_sprite.play("walk")

func go_to_dead_state():
	status = SkeletonState.dead
	animated_sprite.play("dead")
	hitbox.process_mode = Node.PROCESS_MODE_DISABLED

func walk_state(_delta: float):
	velocity.x = SPEED * direction

	if (wall_detector.is_colliding() || !ground_detector.is_colliding()):
		scale.x *= -1
		direction *= -1

func dead_state(_delta: float):
	velocity = Vector2.ZERO

func take_damage():
	go_to_dead_state()

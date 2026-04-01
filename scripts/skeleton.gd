extends CharacterBody2D

const SPEED = 10.0
const JUMP_VELOCITY = -400.0

enum SkeletonState {
	walk,
	attack,
	dead
}

const SPINNING_BONE = preload("uid://bvo814y066my0")

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox: Area2D = $Hitbox
@onready var wall_detector: RayCast2D = $WallDetector
@onready var ground_detector: RayCast2D = $GroundDetector
@onready var player_detector: RayCast2D = $PlayerDetector
@onready var bone_start_position: Node2D = $BoneStartPosition

var status: SkeletonState
var direction = 1
var can_throw = true

func _ready() -> void:
	go_to_walk_state()

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	match status:
		SkeletonState.walk:
			walk_state(delta)
		SkeletonState.attack:
			attack_state(delta)
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

func go_to_attack_state():
	status = SkeletonState.attack
	velocity = Vector2.ZERO
	animated_sprite.play("attack")
	can_throw = true

func walk_state(_delta: float):
	velocity.x = SPEED * direction
	
	if (wall_detector.is_colliding() || !ground_detector.is_colliding()):
		scale.x *= -1
		direction *= -1
		return

	if player_detector.is_colliding():
		go_to_attack_state()
		return


func dead_state(_delta: float):
	velocity = Vector2.ZERO

func attack_state(_delta: float):
	if animated_sprite.frame == 2 && can_throw:
		throw_bone();
		can_throw = false
	#if !player_detector.is_colliding():
		#go_to_walk_state()
	#pass

func take_damage():
	go_to_dead_state()

func throw_bone():
	var new_bone = SPINNING_BONE.instantiate()
	add_sibling(new_bone)
	new_bone.position = bone_start_position.global_position
	new_bone.set_direction(self.direction)

func _on_animated_sprite_2d_animation_finished() -> void:
	if animated_sprite.animation == "attack":
		go_to_walk_state()
		return

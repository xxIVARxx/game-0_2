extends CharacterBody3D

@onready var camera_mount = $camera_mount
@onready var animation_player = $"visuals/Root Scene/AnimationPlayer"
#@onready var healthbar = $Healthbar

@onready var visuals = $visuals
@onready var camera = $camera_mount/Camera3D
@onready var hitbox = $"visuals/Root Scene/RootNode/RedTeam_SwordsMen_Armature/Skeleton3D/TwoHand_Sword_Iron/HitBox"


var SPEED = 3.0

const JUMP_VELOCITY = 4.5
var walking_speed = 3.0
var running_speed = 5.0

var running = false
var health = 100


@export var sens_horizental = 0.5
@export var sens_vertical = 0.5

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
# Get the gravity from the project settings to be synced with RigidBody nodes.
func _enter_tree():
	set_multiplayer_authority(str(name).to_int())

func _ready():
	if not is_multiplayer_authority(): return
	
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	camera.current = true

func _input(event):
	if not is_multiplayer_authority(): return
	
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x*sens_horizental))
		visuals.rotate_y(deg_to_rad(event.relative.x*sens_horizental))
		camera_mount.rotate_x(deg_to_rad(-event.relative.y*sens_vertical))
	
	
func _physics_process(delta):
	if not is_multiplayer_authority(): return
	
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	var input_dir = Input.get_vector("left", "right", "forward", "back")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	rpc("remote_set_position", direction)

	if Input.is_action_just_pressed("hit"):
		if animation_player.current_animation != "RedTeam_SwordsMen_Armature|Atack_TwoHandSwordsMen":
			hitx.rpc()
			hitbox.monitoring = true
			
	else:
		hitbox.monitoring = false
	
	if Input.is_action_pressed("run"):
		SPEED = running_speed
		running = true
	else:
		SPEED = walking_speed
		running = true
	if not is_on_floor():
		velocity.y -= gravity * delta
	
@rpc("call_local")
func runx():
	animation_player.play("RedTeam_SwordsMen_Armature|Running_TwoHandSwordsMen")


@rpc("call_local")
func hitx():
	animation_player.play("RedTeam_SwordsMen_Armature|Atack_TwoHandSwordsMen")


@rpc("any_peer", "call_local")
func remote_set_position(direction):
	visuals.look_at(position + direction)
	#dirx.rpc()
	if direction:
		if running:
				runx.rpc()
				visuals.look_at(position + direction)
						
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		
	else:
			#if animation_player.current_animation != "RedTeam_SwordsMen_Armature|Running_TwoHandSwordsMen":
				#animation_player.play("RedTeam_SwordsMen_Armature|Running_TwoHandSwordsMen")
			
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	move_and_slide()


func _on_hit_box_area_entered(area):
	if area.is_in_group("enemy"):
		print("damage +++")

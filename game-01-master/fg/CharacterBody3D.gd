extends CharacterBody3D


const SPEED = 5.0
var hero
@export var turn_speed =4.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
func _ready():
	hero = get_tree().get_nodes_in_group("hero")[0]


func _physics_process(delta):



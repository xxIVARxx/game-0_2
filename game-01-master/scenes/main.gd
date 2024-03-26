extends Node3D


var LaserInstance = preload("res://scenes/rope.tscn")
@onready var atk = $actionContainer

@onready var main_menu = $CanvasLayer/MainMenu
@onready var address_entry = $CanvasLayer/MainMenu/MarginContainer/VBoxContainer/AddressEntry

const player = preload("res://scenes/player.tscn")
const PORT = 9999
var enet_peer = ENetMultiplayerPeer.new()


func _on_host_button_pressed():
	main_menu.hide()
	
	enet_peer.create_server(PORT)
	multiplayer.multiplayer_peer = enet_peer
	multiplayer.peer_connected.connect(add_player)
	multiplayer.peer_disconnected.connect(remove_player)
	
	add_player(multiplayer.get_unique_id())
	
	#upnp_setup()
	
func _on_join_button_pressed():
	main_menu.hide()
	
	enet_peer.create_client("localhost", PORT)
	multiplayer.multiplayer_peer = enet_peer

func add_player(peer_id):
	var player = player.instantiate()
	player.name = str(peer_id)
	add_child(player)
func remove_player(peer_id):
	var player = get_node_or_null(str(peer_id))
	if player:
		player.queue_free()
func upnp_setup():
	var upnp = UPNP.new()
	
	var discover_result = upnp.discover()
	assert(discover_result == UPNP.UPNP_RESULT_SUCCESS, \
		"UPNP Discover Failed! Error %s" %discover_result)
		
	assert(upnp.get_gateway() and upnp.get_gateway().is_valid_gateway(), \
	"UPNP Invalid Gateway!")
	
	var map_result = upnp.add_port_mapping(PORT)
	assert(map_result == UPNP.UPNP_RESULT_SUCCESS, \
		"UPNP Port Mapping Failed! Error %s" %map_result)
		
	print("Success! Join Address : %s" % upnp.query_external_address()[randi() % 10]) 

func _input(event):
	if event.is_action_pressed("laser"): 
		clear_lasers()
		var laser_ui = LaserInstance.instantiate()
		atk.add_child(laser_ui)
	elif event.is_action_released("laser"):
		clear_lasers()
		
func clear_lasers():
	for n in atk.get_children():
		atk.remove_child(n)
		n.queue_free()


#func set_rope_position(node, new_position):
#	actionContainer.global_transform.origin = Vector3(10, 0, 0)

extends Node3D

@onready var left = $XROrigin3D/leftHand
@onready var right = $XROrigin3D/rightHand

var udp: PacketPeerUDP
var esp_ip = "192.168.4.1"
var port = 4210

var timer = 0.0
var intervalo = 0.05 # 20Hz

func _ready():
	udp = PacketPeerUDP.new()
	udp.set_dest_address(esp_ip, port)
	print("Tracking iniciado em ", esp_ip, ":", port)

func _physics_process(delta):
	timer += delta
	if timer > intervalo:
		timer = 0.0
		enviar_posicao()

func enviar_posicao():
	var payload = {
		"left": get_data(left),
		"right": get_data(right)
	}
	udp.put_packet(JSON.stringify(payload).to_utf8_buffer())

func get_data(ctrl: Node3D) -> Dictionary:
	var p = ctrl.global_position
	var r = ctrl.global_rotation_degrees
	return {"pos": {"x": p.x, "y": p.y, "z": p.z}, "rot": {"x": r.x, "y": r.y, "z": r.z}}

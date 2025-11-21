extends Node

# --- ARRASTE OS NÓS AQUI (IGUAL ESTÁ NO SEU PRINT) ---
@export_group("Juntas do Robô")
@export var joint_base: Node3D
@export var joint_ombro: Node3D
@export var joint_cotovelo: Node3D

# --- CORREÇÕES E AJUSTES ---
@export_group("Correção de Movimento")
@export var inverter_base: bool = false     
@export var inverter_ombro: bool = false    
@export var inverter_cotovelo: bool = false 

# Se estiver mexendo o motor errado, MARQUE essa opção:
@export var trocar_ombro_com_cotovelo: bool = true 

# --- REDE ---
var udp_peer: PacketPeerUDP
var esp_ip = "192.168.4.1"
var port = 4211

func _ready():
	udp_peer = PacketPeerUDP.new()
	udp_peer.set_dest_address(esp_ip, port)

func _physics_process(delta):
	if !joint_base: return

	# 1. Pega Rotações
	var r_base = joint_base.rotation_degrees.y
	var r_ombro = joint_ombro.rotation_degrees.x
	var r_cotovelo = joint_cotovelo.rotation_degrees.x

	# 2. Prepara os valores (0 a 180)
	# O 'remap' converte -90..90 do Godot para 0..180 do Servo
	# Se 'inverter' estiver marcado, ele faz 180..0
	var s_base = 0
	var s_ombro = 0
	var s_cotovelo = 0

	if inverter_base: s_base = remap(r_base, -90, 90, 180, 0)
	else:             s_base = remap(r_base, -90, 90, 0, 180)

	if inverter_ombro: s_ombro = remap(r_ombro, -45, 45, 180, 0)
	else:              s_ombro = remap(r_ombro, -45, 45, 0, 180)

	if inverter_cotovelo: s_cotovelo = remap(r_cotovelo, 0, 90, 180, 0)
	else:                 s_cotovelo = remap(r_cotovelo, 0, 90, 0, 180)

	# 3. MONTA O PACOTE (AQUI ESTÁ A MÁGICA)
	var packet = PackedByteArray()
	packet.append(255) # Cabeçalho
	
	# -- Canal 0: Base --
	packet.append(clamp(int(s_base), 0, 180))

	# -- AQUI FAZEMOS A TROCA SE PRECISAR --
	if trocar_ombro_com_cotovelo:
		# Manda o valor do COTOVELO no canal do OMBRO (Canal 1)
		packet.append(clamp(int(s_cotovelo), 0, 180)) 
		# Manda o valor do OMBRO no canal do COTOVELO (Canal 2)
		packet.append(clamp(int(s_ombro), 0, 180))    
	else:
		# Manda normal
		packet.append(clamp(int(s_ombro), 0, 180))
		packet.append(clamp(int(s_cotovelo), 0, 180))

	packet.append(90) # Pulso fixo
	
	udp_peer.put_packet(packet)

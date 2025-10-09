extends Node3D

# --- REFERÊNCIAS DE NÓS DA CENA ---
@onready var ray_cast_vr = $XR_Setup/XROrigin3D/XRController3D2/RayCast3D
@onready var camera = $XR_Setup/XROrigin3D/XRCamera3D

# --- ESTADO DOS BOTÕES ---
var botao_estados = {
	"GreenBtn": false,
	"RedBtn": false,
	"BlueBtn": false
}

# --- CONFIGURAÇÕES DA COMUNICAÇÃO UDP ---
var udp_peer = PacketPeerUDP.new()
const PORTA_ESP32 = 8888
var IP_ESP32 = "192.168.137.1"

# Função chamada uma vez quando o jogo inicia
func _ready():
	print("UDP configurado para enviar dados para o ESP32 em ", IP_ESP32, ":", PORTA_ESP32)
	
	# PING-PONG: Prepara o UDP para poder RECEBER pacotes de volta
	udp_peer.bind(PORTA_ESP32)
	
	# Loop para inicializar o estado visual de cada botão
	for nome_botao in botao_estados.keys():
		var botao_node = get_node(nome_botao)
		if botao_node:
			var mesh = botao_node.get_node("MeshInstance3D")
			if mesh and mesh.get_surface_override_material(0):
				mesh.set_surface_override_material(0, mesh.get_surface_override_material(0).duplicate())
			atualizar_visual_botao(nome_botao)

# PING-PONG: Chamado a cada frame para verificar se recebemos uma resposta
func _process(_delta):
	if udp_peer.get_available_packet_count() > 0:
		var packet_data = udp_peer.get_packet()
		var pong_message = packet_data.get_string_from_utf8()
		
		if pong_message == "pong":
			print(">>> PONG recebido de volta do Python!")

# Função chamada a cada frame, processa todos os inputs
func _input(_event):
	if Input.is_action_just_pressed("vr_trigger"):
		ray_cast_vr.force_raycast_update() 
		if ray_cast_vr.is_colliding():
			var collider = ray_cast_vr.get_collider()
			if botao_estados.has(collider.name):
				var nome_do_botao = collider.name
				toggle_botao(nome_do_botao)

	if Input.is_action_just_pressed("debug_click"):
		var mouse_pos = get_viewport().get_mouse_position()
		var space_state = get_world_3d().direct_space_state
		var from = camera.project_ray_origin(mouse_pos)
		var to = from + camera.project_ray_normal(mouse_pos) * 1000
		var query = PhysicsRayQueryParameters3D.create(from, to)
		var result = space_state.intersect_ray(query)
		if not result.is_empty():
			var collider = result.collider
			if botao_estados.has(collider.name):
				var nome_do_botao = collider.name
				toggle_botao(nome_do_botao)

# --- FUNÇÕES DE LÓGICA E COMUNICAÇÃO ---

# Inverte o estado de um botão e inicia o envio de dados
func toggle_botao(nome_botao: String):
	botao_estados[nome_botao] = not botao_estados[nome_botao]
	print("Estado do botão '", nome_botao, "' alterado para: ", str(botao_estados[nome_botao]))
	atualizar_visual_botao(nome_botao)
	
	var botao_node = get_node(nome_botao)
	if botao_node:
		var mesh = botao_node.get_node("MeshInstance3D")
		if mesh:
			var tween = create_tween()
			tween.tween_property(mesh, "position:z", 0.05, 0.1) 
			tween.tween_property(mesh, "position:z", 0, 0.1)

	enviar_dados_para_esp32()

# Função dedicada a atualizar a aparência de um botão
func atualizar_visual_botao(nome_botao: String):
	var botao_node = get_node(nome_botao)
	if not botao_node: return
	
	var mesh = botao_node.get_node("MeshInstance3D") as MeshInstance3D
	if not mesh: return
	
	var material = mesh.get_surface_override_material(0) as StandardMaterial3D
	if not material: return
	
	if botao_estados[nome_botao]:
		material.emission_enabled = true
		material.emission = material.albedo_color
		material.emission_energy_multiplier = 1.5
	else:
		material.emission_enabled = false

# Prepara e envia o estado atual dos botões para o ESP32
func enviar_dados_para_esp32():
	var byte_para_enviar = 0
	if botao_estados["GreenBtn"]:
		byte_para_enviar |= 1
	if botao_estados["RedBtn"]:
		byte_para_enviar |= 2
	if botao_estados["BlueBtn"]:
		byte_para_enviar |= 4
	
	var pacote = PackedByteArray([byte_para_enviar])
	udp_peer.set_dest_address(IP_ESP32, PORTA_ESP32)
	udp_peer.put_packet(pacote)


# PING-PONG: Esta função é chamada pelo sinal "timeout" do nó Timer a cada segundo
func _on_timer_timeout():
	var ping_message = "ping".to_utf8_buffer()
	udp_peer.set_dest_address(IP_ESP32, PORTA_ESP32)
	udp_peer.put_packet(ping_message)
	print("<<< Enviando PING...")

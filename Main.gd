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
# IMPORTANTE: Lembre-se de alterar este IP para o do seu ESP32
var IP_ESP32 = "127.0.0.1"

# Função chamada uma vez quando o jogo inicia
func _ready():
	print("UDP configurado para enviar dados para o ESP32 em ", IP_ESP32, ":", PORTA_ESP32)

# Função chamada a cada frame, processa todos os inputs
func _input(_event):
	if Input.is_action_just_pressed("vr_trigger"):
		print("--- NOVO CLIQUE ---")
		print("PASSO 1: Ação 'vr_trigger' detectada.")
		
		ray_cast_vr.force_raycast_update() 
		
		if ray_cast_vr.is_colliding():
			print("PASSO 2: SUCESSO! RayCast está colidindo.")
			var collider = ray_cast_vr.get_collider()
			print(" - Objeto atingido: ", collider.name)
			
			# --- LINHA CORRIGIDA ---
			# Agora checamos o nome do próprio collider, e não do pai dele.
			if botao_estados.has(collider.name):
				var nome_do_botao = collider.name
				print("PASSO 3: SUCESSO! É um botão válido. Nome: ", nome_do_botao)
				toggle_botao(nome_do_botao)
			else:
				print("PASSO 3: FALHA. O objeto atingido não está na lista 'botao_estados'.")
		else:
			print("PASSO 2: FALHA. RayCast NÃO está colidindo com nada.")

	# --- LÓGICA DE INPUT PARA DEBUG (MOUSE + TECLA Q) ---
	# Checa se a ação "debug_click" (mapeada para a tecla Q) acabou de ser pressionada
	if Input.is_action_just_pressed("debug_click"):
		# Dispara um raio a partir da câmera através do cursor do mouse
		var mouse_pos = get_viewport().get_mouse_position()
		var space_state = get_world_3d().direct_space_state
		var from = camera.project_ray_origin(mouse_pos)
		var to = from + camera.project_ray_normal(mouse_pos) * 1000
		
		var query = PhysicsRayQueryParameters3D.create(from, to)
		var result = space_state.intersect_ray(query)
		
		# Se o raio atingiu algo, verifica se é um dos botões
		if not result.is_empty():
			# A variável 'collider' aqui já é o seu botão Area3D ("GreenBtn" ou "RedBtn")
			var collider = result.collider
			# AQUI ESTÁ A MUDANÇA: Checamos o nome do próprio collider
			if botao_estados.has(collider.name):
				# E usamos o nome do próprio collider
				var nome_do_botao = collider.name 
		
				print("Acionado via Mouse+Q: '", nome_do_botao, "'")
				toggle_botao(nome_do_botao)

# --- FUNÇÕES DE LÓGICA E COMUNICAÇÃO ---

# Inverte o estado de um botão e inicia o envio de dados
func toggle_botao(nome_botao: String):
	botao_estados[nome_botao] = not botao_estados[nome_botao]
	print("Estado do botão '", nome_botao, "' alterado para: ", botao_estados[nome_botao])
	enviar_dados_para_esp32()

# Prepara e envia o estado atual dos botões para o ESP32
func enviar_dados_para_esp32():
	var byte_para_enviar = 0
	
	# Converte os estados booleanos (true/false) em um único byte
	if botao_estados["GreenBtn"]:
		byte_para_enviar |= 1 # Liga o primeiro bit
	if botao_estados["RedBtn"]:
		byte_para_enviar |= 2 # Liga o segundo bit
	if botao_estados["BlueBtn"]:
		byte_para_enviar |= 4 # Liga o 
	
	# Envia o pacote via UDP
	var pacote = PackedByteArray([byte_para_enviar])
	udp_peer.set_dest_address(IP_ESP32, PORTA_ESP32)
	var erro = udp_peer.put_packet(pacote)
	
	if erro != OK:
		print("Falha ao enviar pacote UDP. Erro: ", erro)
	else:
		print("Pacote [", byte_para_enviar, "] enviado para ", IP_ESP32)

extends Node

# --- Referências (Arraste os nós aqui no Inspetor) ---
@export var arm_extractor: Node # Arraste seu nó Skeleton3D aqui
@export var controller_esq: XRController3D
@export var controller_dir: XRController3D

# --- Configuração UDP ---
var udp_peer: PacketPeerUDP
var estados = {"azul": false, "vermelho": false}
var esp_ip = "192.168.4.1"
var port = 4211

func _ready():
	udp_peer = PacketPeerUDP.new()
	udp_peer.set_dest_address(esp_ip, port)
	print("UDP Manager pronto no IP: ", esp_ip)
	
	# Garante que este nó corra no loop de física
	set_physics_process(true)

# --- LÓGICA DE ENVIO DE ÂNGULOS (AGORA NO PHYSICS_PROCESS) ---
func _physics_process(delta):
	# 1. Verifica se o nó do esqueleto foi configurado
	if not arm_extractor:
		return

	# 2. Pega os ângulos calculados pelo script arm_ik_extractor.gd
	var s1_ombro_y = arm_extractor.angulo_ombro.y
	var s2_ombro_x = arm_extractor.angulo_ombro.x
	var s3_cotovelo_x = arm_extractor.angulo_cotovelo.x
	var s4_pulso_y = arm_extractor.angulo_pulso.y

	# 3. Mapeia os ângulos (ex: -90 a 90) para o servo (0 a 180)
	# IMPORTANTE: Você precisará ajustar esses valores de 'remap'
	var servo1 = int(remap(s1_ombro_y, -90, 90, 0, 180))
	var servo2 = int(remap(s2_ombro_x, -90, 90, 0, 180))
	var servo3 = int(remap(s3_cotovelo_x, -90, 90, 0, 180))
	var servo4 = int(remap(s4_pulso_y, -90, 90, 0, 180))

	# 4. Cria o pacote binário (5 bytes)
	var packet = PackedByteArray()
	packet.append(255) # Byte de Cabeçalho (Header)
	packet.append(clamp(servo1, 0, 180))
	packet.append(clamp(servo2, 0, 180))
	packet.append(clamp(servo3, 0, 180))
	packet.append(clamp(servo4, 0, 180))

	# 5. Envia o pacote
	udp_peer.put_packet(packet)

# --- LÓGICA DOS BOTÕES (Seu código original, sem alterações) ---

func _on_left_hand_button_pressed(name: String) -> void:
	if name == "trigger_click":
		toggle_state("vermelho")

func _on_right_hand_button_pressed(name: String) -> void:
	if name == "trigger_click":
		toggle_state("azul")

func toggle_state(cor: String):
	estados[cor] = !estados[cor]
	
	var dados = {
		"led": cor, 
		"estado": estados[cor]
	}
	
	# Pacote de Botão (JSON)
	udp_peer.put_packet(JSON.stringify(dados).to_utf8_buffer())
	print("Botão pressionado! LED ", cor, " -> ", estados[cor])

extends Node

# Não precisamos mais dos exports se você conectou via sinal no Editor,
# mas mantenho aqui caso precise referenciar algo depois.
@export var controller_esq: XRController3D
@export var controller_dir: XRController3D

var udp_peer: PacketPeerUDP
var estados = {"azul": false, "vermelho": false}
var esp_ip = "192.168.4.1"
var port = 4211

func _ready():
	# Apenas inicia o UDP. 
	# Não fazemos conexão de sinais aqui porque você já fez pelo Editor visual.
	udp_peer = PacketPeerUDP.new()
	udp_peer.set_dest_address(esp_ip, port)
	print("Gerenciador de Botões pronto no IP: ", esp_ip)

# --- MÃO ESQUERDA (Vermelho) ---
# Essa é a função que você pediu para usar.
# Certifique-se de que o sinal 'button_pressed' do 'leftHand' está conectado aqui.
func _on_left_hand_button_pressed(name: String) -> void:
	# O nome interno do gatilho quando clica é "trigger_click"
	if name == "trigger_click":
		toggle_state("vermelho")

# --- MÃO DIREITA (Azul) ---
# IMPORTANTE: Vá no nó 'rightHand', aba 'Nó' -> 'button_pressed' 
# e conecte criando essa função abaixo:
func _on_right_hand_button_pressed(name: String) -> void:
	if name == "trigger_click":
		toggle_state("azul")

# --- Lógica de Envio ---
func toggle_state(cor: String):
	estados[cor] = !estados[cor]
	
	var dados = {
		"led": cor, 
		"estado": estados[cor]
	}
	
	udp_peer.put_packet(JSON.stringify(dados).to_utf8_buffer())
	print("Botão pressionado! LED ", cor, " -> ", estados[cor])

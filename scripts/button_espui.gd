extends ColorRect

var estado_azul = false
var estado_vermelho = false

var udp_peer: PacketPeerUDP
# MUDEI AQUI: Voltamos ao IP padrão do Modo AP
var esp_ip = "192.168.4.1" 
var esp_port_botoes = 4211

func _ready():
	$Button_Blue.pressed.connect(_on_button_blue_pressed)
	$Button_Red.pressed.connect(_on_button_red_pressed)
	
	udp_peer = PacketPeerUDP.new()
	udp_peer.set_dest_address(esp_ip, esp_port_botoes)
	print("UDP (Botões) pronto. Mirando no IP: ", esp_ip, " Porta: ", esp_port_botoes)

func _on_button_blue_pressed():
	estado_azul = !estado_azul
	send_request("azul", estado_azul)

func _on_button_red_pressed():
	estado_vermelho = !estado_vermelho
	send_request("vermelho", estado_vermelho)

func send_request(led_color, new_state):
	var body_data = {"led": led_color, "estado": new_state}
	var body_json = JSON.stringify(body_data)
	
	var bytes = body_json.to_utf8_buffer()
	udp_peer.put_packet(bytes)
	
	$Label.text = "Comando '" + led_color + "' enviado!"
	print("Pacote UDP (Botão) enviado: ", body_json)

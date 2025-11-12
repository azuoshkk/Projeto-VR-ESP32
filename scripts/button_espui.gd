extends ColorRect

var request_start_time_msec = 0

var estado_azul = false
var estado_vermelho = false

func _ready():
	# Conecta os sinais aos botões pelos seus nomes exatos
	$Button_Blue.pressed.connect(_on_button_blue_pressed)
	$Button_Red.pressed.connect(_on_button_red_pressed)
	$HTTPRequest.request_completed.connect(_on_request_completed)

func _on_button_blue_pressed():
	# Inverte o estado azul e chama a função de envio
	estado_azul = !estado_azul
	send_request("azul", estado_azul)

func _on_button_red_pressed():
	# Inverte o estado vermelho e chama a função de envio
	estado_vermelho = !estado_vermelho
	send_request("vermelho", estado_vermelho)

func send_request(led_color, new_state):
	# Cria o JSON: {"led": "azul", "estado": true}
	var body_data = {"led": led_color, "estado": new_state}
	var body_json = JSON.stringify(body_data)
	
	var url = "http://192.168.4.1/toggle"
	var headers = [ "Content-Type: application/json" ]

	# Marca o tempo de início
	request_start_time_msec = Time.get_ticks_msec()
	
	# Atualiza o label
	$Label.text = "Enviando..."
	
	# Envia a requisição
	$HTTPRequest.request(url, headers, HTTPClient.METHOD_POST, body_json)
	
	print("Enviando para o ESP: ", body_json)

func _on_request_completed(result, response_code, headers, body):
	# Calcula o tempo final
	var response_time_msec = Time.get_ticks_msec()
	
	var delay = response_time_msec - request_start_time_msec
	
	# Mostra o resultado no label
	if result != HTTPRequest.RESULT_SUCCESS:
		$Label.text = "Falha na conexão!"
		return

	if response_code == 200:
		$Label.text = "Delay: " + str(delay) + " ms"
		print("Sucesso! Latência: ", delay, " ms")
	else:
		$Label.text = "Erro no ESP! (" + str(response_code) + ")"
		print("Erro! O ESP32 respondeu com código: ", response_code)

extends Node3D

# Esta função é chamada automaticamente quando o nó entra na cena.
func _ready():
	# Tenta encontrar a interface de XR chamada "OpenXR".
	# Esta interface só existe se os plugins OpenXR estiverem ativos.
	var xr_interface = XRServer.find_interface("OpenXR")

	# Verifica se a interface foi encontrada e se já foi inicializada.
	if xr_interface and xr_interface.is_initialized():
		print("SUCESSO: A interface OpenXR já está inicializada.")
		# Diz para a janela principal do jogo (viewport) começar a usar o modo XR.
		get_viewport().use_xr = true
	
	# Se a interface foi encontrada, mas ainda não está inicializada...
	elif xr_interface:
		print("AVISO: Interface OpenXR encontrada. Tentando inicializar agora...")
		# Nós a inicializamos manualmente.
		var success = xr_interface.initialize()
		if success:
			# E então dizemos para a janela de jogo usar o modo VR.
			get_viewport().use_xr = true
			print("Interface OpenXR inicializada com sucesso.")
		else:
			printerr("ERRO: Falha ao inicializar a interface OpenXR.")
	
	# Se a interface nem foi encontrada...
	else:
		printerr("ERRO CRÍTICO: Interface OpenXR não encontrada. Verifique se os plugins estão ativados em Project Settings.")

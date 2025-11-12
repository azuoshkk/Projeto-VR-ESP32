@tool
extends Node3D # Anexe este script a um nó 3D principal

var xr_interface: XRInterface

func _ready():
	# 1. Encontra a interface OpenXR
	xr_interface = XRServer.find_interface("OpenXR")
	
	CameraServer.monitoring_feeds = true
	var feeds = CameraServer.feeds()
	
	print(feeds)
	
	if not xr_interface:
		printerr("ERRO CRÍTICO: Interface OpenXR não encontrada. O plugin está instalado?")
		return

	# 2. Verifica se já está inicializada
	if xr_interface.is_initialized():
		# Se já estiver, ligamos o VR imediatamente
		_start_xr_and_passthrough()
	else:
		# 3. Se não, tentamos inicializar AGORA.
		#    O método initialize() retorna 'true' se der certo.
		var success = xr_interface.initialize()
		if success:
			# Se funcionou, ligamos o VR
			_start_xr_and_passthrough()
		else:
			printerr("ERRO: Falha ao inicializar a interface OpenXR.")

func _start_xr_and_passthrough():
	# Esta é a função que faz a mágica
	
	# 4. LIGA O VR! (Corrige o "No viewport marked")
	get_viewport().use_xr = true
	
	print("Sucesso: Viewport.use_xr = true. Tentando ligar o Passthrough...")
	
	# 5. LIGA O PASSTHROUGH
	#    Se o Passthrough estiver desligado nas configs, ISSO PODE CRASHAR.
	if xr_interface.is_passthrough_supported():
		xr_interface.start_passthrough()
		print("Passthrough iniciado.")
	else:
		printerr("AVISO: Passthrough não suportado por esta interface.")
		
func _exit_tree():
	# 6. Limpeza ao fechar
	if xr_interface and xr_interface.is_passthrough_active():
		xr_interface.stop_passthrough()

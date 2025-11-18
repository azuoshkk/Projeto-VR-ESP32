extends Node3D

@export var camera_head: XRCamera3D
@export var offset_altura: float = 1.6 # Altura média do pescoço ao chão

func _process(delta):
	if !camera_head: return
	
	# 1. POSIÇÃO: O corpo segue a posição X e Z da câmera (chão), mas mantém altura fixa
	# Isso evita que o boneco voe se você pular ou agachar rápido demais
	var target_pos = camera_head.global_position
	target_pos.y = global_position.y # Mantém a altura original do pé do boneco
	
	# Move suavemente para onde o jogador está
	global_position = global_position.lerp(target_pos, 10 * delta)
	
	# 2. ROTAÇÃO: O corpo gira para olhar na mesma direção da câmera (apenas eixo Y)
	var camera_rot = camera_head.global_rotation
	var target_rot = Vector3(0, camera_rot.y, 0) # Ignora olhar pra cima/baixo
	
	# Interpola a rotação (Slerp) para não ser robótico demais
	rotation = rotation.slerp(target_rot, 10 * delta)

extends Skeleton3D

# --- NOVO: Referência ao nó do IK ---
# Arraste o nó 'IK_Braco_Esquerdo' para cá no Inspector
@export var ik_node: SkeletonIK3D 

@export var osso_ombro_nome: StringName = &"mixamorig8_LeftShoulder"
@export var osso_cotovelo_nome: StringName = &"mixamorig8_LeftForeArm"
@export var osso_pulso_nome: StringName = &"mixamorig8_LeftHand"

var id_ombro: int
var id_cotovelo: int
var id_pulso: int

var angulo_ombro: Vector3
var angulo_cotovelo: Vector3
var angulo_pulso: Vector3

func _ready():
	# 1. INICIA O IK (A Mágica acontece aqui)
	if ik_node:
		ik_node.start()
	else:
		print("ERRO: Nó IK não atribuído no Inspector!")

	# Encontra o ID de cada osso pelo nome
	id_ombro = find_bone(osso_ombro_nome)
	id_cotovelo = find_bone(osso_cotovelo_nome)
	id_pulso = find_bone(osso_pulso_nome)

func _process(delta):
	# Pega a rotação ATUAL (pose) de cada osso
	var rot_ombro_quat = get_bone_pose_rotation(id_ombro)
	var rot_cotovelo_quat = get_bone_pose_rotation(id_cotovelo)
	var rot_pulso_quat = get_bone_pose_rotation(id_pulso)
	
	# Converte para Graus
	angulo_ombro = rot_ombro_quat.get_euler() * (180.0 / PI)
	angulo_cotovelo = rot_cotovelo_quat.get_euler() * (180.0 / PI)
	angulo_pulso = rot_pulso_quat.get_euler() * (180.0 / PI)
	
	# Debug (opcional)
	# print("Ombro: ", angulo_ombro)

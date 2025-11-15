extends Skeleton3D

# Nomes dos ossos que configuramos no IK
@export var osso_ombro_nome: StringName = &"mixamorig8_LeftShoulder"
@export var osso_cotovelo_nome: StringName = &"mixamorig8_LeftForeArm"
@export var osso_pulso_nome: StringName = &"mixamorig8_LeftHand"

# IDs dos ossos (números inteiros)
private var id_ombro: int
private var id_cotovelo: int
private var id_pulso: int

# Variáveis para guardar os ângulos (em graus)
var angulo_ombro: Vector3
var angulo_cotovelo: Vector3
var angulo_pulso: Vector3

func _ready():
	# Encontra o ID de cada osso pelo nome
	id_ombro = find_bone(osso_ombro_nome)
	id_cotovelo = find_bone(osso_cotovelo_nome)
	id_pulso = find_bone(osso_pulso_nome)

func _process(delta):
	# 1. Pega a rotação ATUAL (pose) de cada osso
	# O IK_Braco_Esquerdo está modificando estas rotações em tempo real
	var rot_ombro_quat = get_bone_pose_rotation(id_ombro)
	var rot_cotovelo_quat = get_bone_pose_rotation(id_cotovelo)
	var rot_pulso_quat = get_bone_pose_rotation(id_pulso)
	
	# 2. Converte de Quaternion (complexo) para Ângulos Euler (XYZ) em graus
	# O ESP32 e os servos entendem graus (0-180)
	angulo_ombro = rot_ombro_quat.get_euler() * (180.0 / PI)
	angulo_cotovelo = rot_cotovelo_quat.get_euler() * (180.0 / PI)
	angulo_pulso = rot_pulso_quat.get_euler() * (180.0 / PI)
	
	# 3. Exibe no console para teste (remova depois)
	# O seu "Ombro" (2 servos) usará angulo_ombro.y (rotação) e angulo_ombro.x (elevação)
	# O seu "Cotovelo" (1 servo) usará angulo_cotovelo.x (dobra)
	print("Ombro (Y,X): ", Vector2(angulo_ombro.y, angulo_ombro.x))
	print("Cotovelo (X): ", angulo_cotovelo.x)
	print("Pulso: ", angulo_pulso)

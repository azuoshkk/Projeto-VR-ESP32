extends Node3D

# ALVOS
@export var target_node: Node3D # Arraste seu Controller/Mão aqui

# PEÇAS DO ROBÔ (Arraste os nós da estrutura que criamos)
@export var ombro_eixo: Node3D
@export var cotovelo_eixo: Node3D

# MEDIDAS DO SEU ROBÔ (Em metros, ajuste para ficar igual ao real)
@export var comprimento_braco: float = 0.3
@export var comprimento_antebraco: float = 0.3

# VARIÁVEIS PARA O ESP32
var angulo_base: float
var angulo_ombro: float
var angulo_cotovelo: float

func _process(delta):
	if !target_node: return
	
	# 1. ONDE ESTÁ O ALVO RELATIVO AO OMBRO?
	# Converte a posição global do alvo para o espaço local da base
	var local_target = to_local(target_node.global_position)
	var x = local_target.x
	var y = local_target.y
	var z = local_target.z
	
	# 2. GIRA A BASE (Azimute / Servo 1)
	# A base apenas aponta para o alvo na horizontal
	angulo_base = atan2(x, z)
	ombro_eixo.rotation.y = angulo_base
	
	# 3. CALCULA O TRIÂNGULO (Elevação e Cotovelo)
	# Distância horizontal até o alvo
	var dist_horizontal = Vector2(x, z).length()
	# Distância direta do ombro ao alvo
	var dist_total = local_target.length()
	
	# Limita a distância para o braço não "estourar" se o alvo estiver longe
	dist_total = clamp(dist_total, 0.01, comprimento_braco + comprimento_antebraco - 0.01)
	
	# LEI DOS COSSENOS (A matemática que substitui o SkeletonIK)
	var a = comprimento_braco
	var b = comprimento_antebraco
	var c = dist_total
	
	# Ângulo do Cotovelo (Beta)
	var cos_angle_cotovelo = (a*a + b*b - c*c) / (2 * a * b)
	# Proteção matemática
	cos_angle_cotovelo = clamp(cos_angle_cotovelo, -1.0, 1.0)
	var angle_cotovelo_rad = acos(cos_angle_cotovelo)
	
	# Ângulo do Ombro (Alpha - parte interna)
	var cos_angle_ombro_tri = (a*a + c*c - b*b) / (2 * a * c)
	cos_angle_ombro_tri = clamp(cos_angle_ombro_tri, -1.0, 1.0)
	var angle_ombro_tri = acos(cos_angle_ombro_tri)
	
	# Elevação total necessária para olhar para o alvo
	var angle_elevacao_alvo = atan2(y, dist_horizontal)
	
	# Aplica rotações (Ajuste os sinais + ou - dependendo de como montou os eixos)
	angulo_ombro = angle_elevacao_alvo + angle_ombro_tri
	angulo_cotovelo = angle_cotovelo_rad - PI # Ajuste para dobrar para o lado certo
	
	# Aplica visualmente
	ombro_eixo.rotation.x = -angulo_ombro # O negativo inverte se precisar
	cotovelo_eixo.rotation.x = angulo_cotovelo
	
	# 4. CONVERTE PARA GRAUS (Para enviar pro ESP32)
	var grau_base = rad_to_deg(angulo_base)
	var grau_ombro = rad_to_deg(angulo_ombro)
	var grau_cotovelo = rad_to_deg(angulo_cotovelo)
	
	# Debug
	# print("Base: ", int(grau_base), " Ombro: ", int(grau_ombro), " Cotovelo: ", int(grau_cotovelo))

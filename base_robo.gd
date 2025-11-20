extends Node3D

# --- ENTRADAS ---
@export var target_hand: Node3D
@export var user_shoulder: Node3D

# --- PEÇAS DO ROBÔ ---
@export var base_giro: Node3D
@export var ombro_eixo: Node3D
@export var cotovelo_eixo: Node3D

# --- MEDIDAS ---
@export var tamanho_braco: float = 0.3
@export var tamanho_antebraco: float = 0.3

# --- CALIBRAÇÃO ---
@export_range(-180, 180) var offset_cotovelo_graus: float = -180.0 

# --- SAÍDA PARA ESP32 ---
var angulo_base_graus: float
var angulo_ombro_graus: float
var angulo_cotovelo_graus: float

func _process(delta):
	if !target_hand or !user_shoulder: return
	
	# 1. CÁLCULO DO VETOR
	var vetor_movimento = target_hand.global_position - user_shoulder.global_position
	var vetor_local = to_local(global_position + vetor_movimento)
	
	# 2. DISTÂNCIA
	var dist_total = vetor_local.length()
	
	# Debug (Opcional)
	# print("Distância Ombro-Mão: ", snapped(dist_total, 0.01), "m")
	
	# Limita o alcance para não estourar a matemática
	dist_total = clamp(dist_total, 0.01, tamanho_braco + tamanho_antebraco - 0.01)
	
	# 3. MATEMÁTICA DO TRIÂNGULO (Lei dos Cossenos)
	var a = tamanho_braco
	var b = tamanho_antebraco
	var c = dist_total
	
	var cos_cotovelo = (a*a + b*b - c*c) / (2 * a * b)
	var ang_cotovelo_rad = acos(clamp(cos_cotovelo, -1.0, 1.0))
	
	# Cálculos do Ombro
	var x = vetor_local.x
	var y = vetor_local.y
	var z = vetor_local.z
	
	var angulo_y = atan2(x, z) # Base
	var dist_horizontal = Vector2(x, z).length()
	var ang_elevacao = atan2(y, dist_horizontal)
	
	var cos_ombro_tri = (a*a + c*c - b*b) / (2 * a * c)
	var ang_ombro_interno = acos(clamp(cos_ombro_tri, -1.0, 1.0))
	
	var resultado_ombro = ang_elevacao + ang_ombro_interno
	
	# --- 4. CÁLCULO FINAL DO COTOVELO COM TRAVA ---
	var offset_rad = deg_to_rad(offset_cotovelo_graus)
	var cotovelo_final = ang_cotovelo_rad + offset_rad
	
	# !!! AQUI ESTÁ A CORREÇÃO !!!
	# Impede que o ângulo seja menor que 0 (dobrar para trás).
	# Se o braço ficar TRAVADO RETO e não dobrar, troque 'max' por 'min'.
	cotovelo_final = min(cotovelo_final, 0.0)
	
	# 5. APLICAÇÃO NOS NÓS
	base_giro.rotation.y = angulo_y
	ombro_eixo.rotation.x = -resultado_ombro 
	cotovelo_eixo.rotation.x = cotovelo_final 
	
	# 6. ATUALIZA VARIÁVEIS PARA O ESP32
	# (Usamos cotovelo_final aqui para o robô físico também respeitar a trava)
	angulo_base_graus = rad_to_deg(angulo_y)
	angulo_ombro_graus = rad_to_deg(resultado_ombro)
	angulo_cotovelo_graus = rad_to_deg(cotovelo_final)

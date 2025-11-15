extends ColorRect


const AR_MODE_SCENE_PATH = "res://tscn/ARMode.tscn" 
const VR_MODE_SCENE_PATH = "res://tscn/VRMode.tscn"

func _on_arbutton_pressed():
	print("Carregando cena AR Mode (Passthrough)...")
	
	if FileAccess.file_exists(AR_MODE_SCENE_PATH):
		get_tree().change_scene_to_file(AR_MODE_SCENE_PATH)
		print("Cena AR Mode carregada.")
	else:
		print("ERRO: O arquivo de cena AR Mode não foi encontrado em: ", AR_MODE_SCENE_PATH)
		
func _on_vrbutton_pressed():
	print("Carregando cena VR Mode (Imersivo)...")
	
	if FileAccess.file_exists(VR_MODE_SCENE_PATH):
		get_tree().change_scene_to_file(VR_MODE_SCENE_PATH)
		print("Cena VR Mode carregada.")
	else:
		print("ERRO: O arquivo de cena VR Mode não foi encontrado em: ", VR_MODE_SCENE_PATH)

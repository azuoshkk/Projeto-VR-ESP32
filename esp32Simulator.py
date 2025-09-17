import socket

HOST = "0.0.0.0"
PORT = 8888

sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)

sock.bind((HOST, PORT))

print(f"---Simulador de Esp Iniciado----")
print(f"[*] Escutando em {HOST}:{PORT}")
print(f"Aguardando pacote Godot...Ctrl + C para finalizar.")

try:
    while True:
        data, addr = sock.recvfrom(1024)

        print(f"\n----Pacote Recebido---")
        print(f"De: {addr}")

        byteRecebido = data[0]
        print(f"Byte recebido: {byteRecebido}:(Binário: {byteRecebido:08b})")

        greenBtnLigado = (byteRecebido & 1) != 0
        redBtnLigado = (byteRecebido & 2) != 0
        blueBtnLigado = (byteRecebido & 4) != 0

        print(f"  - Estado do Botão Verde: {'LIGADO' if greenBtnLigado else 'DESLIGADO'}")
        print(f"  - Estado do Botão Vermelho: {'LIGADO' if redBtnLigado else 'DESLIGADO'}")
        print(f"  - Estado do Botão Azul: {'LIGADO' if blueBtnLigado else 'DESLIGADO'}")

except KeyboardInterrupt:
    print("\n--- Simulador encerrado. ---")
finally:
    sock.close()


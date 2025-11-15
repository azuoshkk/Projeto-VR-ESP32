Controle Robótico Remoto via Godot e ESP32

Projeto de TCC para o curso de Ciências da Computação (Universidade Jorge Amado, 2025). O objetivo é a teleoperação de uma garra robótica (5 GDL) com Realidade Virtual (Godot Engine) e um microcontrolador ESP32, focado em comunicação de baixíssima latência.

Sobre o Projeto

O problema central da teleoperação (como em cirurgias remotas) é a latência. Abordagens tradicionais (como APIs em nuvem) podem introduzir atrasos de segundos, tornando o controle em tempo real inviável.

Este projeto investiga, implementa e valida uma arquitetura de comunicação local e direta para resolver esse problema.

V1.0 (Firebase): Latência > 2000ms. Inviável.

V3.0 (HTTP Local): Latência de 70ms a 218ms. Funcional, mas instável.

V4.0 (UDP Local): Latência < 20ms. Ideal.

O sistema atual (V4.0) utiliza o Meta Quest 2 (executando um app Godot) para capturar a posição (XYZ) e rotação (ABC) das mãos do operador. Esses dados são enviados via UDP para um ESP32, que atua como o cérebro da garra robótica.

Arquitetura da V4.0 (Atual)

[ Meta Quest 2 (Godot Engine) ]               [ ESP32 (Hardware) ]
  |                                               |
  |   <------ Rede Wi-Fi Local (ESP32 AP) ------>   |
  |   (IP: 192.168.4.1)                           |
  |                                               |
  +-- Envio de Posição (UDP / Porta 4210) -->       |
  |   (JSON: {left: {pos, rot}, right: {pos, rot}}) |
  |                                               |
  +-- Envio de Comandos (UDP / Porta 4211) -->      |
  |   (JSON: {led: "cor", estado: true})           |
  |   (Acionado pelos gatilhos dos controles)     |


Status Atual (Semana 6 / V4.0)

O projeto está em fase de integração da V4.0.

1. Godot (Meta Quest 2)

[X] Envio de dados de Posição (XYZ) e Rotação (ABC) das duas mãos.

[X] Comunicação migrada para UDP (Portas 4210 e 4211).

[X] Latência de envio de pacotes < 20ms (operando a 20Hz).

[X] Input de botões via gatilhos (sem necessidade de mirar).

2. ESP32 (Hardware)

[X] Operando como Access Point (AP) Wi-Fi (Rede: Rede_ESP_VR).

[!] PENDENTE: O firmware atual no repositório (/firmware_esp32 ou Anexo B) ainda é da V3.0 (baseado em WebServer.h para HTTP). Ele precisa ser atualizado para usar WiFiUDP.h e receber os pacotes V4.0 (tracking e botões).

Tecnologias Utilizadas

VR/Interface: Godot Engine 4.2 (com Godot XR Tools)

Hardware: ESP32-DevKitC V4

Comunicação: Protocolo UDP

Linguagens: GDScript (Godot) e C++/Arduino (ESP32)

Como Usar (Instruções da V4.0)

Atenção: O firmware do ESP32 para UDP (V4.0) ainda precisa ser implementado (veja Roadmap). As instruções abaixo presumem que o firmware UDP está pronto.

1. Hardware (ESP32)

Abra o projeto do firmware (.ino) na IDE Arduino (configurado para ESP32).

(Quando pronto) O firmware deve criar o Access Point Rede_ESP_VR.

Flashe o ESP32 e ligue-o.

2. VR (Godot / Meta Quest 2)

Abra o projeto na Godot Engine 4.2.

Certifique-se de que os scripts RootNode.gd e GerenciarLed.gd estão apontando para o IP correto do ESP32 (IP Padrão do AP: 192.168.4.1).

Exporte o projeto para Android (.apk), garantindo que o plugin "OpenXR" e "Godot XR Tools" esteja ativado.

Instale o .apk no Meta Quest 2 (via SideQuest ou ADB).

No Meta Quest 2, conecte-se à rede Wi-Fi Rede_ESP_VR.

Execute a aplicação. Os movimentos e gatilhos serão enviados ao ESP32.

Roadmap (Próximos Passos)

[ ] Firmware ESP32 (Prioridade): Atualizar o firmware para WiFiUDP.h, recebendo e processando os pacotes JSON das portas 4210 (tracking) e 4211 (botões).

[ ] Cinemática Inversa (CI): Implementar a "Resolução 2" (cálculo no Godot). Converter os dados de XYZ/ABC recebidos do controle nos 5 ângulos de servo necessários para a garra.

[ ] Protótipo Físico: Reconstruir a garra (o protótipo V1 era de palitos) com servos e materiais robustos.

[ ] Streaming de Câmera: Investigar o envio de vídeo de uma câmera (na garra) de volta para uma tela (viewport) no Godot.

[ ] Modo Híbrido AR/VR: Implementar a troca entre visão AR (pass-through) e VR (câmera) para operação a longa distância.

Autores (Equipe TCC)

Azuosh (Zush)

Guilherme Costa Andrade

João Felipe da Silva Pinto Santana

Luisa Sardinha dos Santos Silva

Pedro Alexandre Costa Coutinho

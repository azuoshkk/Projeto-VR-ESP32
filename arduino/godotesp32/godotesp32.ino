#include <Arduino.h>
#include <WiFi.h>
#include <WiFiUdp.h>
#include <Wire.h>
#include <Adafruit_PWMServoDriver.h>

// --- CONFIGURAÇÃO DA REDE ---
const char* ssid = "Rede_ESP_VR";
const char* password = "senha12345";

// --- CONFIGURAÇÃO DO UDP ---
WiFiUDP udp;
unsigned int localUdpPort = 4211;
byte udpBuffer[256]; 

// --- CONFIGURAÇÃO DO MÓDULO PWM ---
Adafruit_PWMServoDriver pwm = Adafruit_PWMServoDriver();

// Calibragem (Baseada nos seus testes)
#define PULSO_MIN  150  
#define PULSO_MAX  480  

// Mapeamento dos Canais no Módulo (0 a 3)
#define CANAL_BASE      0 
#define CANAL_OMBRO     1
#define CANAL_COTOVELO  2
#define CANAL_PULSO     3

void setup() {
  Serial.begin(115200);

  // --- Inicializa Módulo PWM ---
  pwm.begin();
  pwm.setPWMFreq(50); // 50Hz para servos analógicos

  // --- Iniciar WiFi (AP Mode) ---
  Serial.println("\nIniciando Ponto de Acesso...");
  WiFi.softAP(ssid, password);
  IPAddress myIP = WiFi.softAPIP();
  Serial.print("AP Criado! IP do ESP32: ");
  Serial.println(myIP);

  // --- Iniciar UDP ---
  if (udp.begin(localUdpPort)) {
    Serial.print("Escutando UDP na porta: ");
    Serial.println(localUdpPort);
  } else {
    Serial.println("Erro ao iniciar UDP!");
  }
}

// Função auxiliar para mover o servo suavemente
void moverServo(int canal, int angulo) {
  // Proteção de limites (0-180)
  if (angulo < 0) angulo = 0;
  if (angulo > 180) angulo = 180;

  // Converte ângulo em pulso do módulo PCA9685
  int pulso = map(angulo, 0, 180, PULSO_MIN, PULSO_MAX);
  pwm.setPWM(canal, 0, pulso);
}

void loop() {
  // Verifica se chegou dados
  int packetSize = udp.parsePacket();
  
  if (packetSize > 0) {
    udp.read(udpBuffer, 255);
    
    // --- Rota de Baixa Latência (Binário do Godot) ---
    // O Godot envia [255, angulo1, angulo2, angulo3, angulo4]
    if (packetSize >= 5 && udpBuffer[0] == 255) {
      
      // Pega os valores diretos do pacote
      int anguloBase     = udpBuffer[1];
      int anguloOmbro    = udpBuffer[2];
      int anguloCotovelo = udpBuffer[3];
      int anguloPulso    = udpBuffer[4];

      // Envia para o Módulo PWM instantaneamente
      moverServo(CANAL_BASE,     anguloBase);
      moverServo(CANAL_OMBRO,    anguloOmbro);
      moverServo(CANAL_COTOVELO, anguloCotovelo);
      moverServo(CANAL_PULSO,    anguloPulso);
    }
  }
}
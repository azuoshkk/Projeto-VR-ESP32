#include <WiFi.h>
#include <WiFiUdp.h>        // <--- MUDEI: Usamos UDP, não WebServer
#include <Servo.h>          // <--- NOVO: Para controlar os servos
#include <ArduinoJson.h>    // Para os botões

// --- Configuração da Rede (do seu código) ---
const char* ssid = "Rede_ESP_VR";
const char* password = "senha12345";

// --- Configuração do UDP ---
WiFiUDP udp;
unsigned int localUdpPort = 4211; // Porta que o Godot está enviando

// --- Pinos (do seu código) ---
const int blueLedPin = 15;
const int redLedPin = 17;

// --- Pinos dos Servos (!!! ATUALIZE AQUI !!!) ---
// !!! ATENÇÃO: Mude estes pinos para os GPIOs corretos dos seus 4 servos !!!
#define SERVO_OMBRO_Y_PIN   13 // Servo 1 (Base)
#define SERVO_OMBRO_X_PIN   12 // Servo 2 (Elevação)
#define SERVO_COTOVELO_PIN  14 // Servo 3 (Cotovelo)
#define SERVO_PULSO_PIN     27 // Servo 4 (Pulso)

// --- Objetos dos Servos ---
Servo servoOmbroY;
Servo servoOmbroX;
Servo servoCotovelo;
Servo servoPulso;

// --- Buffer ---
byte udpBuffer[256]; 

void setup() {
  Serial.begin(115200);

  // --- Pinos dos LEDs (do seu código) ---
  pinMode(blueLedPin, OUTPUT);
  pinMode(redLedPin, OUTPUT);
  digitalWrite(blueLedPin, LOW); // Garante que começam desligados
  digitalWrite(redLedPin, LOW);

  // --- Conectar Servos ---
  servoOmbroY.attach(SERVO_OMBRO_Y_PIN);
  servoOmbroX.attach(SERVO_OMBRO_X_PIN);
  servoCotovelo.attach(SERVO_COTOVELO_PIN);
  servoPulso.attach(SERVO_PULSO_PIN);

  // --- Iniciar WiFi (do seu código) ---
  Serial.println("Iniciando Modo Access Point (AP)...");
  WiFi.softAP(ssid, password);
  IPAddress myIP = WiFi.softAPIP();
  Serial.print("AP iniciado! Conecte-se em: ");
  Serial.println(ssid);
  Serial.print("IP do ESP32 (deve ser 192.168.4.1): ");
  Serial.println(myIP);

  // --- Iniciar UDP ---
  if (udp.begin(localUdpPort)) {
    Serial.print("Servidor UDP ouvindo na porta: ");
    Serial.println(localUdpPort);
  } else {
    Serial.println("Falha ao iniciar UDP");
  }
}

// O loop() agora é nosso roteador de pacotes
void loop() {
  int packetSize = udp.parsePacket();
  
  // Se um pacote UDP chegou...
  if (packetSize > 0) {
    
    // Lê o pacote para o buffer
    int len = udp.read(udpBuffer, 255);
    
    // --- 1. Rota de Baixa Latência (Ângulos) ---
    // Checa o Header (255) e o tamanho exato (5 bytes)
    if (packetSize == 5 && udpBuffer[0] == 255) {
      
      // Pacote de ângulo (binário)
      // udpBuffer[1] = servo1
      // udpBuffer[2] = servo2
      // ...
      
      servoOmbroY.write(udpBuffer[1]);
      servoOmbroX.write(udpBuffer[2]);
      servoCotovelo.write(udpBuffer[3]);
      servoPulso.write(udpBuffer[4]);
    }
    
    // --- 2. Rota de Botões (JSON) ---
    // Checa se o primeiro caractere é '{'
    else if (udpBuffer[0] == '{') {
      
      // Pacote de LED (JSON)
      udpBuffer[len] = '\0'; // Adiciona terminador nulo para o parser
      
      StaticJsonDocument<100> doc;
      DeserializationError error = deserializeJson(doc, udpBuffer);

      if (error) {
        Serial.print("Falha no parse do JSON: ");
        Serial.println(error.c_str());
        return;
      }

      const char* led = doc["led"];
      bool estado = doc["estado"];

      if (strcmp(led, "azul") == 0) {
        digitalWrite(blueLedPin, estado);
      } else if (strcmp(led, "vermelho") == 0) {
        digitalWrite(redLedPin, estado);
      }
    }
  }
}
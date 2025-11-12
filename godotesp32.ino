#include <WiFi.h>
#include <WebServer.h>
#include <ArduinoJson.h>

const char* ssid = "Rede_ESP_VR";
const char* password = "senha12345";

const int blueLedPin = 15;
const int redLedPin = 17;

WebServer server(80);

bool blueLed = false;
bool redLed = false;

void handleToggle() {
  if (!server.hasArg("plain")) {
    server.send(400, "text/plain", "ERRO: Faltando corpo da requisição.");
    return;
  }

  String body = server.arg("plain");
  Serial.print("Dados recebidos: ");
  Serial.println(body);

  JsonDocument doc;
  DeserializationError error = deserializeJson(doc, body);

  if (error) {
    server.send(400, "text/plain", "ERRO: JSON inválido.");
    return;
  }

  // Verifica se o JSON tem as chaves "led" e "estado"
  if (doc.containsKey("led") && doc.containsKey("estado")) {
    
    const char* led_color = doc["led"];
    bool new_state = doc["estado"];

    // Compara a string recebida para decidir qual LED alterar
    if (strcmp(led_color, "azul") == 0) {
      blueLed = new_state;
      digitalWrite(blueLedPin, blueLed);
      Serial.print("Novo estado do 'blueLed': ");
      Serial.println(blueLed);
      
    } else if (strcmp(led_color, "vermelho") == 0) {
      redLed = new_state;
      digitalWrite(redLedPin, redLed);
      Serial.print("Novo estado do 'redLed': ");
      Serial.println(redLed);
      
    } else {
      server.send(400, "text/plain", "ERRO: Cor de LED desconhecida.");
      return;
    }

    server.send(200, "text/plain", "OK, estado atualizado.");

  } else {
    server.send(400, "text/plain", "ERRO: JSON com chaves inválidas.");
  }
}

void setup() {
  Serial.begin(115200);
  
  pinMode(blueLedPin, OUTPUT);
  pinMode(redLedPin, OUTPUT);
  
  digitalWrite(blueLedPin, blueLed);
  digitalWrite(redLedPin, redLed);

  Serial.println("Iniciando Modo Access Point (AP)...");
  
  WiFi.softAP(ssid, password);

  IPAddress myIP = WiFi.softAPIP();
  Serial.print("AP iniciado! Conecte-se em: ");
  Serial.println(ssid);
  Serial.print("IP do ESP32: ");
  Serial.println(myIP);

  server.on("/toggle", HTTP_POST, handleToggle);
  
  server.begin();
  Serial.println("Servidor web iniciado. Aguardando comandos...");
}

void loop() {
  server.handleClient();
}
#include <ESP32Servo.h>
// --- Definição dos Pinos (Conecte os fios laranjas aqui) ---
int pinoServoBase = 16;
int pinoServoOmbro = 17;
int pinoServoCotovelo = 14;
int pinoServoGarra = 15;

// --- Criação dos Objetos Servo ---
Servo servoBase;
Servo servoOmbro;
Servo servoCotovelo;
Servo servoGarra;

// Intervalos min/max em microssegundos (padrão do SG90 é geralmente 500-2400)
int minPulse = 500;  // Posição 0 graus
int maxPulse = 2400; // Posição 180 graus

void setup() {
  // Inicia a comunicação Serial para o "Controle Remoto"
  Serial.begin(115200);
  Serial.println("--- Controle de Braço Robótico (4-DOF) ---");

  // "Anexa" cada servo ao seu pino com as configurações de pulso
  servoBase.attach(pinoServoBase, minPulse, maxPulse);
  servoOmbro.attach(pinoServoOmbro, minPulse, maxPulse);        
  servoCotovelo.attach(pinoServoCotovelo, minPulse, maxPulse);  
  servoGarra.attach(pinoServoGarra, minPulse, maxPulse);        

  // --- Posição Inicial (Home) ---
  Serial.println("Definindo posição inicial...");
  servoBase.write(90);      // Centralizado
  servoOmbro.write(90);     // Em pé
  servoCotovelo.write(90);  // Em L
  servoGarra.write(0);      // Aberta ou fechada (depende da sua montagem)

  Serial.println("Sistema pronto!");
  Serial.println("Envie comandos no formato: NOME ANGULO");
  Serial.println("Exemplos: 'base 90', 'ombro 45', 'garra 180'");
}

void loop() {
  // Verifica se há dados chegando pela Serial
  if (Serial.available() > 0) {
    
    // Lê o nome do servo até encontrar um espaço (ex: lê "base" de "base 90")
    String nomeServo = Serial.readStringUntil(' ');
    nomeServo.trim(); // Remove espaços extras ou quebras de linha

    // Verifica se ainda tem dados (o número do ângulo)
    if (Serial.available() > 0) {
      
      // Lê o número inteiro que vem depois (o ângulo)
      int angulo = Serial.parseInt();

      // Verifica qual servo deve mover e aplica o ângulo
      if (nomeServo == "base") {
        servoBase.write(angulo);
        Serial.print(">> Base movida para: ");
        Serial.println(angulo);
        
      } else if (nomeServo == "ombro") {
        servoOmbro.write(angulo);
        Serial.print(">> Ombro movido para: ");
        Serial.println(angulo);
        
      } else if (nomeServo == "cotovelo") {
        servoCotovelo.write(angulo);
        Serial.print(">> Cotovelo movido para: ");
        Serial.println(angulo);
        
      } else if (nomeServo == "garra") {
        servoGarra.write(angulo);
        Serial.print(">> Garra movida para: ");
        Serial.println(angulo);
        
      } else {
        Serial.println("Erro: Nome do servo incorreto. Use: base, ombro, cotovelo ou garra.");
      }
    }
    
    // Limpa qualquer "lixo" que tenha sobrado no buffer serial (como novas linhas)
    while (Serial.available() > 0) {
      Serial.read();
    }
  }
}
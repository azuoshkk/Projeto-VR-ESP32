#include <Arduino.h>
#include <Wire.h>
#include <Adafruit_PWMServoDriver.h>

Adafruit_PWMServoDriver pwm = Adafruit_PWMServoDriver();

// --- CONFIGURAÇÃO ---
#define PULSO_MIN  150  // 0 Graus (Ajuste se bater no fim)
#define PULSO_MAX  480  // 180 Graus

// Mapa das Portas
int pinoBase = 0;
int pinoOmbro = 1;
int pinoCotovelo = 2;
int pinoPulso = 3;

void setup() {
  Serial.begin(115200);
  pwm.begin();
  pwm.setPWMFreq(50);
  
  Serial.println("--- SISTEMA TUSK PRONTO ---");
  Serial.println("Comandos disponiveis:");
  Serial.println("base 90");
  Serial.println("ombro 45");
  Serial.println("cotovelo 120");
  Serial.println("pulso 180");
}

void mover(int pino, int angulo) {
  // Proteção de Limites
  if (angulo < 0) angulo = 0;
  if (angulo > 180) angulo = 180;

  int pulso = map(angulo, 0, 180, PULSO_MIN, PULSO_MAX);
  pwm.setPWM(pino, 0, pulso);
  
  Serial.print("Movendo motor ");
  Serial.print(pino);
  Serial.print(" para ");
  Serial.println(angulo);
}

void loop() {
  if (Serial.available() > 0) {
    // Lê o nome do motor
    String comando = Serial.readStringUntil(' ');
    // Lê o ângulo
    int grau = Serial.parseInt();

    // Limpa o buffer
    while(Serial.available()) Serial.read();

    // Executa
    if (comando.equalsIgnoreCase("base")) {
      mover(pinoBase, grau);
    }
    else if (comando.equalsIgnoreCase("ombro")) {
      mover(pinoOmbro, grau);
    }
    else if (comando.equalsIgnoreCase("cotovelo")) {
      mover(pinoCotovelo, grau);
    }
    else if (comando.equalsIgnoreCase("pulso") || comando.equalsIgnoreCase("garra")) {
      mover(pinoPulso, grau);
    }
    else {
      Serial.println("Comando nao reconhecido. Tente: base, ombro, cotovelo, pulso");
    }
  }
}
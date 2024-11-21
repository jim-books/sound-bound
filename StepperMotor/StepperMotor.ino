
// Define GPIO Pins (Adjust as per your setup)
#define ENA_PIN    5   // ENA+ connected to GPIO 5
#define DIR_PIN    19  // DIR+ connected to GPIO 19
#define PUL_PIN    18  // PUL+ connected to GPIO 18

#define stepsPerRevolution 6400

void setup() {
  pinMode(DIR_PIN, OUTPUT);
  pinMode(PUL_PIN, OUTPUT);
}

void loop() {
  for (int i = 0; i < stepsPerRevolution; i++) {
    digitalWrite(DIR_PIN, HIGH);
    digitalWrite(PUL_PIN, HIGH);
    delayMicroseconds(50);
    digitalWrite(PUL_PIN, LOW);
    delayMicroseconds(50);
  }
}
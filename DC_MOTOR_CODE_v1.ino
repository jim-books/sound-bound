

/*  Arduino DC Motor Control - PWM | H-Bridge | L298N  -  Example 01

    by Dejan Nedelkovski, www.HowToMechatronics.com
*/
// CONNECTIONS -----------------
// MOTOR RED -> OUT1
// MOTOR WHITE -> OUT22
// MOTOR BLUE -> 5v+
// MOTOR BLACK -> GROUND

#define enA 11 // UNUSED
#define in1 2 // CONTROLLER in1
#define in2 3 // CONTROLLER in2


#define button 4 // UNUSED
int rotDirection = 0;

// ENCODER ////////////////////////////////
//#include <SimplyAtomic.h>
const int ENCA = 6; // MOTOR YELLOW
const int ENCB = 7; // MOTOR GREEN

volatile int motorPos = 0; // specify posi as volatile
// Target movement length of string
const int targetPos = 20;
///////////////////////////////////////////////

// Solenoid / Servo////////////////////////////////
#define solenoid 10 // 44N MOSFET


void setup() {
  // Motor Driver ////////////////////////////////
  pinMode(enA, OUTPUT);
  pinMode(in1, OUTPUT);
  pinMode(in2, OUTPUT);
  pinMode(button, INPUT);
  // Set initial rotation direction
  digitalWrite(in1, LOW);
  digitalWrite(in2, LOW);

  // ECODER ///////////////////////////////////////
  pinMode(ENCA,INPUT);
  pinMode(ENCB,INPUT);
  attachInterrupt(digitalPinToInterrupt(ENCA), readEncoder, RISING);

  
  /////////////////////////////////////////////////

  // SOLENOID ////////////////////
  pinMode(solenoid, OUTPUT);
  digitalWrite(solenoid, LOW);
  /////////////////////////////////////

  Serial.begin(115200);
}

void readEncoder(){
  int b = digitalRead(ENCB);
  if(b > 0){
    motorPos++;
  }
  else{
    motorPos--;
  }
}


void makeMovement(int move, int targetPos) {

  while (move != 0) {
    switch(move) { 
      case 1: //up
        // Actevate Solenoid
        digitalWrite(solenoid, LOW);
        Serial.println("Sol LOW");
        delay(50);
        //
        digitalWrite(in1, HIGH);
        digitalWrite(in2, LOW);
        Serial.println("TURNING CCW");
        rotDirection = 1;
        break;
      
      case 2: //down
        // Actevate Solenoid
        digitalWrite(solenoid, LOW);
        Serial.println("Sol LOW");
        delay(50);
        //
        digitalWrite(in1, LOW);
        digitalWrite(in2, HIGH);
        Serial.println("TURNING CW");
        rotDirection = 0;
        break;
    }

    // Stop the
    if (abs(targetPos) < (abs(motorPos) * 0.5) ) {
      
      // STOP MOTOR
      move = 0;
      digitalWrite(in1, LOW);
      digitalWrite(in2, LOW);
      Serial.print("TURNING STOP, pos at: ");
      Serial.println(motorPos);
      motorPos = 0;

      while (abs(targetPos) > abs(motorPos)) {
        delay(20);
      }
        
      // Actevate Solenoid
      delay(500);
      digitalWrite(solenoid, HIGH);
      Serial.println("Sol HIGH");
      delay(200);
      

      return;
    }

  }

  if (move == 0) {
      digitalWrite(in1, LOW);
      digitalWrite(in2, LOW);
      return;
    }

}

void loop() {
  //int potValue = analogRead(A0); // Read potentiometer value
  //int pwmOutput = map(potValue, 0, 1023, 0 , 255); // Map the potentiometer value from 0 to 255
  //analogWrite(enA, pwmOutput); // Send PWM signal to L298N Enable pin

    //ATOMIC() {
    //  pos = motorPos;
    //}

    makeMovement(1, targetPos);
    Serial.println(motorPos);
    delay(2000);
    motorPos = 0;

    makeMovement(2, targetPos);
    Serial.println(motorPos);
    delay(2000);
    motorPos = 0;


}


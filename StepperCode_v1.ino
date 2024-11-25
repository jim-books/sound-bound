// Include the AccelStepper library:
#include "AccelStepper.h"
// For ESP32 Communication
#include <esp_now.h>
#include <WiFi.h>

#define STEP_MOTOR_ACTION 1 // Action identifier

// Define stepper motor connections and motor interface type. 
// Motor interface type must be set to 1 when using a driver:
#define dirPin 2
#define stepPin 15
#define motorInterfaceType 1

// Create a new instance of the AccelStepper class:
AccelStepper stepper = AccelStepper(motorInterfaceType, stepPin, dirPin);


// ESP32 COMMUNICATION ////////////////////////////
typedef struct struct_message {
  int action;
  int spins;  // Additional parameter for spins
} struct_message;

struct_message incomingData;
///////////////////////////////////////////////////



void setup() {
  // ACCEL STEPPER///////////////////////////////////////////
  // Set the maximum speed and acceleration:
  // Steps per second
  stepper.setMaxSpeed(2800);
  // Acceleration in steps per second squared (Steps/s^2) 
  stepper.setAcceleration(8000);
  ///////////////////////////////////////////////////////////

  // ESP32 COMMUNICATION ////////////////////////////////////
  Serial.begin(115200);
  // Set up Wi-Fi
  WiFi.mode(WIFI_STA);

  if (esp_now_init() != ESP_OK) {
    Serial.println("Error initializing ESP-NOW");
    return;
  }
  
  // Register the callback to receive data
  esp_now_register_recv_cb(OnDataReceived);
  ////////////////////////////////////////////////////////////
  
}


// ESP32 COMMUNICATION ////////////////////////////////////
void OnDataReceived(const uint8_t *mac_addr, const uint8_t *data, int data_len) {
  memcpy(&incomingData, data, sizeof(incomingData));
  
  if (incomingData.action == STEP_MOTOR_ACTION) {
    Serial.println("Action received: Triggering stepper motor.");
    turnStepperMotor(incomingData.spins); // Pass spins to the function
  }
  
}
///////////////////////////////////////////////////////////


void turnStepperMotor(int spins)) {
  // Your stepper motor control logic
  switch(spins) {
    // Move up
    case 1:
      stepper.moveTo(200);
      // Run to target position with set speed and acceleration/deceleration:
      stepper.runToPosition();
      stepper.run();
      Serial.println("Stepper at step: 200");
      break;

    // Move down
    case 2:
      stepper.moveTo(0);
      // Run to target position with set speed and acceleration/deceleration:
      stepper.runToPosition();
      stepper.run();
      Serial.println("Stepper at step: 200");
      break;
  }

}



void loop() {
  // Set the target position:
  stepper.moveTo(200);
  // Run to target position with set speed and acceleration/deceleration:
  stepper.runToPosition();

  stepper.run();

  delay(1000);

  // Move back to zero:
  stepper.moveTo(0);
  stepper.runToPosition();

  stepper.run();

  delay(1000);


}
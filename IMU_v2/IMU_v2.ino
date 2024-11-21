#include <Wire.h>
#include "Waveshare_10Dof-D.h"
#include <BLEMIDI_Transport.h>
#include <hardware/BLEMIDI_ESP32.h>

// Create instances for Bluetooth MIDI
BLEMIDI_CREATE_INSTANCE("SoundboundTest", MIDI);

// Constants and Parameters
const float MOTION_START_THRESHOLD = 0.5;   // Threshold for detecting motion (g), dynamic based on calibration
const float MOTION_STOP_THRESHOLD = 0.25;   // Threshold for stopping motion detection (g), dynamic based on calibration
const float HIT_DECEL_THRESHOLD = 1.0;      // Threshold for detecting hit (g)
const unsigned long DEBOUNCE_TIME = 1;     // Debounce time in milliseconds
const unsigned long LOOP_INTERVAL = 15;      // Main loop interval in milliseconds
const unsigned long HIT_RELEASE_TIME = 1;  // Time to transition back to IDLE after a hit (ms)

// MIDI Parameters
const int MIDI_CHANNEL = 10;              // MIDI channel (1-16)
const int BASS_NOTE = 36;                 // MIDI note number for bass
const int SNARE_NOTE = 38;                // MIDI note number for snare
const int VELOCITY_MIN = 30;              // Minimum MIDI velocity
const int VELOCITY_MAX = 127;             // Maximum MIDI velocity
const int NOTE_DURATION_MS = 50;          // Fixed note duration in milliseconds

// Variables for Hit Detection
float previousMagnitude = 0.0;
bool isMoving = false;
unsigned long lastHitTime = 0;

// State Machine Variables
enum HitState {
  IDLE,
  DETECTING,
  HIT_DETECTED
};

HitState currentState = IDLE;
unsigned long stateChangeTime = 0;

// Calibration Variables
float baselineMagnitude = 0.0;
const int CALIBRATION_SAMPLES = 100;
int calibrationCount = 0;

// Structures for IMU Data
IMU_ST_ANGLES_DATA stAngles;
IMU_ST_SENSOR_DATA stAccelRawData;
IMU_ST_SENSOR_DATA stGyroRawData;
IMU_ST_SENSOR_DATA stMagnRawData;

// Filtering Variables
#define ALPHA 0.5
float filteredAccelX = 0.0;
float filteredAccelY = 0.0;
float filteredAccelZ = 0.0;

// Debugging
#define DEBUG_MODE 0
#if DEBUG_MODE
  #define DEBUG_PRINT(x) Serial.println(x)
#else
  #define DEBUG_PRINT(x)
#endif

// Function Prototypes
int mapDecelerationToVelocity(float deceleration);
void sendMIDINote(int note, int velocity);
void calibrateIMU();

void setup() {
  // Initialize Serial Monitor for debugging
  Serial.begin(115200);
  while (!Serial) {
    ; // Wait for Serial Monitor to open
  }
  Serial.println("Drumstick Hit Detection System Initializing...");

  // Initialize I2C communication on GPIO8 and GPIO9
  Wire.begin(8, 9); // SDA: GPIO8, SCL: GPIO9
  Serial.println("I2C Initialized on GPIO8 (SDA) and GPIO9 (SCL).");

  // Initialize IMU with retry logic
  IMU_EN_SENSOR_TYPE enMotionSensorType, enPressureType;
  const int maxRetries = 5;
  int retryCount = 0;
  bool imuDetected = false;

  while (retryCount < maxRetries && !imuDetected) {
    imuInit(&enMotionSensorType, &enPressureType);
    if (enMotionSensorType == IMU_EN_SENSOR_TYPE_ICM20948) {
      Serial.println("IMU Sensor is ICM-20948.");
      imuDetected = true;
    } else {
      Serial.println("IMU Sensor not detected! Retrying...");
      retryCount++;
      delay(1000);
    }
  }

  if (!imuDetected) {
    Serial.println("Failed to detect IMU after multiple attempts. Halting.");
    while (1); // Halt execution
  }

  // Perform Calibration
  calibrateIMU();

  // Initialize MIDI
  MIDI.begin(MIDI_CHANNEL + 1); // MIDI.begin takes channels 1-16
  Serial.println("MIDI Initialized.");

  // Initialize BLE-MIDI
  BLEMIDI.setHandleConnected([]() {
    Serial.println("Bluetooth MIDI Client Connected");
  });

  BLEMIDI.setHandleDisconnected([]() {
    Serial.println("Bluetooth MIDI Client Disconnected");
  });

  Serial.println("Setup Complete. System Ready.");
}

void loop() {
  static unsigned long lastLoopTime = 0;

  // Ensure the loop runs every LOOP_INTERVAL milliseconds
  unsigned long currentTime = millis();
  if (currentTime - lastLoopTime < LOOP_INTERVAL) {
    return;
  }
  lastLoopTime = currentTime;

  // Retrieve IMU data
  imuDataGet(&stAngles, &stGyroRawData, &stAccelRawData, &stMagnRawData);

  // Scale raw acceleration to 'g' units (assuming ±16g range and LSB = 2048 LSB/g)
  float accelX = stAccelRawData.s16X / 2048.0;
  float accelY = stAccelRawData.s16Y / 2048.0;
  float accelZ = stAccelRawData.s16Z / 2048.0;

  // Apply Low-Pass Filter
  filteredAccelX = ALPHA * accelX + (1 - ALPHA) * filteredAccelX;
  filteredAccelY = ALPHA * accelY + (1 - ALPHA) * filteredAccelY;
  filteredAccelZ = ALPHA * accelZ + (1 - ALPHA) * filteredAccelZ;

  // Calculate total acceleration magnitude using filtered values
  float magnitude = sqrt(pow(filteredAccelX, 2) + pow(filteredAccelY, 2) + pow(filteredAccelZ, 2));

  // Debugging: Print current acceleration and magnitude
  #if DEBUG_MODE
    Serial.print("Accel X: ");
    Serial.print(filteredAccelX, 3);
    Serial.print(" g, Y: ");
    Serial.print(filteredAccelY, 3);
    Serial.print(" g, Z: ");
    Serial.print(filteredAccelZ, 3);
    Serial.print(" g | Total Accel: ");
    Serial.print(magnitude, 3);
    Serial.println(" g");
  #endif

  // Dynamic Thresholds based on Calibration
  float dynamicMotionStartThreshold = baselineMagnitude + MOTION_START_THRESHOLD; // e.g., baseline + 0.5g
  float dynamicMotionStopThreshold = baselineMagnitude + MOTION_STOP_THRESHOLD;   // e.g., baseline + 0.25g

  // Detect Movement with Hysteresis
  if (magnitude > dynamicMotionStartThreshold) {
    isMoving = true;
  } else if (magnitude < dynamicMotionStopThreshold) {
    isMoving = false;
  }

  // State Machine for Hit Detection
  switch(currentState) {
    case IDLE:
      if (isMoving) {
        currentState = DETECTING;
      }
      break;

    case DETECTING:
      {
        float deceleration = previousMagnitude - magnitude;
        if (deceleration > HIT_DECEL_THRESHOLD) {
          if (currentTime - lastHitTime > DEBOUNCE_TIME) {
            int velocity = mapDecelerationToVelocity(deceleration);
            sendMIDINote(SNARE_NOTE, velocity);
            lastHitTime = currentTime;
            currentState = HIT_DETECTED;
            stateChangeTime = currentTime;
            Serial.print("Hit Detected! Deceleration: ");
            Serial.print(deceleration, 3);
            Serial.print(" g, Velocity: ");
            Serial.println(velocity);
          }
        }

        if (magnitude < dynamicMotionStopThreshold) {
          currentState = IDLE;
        }
      }
      break;

    case HIT_DETECTED:
      if (currentTime - stateChangeTime > HIT_RELEASE_TIME) {
        currentState = IDLE;
      }
      break;
  }

  // Update previous magnitude
  previousMagnitude = magnitude;

  // Process BLE-MIDI events
  BLEMIDI.read();
}

/**
 * Maps deceleration to MIDI velocity based on observed deceleration range.
 * Uses linear scaling for direct proportionality.
 * 
 * @param deceleration Deceleration value (g)
 * @return Mapped MIDI velocity (VELOCITY_MIN - VELOCITY_MAX)
 */
int mapDecelerationToVelocity(float deceleration) {
  // Define adjusted deceleration range based on observed data
  const float DECEL_MIN = 1.0; // Minimum deceleration observed (g)
  const float DECEL_MAX = 2.0; // Adjusted maximum deceleration (g)

  // Normalize deceleration between 0 and 1
  float normalizedDecel = (deceleration - DECEL_MIN) / (DECEL_MAX - DECEL_MIN);
  normalizedDecel = constrain(normalizedDecel, 0.0, 1.0);

  // Apply linear scaling to map to MIDI velocity range
  float scaledVelocity = VELOCITY_MIN + (normalizedDecel * (VELOCITY_MAX - VELOCITY_MIN));

  // Round to nearest integer and constrain within MIDI velocity limits
  int velocity = round(scaledVelocity);
  velocity = constrain(velocity, VELOCITY_MIN, VELOCITY_MAX);

  return velocity;
}

/**
 * Calibration Function to determine baseline magnitude.
 */
void calibrateIMU() {
  Serial.println("Calibrating...");
  while (calibrationCount < CALIBRATION_SAMPLES) {
    imuDataGet(&stAngles, &stGyroRawData, &stAccelRawData, &stMagnRawData);
    float accelX = stAccelRawData.s16X / 2048.0;
    float accelY = stAccelRawData.s16Y / 2048.0;
    float accelZ = stAccelRawData.s16Z / 2048.0;
    float magnitude = sqrt(pow(accelX, 2) + pow(accelY, 2) + pow(accelZ, 2));
    baselineMagnitude += magnitude;
    calibrationCount++;
    delay(10); // Ensure consistent timing between samples
  }
  baselineMagnitude /= CALIBRATION_SAMPLES;
  Serial.print("Calibration complete. Baseline Magnitude: ");
  Serial.println(baselineMagnitude);
}

/**
 * Sends a MIDI Note On and Note Off message with non-blocking delay.
 * 
 * @param note     MIDI note number (0-127)
 * @param velocity MIDI velocity (0-127)
 */
void sendMIDINote(int note, int velocity) {
  MIDI.sendNoteOn(note, velocity, MIDI_CHANNEL);
  Serial.print("MIDI Note Sent: ");
  Serial.print(note);
  Serial.print(" | Velocity: ");
  Serial.println(velocity);
}
/*
  Real-Time Drumstick Hit Detection System (Refined)
  ===================================================
  
  Description:
  This system detects drumstick hits in real-time using the ICM20948 IMU sensor
  attached to the drumstick. It calculates the total acceleration magnitude to
  detect sudden stops (hits) and sends MIDI drum hit messages over Bluetooth.
  
  Hardware:
  - ESP32 Development Board
  - ICM20948 9-axis IMU Sensor
  - Bluetooth-enabled MIDI device (e.g., smartphone, computer)
  
  Libraries:
  - ICM20948_WE: https://github.com/wollewald/ICM20948_WE
  - BLE-MIDI: https://github.com/lathoub/Arduino-BLE-MIDI
  
*/

#include <Wire.h>
#include <ICM20948_WE.h>
#include <BLEMIDI_Transport.h>
#include <hardware/BLEMIDI_ESP32.h>

// Create instances for IMU and Bluetooth
ICM20948_WE imu;
BLEMIDI_CREATE_INSTANCE("SoundboundTest",MIDI);

// Constants and Parameters
const float MOTION_START_THRESHOLD = 0.5; // Threshold for detecting motion (g) - adjusted after scaling
const float MOTION_STOP_THRESHOLD = 0.25; // Threshold for detecting hit (g) - adjusted after scaling
const float HIT_DECEL_THRESHOLD = 1.0;    // Threshold for detecting hit (g)
const unsigned long DEBOUNCE_TIME = 150;   // Debounce time in milliseconds
const unsigned long LOOP_INTERVAL = 15;   // Loop interval in milliseconds

// MIDI Parameters
const int MIDI_CHANNEL = 10;             // MIDI channel (1-16)
const int BASS_NOTE = 36;                // MIDI note number for bass
const int SNARE_NOTE = 38;               // MIDI note number for acoustic snare

const int VELOCITY_MIN = 30;             // Minimum MIDI velocity
const int VELOCITY_MAX = 127;            // Maximum MIDI velocity

// Accelerometer Sensitivity based on range (±16g)
const float ACC_SENSITIVITY = 2048.0;      // LSB/g for ±16g

// Variables for Hit Detection
float previousMagnitude = 0.0;
bool isMoving = false;
unsigned long lastHitTime = 0;

bool isConnected = false;

int mapDecelerationToVelocity(float deceleration);

void setup() {
  // Initialize Serial Monitor for debugging
  Serial.begin(115200);  // Changed to a standard baud rate
  while (!Serial) {
    ; // Wait for Serial Monitor to open
  }
  Serial.println("Drumstick Hit Detection System Initializing...");

  // Initialize I2C communication
  Wire.begin();

  // Initialize IMU
  if (!imu.init()) {
    Serial.println("Failed to initialize IMU!");
    while (1);
  }
  Serial.println("IMU Initialized.");

  // Calibrate IMU
  Serial.println("Calibrating IMU...");
  imu.autoOffsets();
  Serial.println("IMU Calibration Complete.");

  // Configure IMU settings
  imu.setAccRange(ICM20948_ACC_RANGE_16G);
  Serial.print("Accelerometer Range Set to: ");
  Serial.println(ICM20948_ACC_RANGE_16G);

  imu.setAccDLPF(ICM20948_DLPF_5); // Corrected constant
  Serial.print("Accelerometer DLPF Set to: ");
  Serial.println(ICM20948_DLPF_5);

  Serial.println("IMU Configuration Set.");

  // Initialize MIDI
  MIDI.begin(MIDI_CHANNEL + 1);  // MIDI.begin takes channels 1-16
  Serial.println("MIDI Initialized.");

  // Initialize BLE-MIDI
  BLEMIDI.setHandleConnected([]() {
    Serial.println("Bluetooth MIDI Client Connected");
    isConnected = true;
  });

  BLEMIDI.setHandleDisconnected([]() {
    Serial.println("Bluetooth MIDI Client Disconnected");
    isConnected = false;
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

  // Read sensor data
  imu.readSensor();
  xyzFloat accelRaw = imu.getAccRawValues();

  // Scale raw acceleration to 'g' units
  float accelX = accelRaw.x / ACC_SENSITIVITY;
  float accelY = accelRaw.y / ACC_SENSITIVITY;
  float accelZ = accelRaw.z / ACC_SENSITIVITY;

  // Calculate total acceleration magnitude
  float magnitude = sqrt(pow(accelX, 2) + pow(accelY, 2) + pow(accelZ, 2));

  // Debugging: Print scaled acceleration values and magnitude
  // Serial.print("Accel X: ");
  // Serial.print(accelX, 3);
  // Serial.print(" g, Y: ");
  // Serial.print(accelY, 3);
  // Serial.print(" g, Z: ");
  // Serial.print(accelZ, 3);
  // Serial.print(" g | Total Accel: ");
  // Serial.print(magnitude, 3);
  // Serial.println(" g");

  // Detect Movement with Hysteresis
  if (magnitude > MOTION_START_THRESHOLD) {
    isMoving = true;
  } else if (magnitude < MOTION_STOP_THRESHOLD) {
    isMoving = false;
  }

  // Detect Hit (Sudden Deceleration)
  if (isMoving) {
    float deceleration = previousMagnitude - magnitude;

    // Log deceleration for analysis
    // Serial.print("Deceleration: ");
    // Serial.print(deceleration, 3);
    // Serial.println(" g");

    if (deceleration > HIT_DECEL_THRESHOLD) {
      // Check for debounce
      if (currentTime - lastHitTime > DEBOUNCE_TIME) {
        // Map deceleration to MIDI velocity using the new function
        int velocity = mapDecelerationToVelocity(deceleration);

        // Choose which note to send based on axis with maximum acceleration
        // For simplicity, sending SNARE_NOTE. Extend logic as needed.
        sendMIDINote(SNARE_NOTE, velocity);

        // Update last hit time
        lastHitTime = currentTime;

        // Debugging: Print hit information
        Serial.print("Hit Detected! Deceleration: ");
        Serial.print(deceleration, 3);
        Serial.print(" g, Velocity: ");
        Serial.println(velocity);
      }
    }
  }

  // Update previous magnitude
  previousMagnitude = magnitude;

}

/**
 * Maps deceleration to MIDI velocity based on observed deceleration range.
 * Uses non-linear (exponential) mapping to provide a more responsive velocity scaling.
 * 
 * @param deceleration Deceleration value (g)
 * @return Mapped MIDI velocity (50-127)
 */
int mapDecelerationToVelocity(float deceleration) {
  // Define your observed deceleration range here
  const float DECEL_MIN = 1.0; // Minimum deceleration observed (g)
  const float DECEL_MAX = 9.0; // Maximum deceleration observed (g)

  // Normalize deceleration between 0 and 1
  float normalizedDecel = (deceleration - DECEL_MIN) / (DECEL_MAX - DECEL_MIN);
  normalizedDecel = constrain(normalizedDecel, 0.0, 1.0);

  // Apply exponential scaling to enhance sensitivity for lower hits
  float expScale = pow(normalizedDecel, 1.3); // Exponent >1 for non-linear mapping

  // Map to MIDI velocity range
  int velocity = VELOCITY_MIN + (expScale * (VELOCITY_MAX - VELOCITY_MIN));
  velocity = constrain(velocity, VELOCITY_MIN, VELOCITY_MAX);

  return velocity;
}

/**
 * Sends a MIDI Note On message over Bluetooth.
 * 
 * @param note     MIDI note number (0-127)
 * @param velocity MIDI velocity (0-127)
 */
void sendMIDINote(int note, int velocity) {
    MIDI.sendNoteOn (36, velocity, 1); // note 38, velocity 100 on channel 1
    Serial.println("MIDI sent.");

}
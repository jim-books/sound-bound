#include "Waveshare_10Dof-D.h"
#include <Wire.h>
#include <BLEMIDI_Transport.h>
#include <hardware/BLEMIDI_ESP32.h>
bool gbSenserConnectState = false;


// Sensitivity for hit detection
float sensitivity = 11500.0; // Adjust this value as needed

BLEMIDI_CREATE_INSTANCE("SoundboundTest", MIDI);

// MIDI Parameters
const int MIDI_CHANNEL = 10;             // MIDI channel (1-16)
const int BASS_NOTE = 36;                // MIDI note number for bass
const int SNARE_NOTE = 38;               // MIDI note number for acoustic snare

bool isConnected = false;

void setup() {

  // put your setup code here, to run once:
  bool bRet;
  IMU_EN_SENSOR_TYPE enMotionSensorType, enPressureType;
  Serial.begin(115200);
  Wire.begin(8, 9);

  imuInit(&enMotionSensorType, &enPressureType);
  if(IMU_EN_SENSOR_TYPE_ICM20948 == enMotionSensorType)
  {
    Serial.println("Motion sersor is ICM-20948");
  }
  else
  {
    Serial.println("Motion sersor NULL");
  }
  if(IMU_EN_SENSOR_TYPE_BMP280 == enPressureType)
  {
    Serial.println("Pressure sersor is BMP280");
  }
  else
  {
    Serial.println("Pressure sersor NULL");
  }
  delay(1000);

  MIDI.begin(MIDI_CHANNEL + 1);
  Serial.println("MIDI Initialised");
  
  BLEMIDI.setHandleConnected([]() {
    Serial.println("Bluetooth MIDI Client Connected");
    isConnected = true;
  });

  BLEMIDI.setHandleDisconnected([]{
    Serial.println("Bluetooht MIDI Client Discounnected");
    isConnected = false;
  });

}

void detectHit(int16_t accelX, int16_t accelY, int16_t accelZ) {
  // Calculate the magnitude of the acceleration vector
  float magnitude = sqrt(accelX * accelX + accelY * accelY + accelZ * accelZ);
  Serial.print("Detecting HIT, magnitude:  ");
  Serial.println(magnitude);

  // Check if the magnitude exceeds the sensitivity threshold
  if (magnitude < sensitivity) {
    // Call the function to handle a hit
    handleHit();
  }
}

void handleHit() {
  Serial.println("Hit detected! Performing function X...");
  MIDI.sendNoteOn (SNARE_NOTE, 100, 1);
  Serial.println("MIDI sent.");
  delay(100);
  // Add your custom functionality here
  // For example, you could play a sound, trigger an LED, etc.
}


void loop() {
  // put your main code here, to run repeatedly:
  IMU_ST_ANGLES_DATA stAngles;
  IMU_ST_SENSOR_DATA stGyroRawData;
  IMU_ST_SENSOR_DATA stAccelRawData;
  IMU_ST_SENSOR_DATA stMagnRawData;
  int32_t s32PressureVal = 0, s32TemperatureVal = 0, s32AltitudeVal = 0;
  
  imuDataGet( &stAngles, &stGyroRawData, &stAccelRawData, &stMagnRawData);
  pressSensorDataGet(&s32TemperatureVal, &s32PressureVal, &s32AltitudeVal);

  // Detect hit based on acceleration data
  detectHit(stAccelRawData.s16X, stAccelRawData.s16Y, stAccelRawData.s16Z);

  /*
  // DEBUGGING OUTPUTTTT ///////////////////////////////////////////////////////////
  Serial.println();
  Serial.println("/-------------------------------------------------------------/");
  Serial.print("Roll : "); Serial.print(stAngles.fRoll);
  Serial.print("    Pitch : "); Serial.print(stAngles.fPitch);
  Serial.print("    Yaw : "); Serial.print(stAngles.fYaw);
  Serial.println();
  Serial.print("Acceleration: X : "); Serial.print(stAccelRawData.s16X);
  Serial.print("    Acceleration: Y : "); Serial.print(stAccelRawData.s16Y);
  Serial.print("    Acceleration: Z : "); Serial.print(stAccelRawData.s16Z);
  Serial.println();
  Serial.print("Gyroscope: X : "); Serial.print(stGyroRawData.s16X);
  Serial.print("       Gyroscope: Y : "); Serial.print(stGyroRawData.s16Y);
  Serial.print("       Gyroscope: Z : "); Serial.print(stGyroRawData.s16Z);
  Serial.println();
  Serial.print("Magnetic: X : "); Serial.print(stMagnRawData.s16X);
  Serial.print("      Magnetic: Y : "); Serial.print(stMagnRawData.s16Y);
  Serial.print("      Magnetic: Z : "); Serial.print(stMagnRawData.s16Z);
  Serial.println();
  Serial.print("Pressure : "); Serial.print((float)s32PressureVal / 100);
  Serial.print("     Altitude : "); Serial.print((float)s32AltitudeVal / 100);
  Serial.println();  
  Serial.print("Temperature : "); Serial.print((float)s32TemperatureVal / 100);
  Serial.println();  
  delay(200);
  */
}

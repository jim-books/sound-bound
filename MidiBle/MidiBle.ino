#include <BLEMIDI_Transport.h>
#include <hardware/BLEMIDI_ESP32.h>

BLEMIDI_CREATE_INSTANCE("SoundboundTest",MIDI);

unsigned long t0 = millis();
bool isConnected = false;

void setup()
{
  MIDI.begin();
  Serial.begin(9600);

  BLEMIDI.setHandleConnected([]() {
    Serial.println("Client Connected");
    isConnected = true;
  });

  BLEMIDI.setHandleDisconnected([]() {
    Serial.println("Client disconnected");
    isConnected = false;
  });
}

// -----------------------------------------------------------------------------
//
// -----------------------------------------------------------------------------
void loop()
{

  if (isConnected && (millis() - t0) > 1000)
  {
    t0 = millis();

    MIDI.sendNoteOn (38, 100, 1); // note 38, velocity 100 on channel 1
    Serial.println("sent");
  }
}

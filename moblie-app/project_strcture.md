# SoundBound Project Structure

## Overview

SoundBound is a Flutter mobile application that enables users to configure a virtual drum kit and communicate with an Arduino-controlled electrical drum system via MIDI over Bluetooth.

## Directory Structure

```
/soundbound/
  ├── /lib/                         # Main application code
  │    ├── /screens/                # Full-page screens
  │    │    ├── sitting_height_screen.dart    # Screen for configuring sitting height
  │    │    └── drum_interface_screen.dart    # Screen for customizing the drum kit
  │    ├── /widgets/                # Reusable UI components
  │    │    ├── drum_icon.dart      # Widget for displaying and interacting with a drum element
  │    │    └── drum_settings_dialog.dart     # Dialog for configuring individual drum settings
  │    ├── /models/                 # Data models
  │    │    └── drum_config.dart    # Models for drum configuration data
  │    ├── /services/               # Business logic and services
  │    │    ├── bluetooth_service.dart   # Service for Bluetooth communication
  │    │    └── midi_service.dart   # Service for processing MIDI signals
  │    └── main.dart                # Entry point of the app
  ├── /assets/                      # Static assets
  │    ├── /images/                 # Image files
  │    └── /animations/             # Animation files
  └── pubspec.yaml                  # Project configuration
```

## Key Components

1. **Screens**:
   - `SittingHeightScreen`: Allows users to input their sitting height with a visual guide.
   - `DrumInterfaceScreen`: Provides a canvas for customizing the virtual drum kit.

2. **Widgets**:
   - `DrumIcon`: Represents individual drum elements that can be dragged and configured.
   - `DrumSettingsDialog`: A modal dialog for adjusting individual drum settings.

3. **Models**:
   - `DrumElement`: Represents a single drum element with properties like position, volume, and sound filter.
   - `DrumConfigModel`: State management for the entire drum configuration using Provider.

4. **Services**:
   - `BluetoothService`: Handles Bluetooth communication with the Arduino board.
   - `MidiService`: Processes MIDI signals for visualization and feedback.

## State Management

The application uses the Provider pattern for state management. The main state container is `DrumConfigModel`, which stores:
- User's sitting height
- Collection of drum elements with their positions and settings

## Communication Protocol

The app communicates with the Arduino using a custom JSON protocol over Bluetooth:

1. **Configuration Messages**: Sent from app to Arduino
   ```json
   {
     "command_type": "drum_config",
     "payload": {
       "drums": [
         {
           "id": "kick",
           "name": "Kick Drum",
           "volume": 0.8,
           "sound_filter": "normal",
           "position": { "x": 150, "y": 300 }
         },
         ...
       ]
     }
   }
   ```

2. **MIDI Messages**: Received from Arduino to app
   - Raw MIDI data packets are parsed by `MidiService`
   - Each note is mapped to a specific drum ID for visual feedback

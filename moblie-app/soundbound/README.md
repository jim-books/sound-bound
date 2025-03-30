# SoundBound

A Flutter application for configuring and interfacing with an Arduino-controlled electrical drum system via MIDI over Bluetooth.

## Features

- Configure personal sitting height for optimal drum setup
- Customize virtual drum kit by repositioning drum elements
- Individually configure sound settings for each drum element
- Transmit and receive MIDI signals via Bluetooth communication
- Visualize MIDI feedback in real-time

## Getting Started

### Prerequisites

- Flutter SDK (version 3.7.0 or higher)
- Android Studio or Visual Studio Code with Flutter extensions
- An Android or iOS device with Bluetooth capabilities
- Arduino board with Bluetooth module and the electrical drum system

### Installation

1. Clone this repository:
   ```bash
   git clone https://github.com/yourusername/soundbound.git
   cd soundbound
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Connect your device and run the app:
   ```bash
   flutter run
   ```

## Usage

1. **Configure Sitting Height**:
   - Launch the app and follow the visual guide
   - Use the slider or input field to enter your sitting height
   - Press "Next" to proceed to the drum interface

2. **Customize Drum Kit**:
   - Drag drum elements to position them in your preferred layout
   - Tap the settings icon on each drum to configure:
     - Volume level
     - Sound filter options (normal, reverb, delay, distortion)

3. **Connect to Arduino**:
   - Press the Bluetooth button to scan for and connect to your Arduino
   - Once connected, your configuration will be sent to the drum system
   - MIDI signals from the physical drums will be visualized in the app

## Architecture

The app is built using a modular architecture with separation of concerns:

- **Provider** for state management
- **Flutter Blue Plus** for Bluetooth communication
- **Custom MIDI parsing** for real-time signal processing

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

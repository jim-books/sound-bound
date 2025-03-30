import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/drum_config.dart';
import '../widgets/drum_icon.dart';
import '../widgets/drum_settings_dialog.dart';

class DrumInterfaceScreen extends StatefulWidget {
  const DrumInterfaceScreen({super.key});

  @override
  State<DrumInterfaceScreen> createState() => _DrumInterfaceScreenState();
}

class _DrumInterfaceScreenState extends State<DrumInterfaceScreen> {
  final List<Map<String, dynamic>> _defaultDrumElements = [
    {'id': 'kick', 'name': 'Kick Drum', 'position': const Offset(150, 300)},
    {'id': 'snare', 'name': 'Snare Drum', 'position': const Offset(250, 200)},
    {'id': 'hihat', 'name': 'Hi-Hat', 'position': const Offset(350, 150)},
    {'id': 'tom1', 'name': 'Tom 1', 'position': const Offset(150, 150)},
    {'id': 'tom2', 'name': 'Tom 2', 'position': const Offset(300, 250)},
    {'id': 'crash', 'name': 'Crash Cymbal', 'position': const Offset(100, 100)},
    {'id': 'ride', 'name': 'Ride Cymbal', 'position': const Offset(400, 200)},
  ];

  @override
  void initState() {
    super.initState();
    // Add default drum elements if none exist
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final model = Provider.of<DrumConfigModel>(context, listen: false);
      if (model.drumElements.isEmpty) {
        for (final drum in _defaultDrumElements) {
          model.addDrumElement(
            DrumElement(
              id: drum['id'],
              name: drum['name'],
              position: drum['position'],
            ),
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Drum Kit Customization'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Configuration saved!')),
              );
              // This would eventually trigger sending the config to the Arduino
            },
          ),
        ],
      ),
      body: Consumer<DrumConfigModel>(
        builder: (context, drumConfigModel, child) {
          return Stack(
            children: [
              // Background grid
              CustomPaint(
                painter: GridPainter(),
                size: Size.infinite,
              ),
              // Drum elements
              ...drumConfigModel.drumElements.map((drum) => 
                DrumIcon(
                  key: ValueKey(drum.id),
                  drum: drum,
                  onPositionChanged: (newPosition) {
                    drumConfigModel.updateDrumPosition(drum.id, newPosition);
                  },
                  onSettingsTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => DrumSettingsDialog(
                        drum: drum,
                        onSave: (name, volume, soundFilter) {
                          drumConfigModel.updateDrumSettings(
                            drum.id,
                            name: name,
                            volume: volume,
                            soundFilter: soundFilter,
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // This would trigger a Bluetooth connection to receive MIDI signals
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Connecting to drum hardware...')),
          );
        },
        child: const Icon(Icons.bluetooth),
      ),
    );
  }
}

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.withOpacity(0.3)
      ..strokeWidth = 1.0;

    const double step = 50.0;
    
    for (double i = 0; i < size.width; i += step) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    
    for (double i = 0; i < size.height; i += step) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

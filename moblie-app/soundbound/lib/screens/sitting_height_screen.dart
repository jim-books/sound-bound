import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/drum_config.dart';
import 'drum_interface_screen.dart';

class SittingHeightScreen extends StatefulWidget {
  const SittingHeightScreen({super.key});

  @override
  State<SittingHeightScreen> createState() => _SittingHeightScreenState();
}

class _SittingHeightScreenState extends State<SittingHeightScreen> {
  final TextEditingController _heightController = TextEditingController();
  double _sliderValue = 70.0; // Default value in cm
  
  @override
  void dispose() {
    _heightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sitting Height'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Please sit on the drum chair as shown and measure your sitting height.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 40),
              AnimatedSeatingWidget(),
              const SizedBox(height: 40),
              SittingHeightInput(
                sliderValue: _sliderValue,
                onChanged: (value) {
                  setState(() {
                    _sliderValue = value;
                    _heightController.text = value.toStringAsFixed(1);
                  });
                },
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _heightController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Height (cm)',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        final double? height = double.tryParse(value);
                        if (height != null && height >= 40 && height <= 120) {
                          setState(() {
                            _sliderValue = height;
                          });
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: () {
                      final double height = _sliderValue;
                      Provider.of<DrumConfigModel>(context, listen: false)
                          .setSittingHeight(height);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DrumInterfaceScreen(),
                        ),
                      );
                    },
                    child: const Text('Next'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AnimatedSeatingWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // This widget would ideally have a 3D model or animation
    // For now, a simple placeholder is used
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Center(
        child: Text(
          'Animated Seating Model\n(Will be implemented)',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class SittingHeightInput extends StatelessWidget {
  final double sliderValue;
  final ValueChanged<double> onChanged;

  const SittingHeightInput({
    super.key,
    required this.sliderValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '${sliderValue.toStringAsFixed(1)} cm',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Slider(
          value: sliderValue,
          min: 40.0,
          max: 120.0,
          divisions: 80,
          label: '${sliderValue.toStringAsFixed(1)} cm',
          onChanged: onChanged,
        ),
      ],
    );
  }
}

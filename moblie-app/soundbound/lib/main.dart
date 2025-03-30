import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/sitting_height_screen.dart';
import 'models/drum_config.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DrumConfigModel()),
      ],
      child: const SoundBoundApp(),
    ),
  );
}

class SoundBoundApp extends StatelessWidget {
  const SoundBoundApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SoundBound',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const SittingHeightScreen(),
    );
  }
}

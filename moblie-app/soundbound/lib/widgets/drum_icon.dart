import 'package:flutter/material.dart';
import '../models/drum_config.dart';

class DrumIcon extends StatefulWidget {
  final DrumElement drum;
  final Function(Offset) onPositionChanged;
  final VoidCallback onSettingsTap;

  const DrumIcon({
    super.key,
    required this.drum,
    required this.onPositionChanged,
    required this.onSettingsTap,
  });

  @override
  State<DrumIcon> createState() => _DrumIconState();
}

class _DrumIconState extends State<DrumIcon> {
  late Offset _position;
  bool _isHighlighted = false;
  
  @override
  void initState() {
    super.initState();
    _position = widget.drum.position;
  }
  
  @override
  void didUpdateWidget(DrumIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.drum.position != widget.drum.position) {
      _position = widget.drum.position;
    }
  }

  void _animateHighlight() {
    setState(() {
      _isHighlighted = true;
    });
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _isHighlighted = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: _position.dx - 40, // Center on position
      top: _position.dy - 40,
      child: GestureDetector(
        onPanUpdate: (details) {
          final RenderBox box = context.findRenderObject() as RenderBox;
          final Offset localPosition = box.localToGlobal(Offset.zero);
          final newPosition = Offset(
            _position.dx + details.delta.dx,
            _position.dy + details.delta.dy,
          );
          setState(() {
            _position = newPosition;
          });
          widget.onPositionChanged(newPosition);
        },
        child: Stack(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: _isHighlighted 
                    ? Theme.of(context).primaryColor.withOpacity(0.8)
                    : Theme.of(context).colorScheme.primary.withOpacity(0.5),
                borderRadius: BorderRadius.circular(40),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  _getDrumIconLabel(widget.drum.id),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: IconButton(
                icon: const Icon(Icons.settings, color: Colors.white),
                onPressed: widget.onSettingsTap,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  String _getDrumIconLabel(String drumId) {
    switch (drumId) {
      case 'kick':
        return 'K';
      case 'snare':
        return 'S';
      case 'hihat':
        return 'HH';
      case 'tom1':
        return 'T1';
      case 'tom2':
        return 'T2';
      case 'crash':
        return 'CR';
      case 'ride':
        return 'RD';
      default:
        return drumId.substring(0, min(2, drumId.length)).toUpperCase();
    }
  }
  
  int min(int a, int b) => a < b ? a : b;
}

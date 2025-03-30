import 'package:flutter/material.dart';
import '../models/drum_config.dart';

class DrumSettingsDialog extends StatefulWidget {
  final DrumElement drum;
  final Function(String, double, String) onSave;

  const DrumSettingsDialog({
    super.key,
    required this.drum,
    required this.onSave,
  });

  @override
  State<DrumSettingsDialog> createState() => _DrumSettingsDialogState();
}

class _DrumSettingsDialogState extends State<DrumSettingsDialog> {
  late TextEditingController _nameController;
  late double _volume;
  late String _soundFilter;
  
  final List<String> _filterOptions = ['normal', 'reverb', 'delay', 'distortion'];
  
  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.drum.name);
    _volume = widget.drum.volume;
    _soundFilter = widget.drum.soundFilter;
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Configure ${widget.drum.name}'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Volume'),
            Slider(
              value: _volume,
              min: 0.0,
              max: 1.0,
              divisions: 10,
              label: (_volume * 100).toStringAsFixed(0) + '%',
              onChanged: (value) {
                setState(() {
                  _volume = value;
                });
              },
            ),
            const SizedBox(height: 20),
            const Text('Sound Filter'),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8.0,
              children: _filterOptions.map((filter) {
                return ChoiceChip(
                  label: Text(filter.toUpperCase()),
                  selected: _soundFilter == filter,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _soundFilter = filter;
                      });
                    }
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onSave(
              _nameController.text,
              _volume,
              _soundFilter,
            );
            Navigator.of(context).pop();
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}

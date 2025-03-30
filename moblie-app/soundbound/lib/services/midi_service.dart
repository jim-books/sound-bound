import 'dart:async';
import 'package:flutter/foundation.dart';

class MidiMessage {
  final int command;
  final int note;
  final int velocity;
  final int channel;
  final DateTime timestamp;

  MidiMessage({
    required this.command,
    required this.note,
    required this.velocity,
    required this.channel,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  // Convert raw MIDI data to MidiMessage
  factory MidiMessage.fromBytes(List<int> data) {
    if (data.length < 3) {
      throw ArgumentError('MIDI message requires at least 3 bytes');
    }
    
    final statusByte = data[0];
    final command = statusByte & 0xF0; // Extract command (high nibble)
    final channel = statusByte & 0x0F; // Extract channel (low nibble)
    final note = data[1];
    final velocity = data[2];
    
    return MidiMessage(
      command: command,
      note: note,
      velocity: velocity,
      channel: channel,
    );
  }
  
  // Check if this is a note-on message (with non-zero velocity)
  bool get isNoteOn => command == 0x90 && velocity > 0;
  
  // Check if this is a note-off message (or note-on with zero velocity)
  bool get isNoteOff => command == 0x80 || (command == 0x90 && velocity == 0);
  
  @override
  String toString() {
    return 'MidiMessage(command: 0x${command.toRadixString(16)}, note: $note, velocity: $velocity, channel: $channel)';
  }
}

class MidiService with ChangeNotifier {
  // Map of MIDI note numbers to drum IDs
  final Map<int, String> _noteToIdMap = {
    36: 'kick',     // Bass Drum 1
    38: 'snare',    // Snare Drum 1
    42: 'hihat',    // Closed Hi-Hat
    45: 'tom1',     // Low Tom
    48: 'tom2',     // Hi-Mid Tom
    49: 'crash',    // Crash Cymbal 1
    51: 'ride',     // Ride Cymbal 1
  };
  
  // Stream controller for MIDI events
  final StreamController<MidiMessage> _midiStreamController = StreamController<MidiMessage>.broadcast();
  Stream<MidiMessage> get midiStream => _midiStreamController.stream;
  
  // Most recently active drum ID
  String? _activeDrumId;
  String? get activeDrumId => _activeDrumId;
  
  // Process raw MIDI data
  void processMidiData(List<int> data) {
    try {
      final midiMessage = MidiMessage.fromBytes(data);
      
      if (midiMessage.isNoteOn) {
        final drumId = _noteToIdMap[midiMessage.note];
        if (drumId != null) {
          _activeDrumId = drumId;
          notifyListeners();
          
          // Reset active drum after a short delay
          Future.delayed(const Duration(milliseconds: 300), () {
            _activeDrumId = null;
            notifyListeners();
          });
        }
      }
      
      // Broadcast the MIDI message
      _midiStreamController.add(midiMessage);
    } catch (e) {
      debugPrint('Error processing MIDI data: $e');
    }
  }
  
  // Determine drum ID from a MIDI note number
  String? getDrumIdForMidiNote(int note) {
    return _noteToIdMap[note];
  }
  
  @override
  void dispose() {
    _midiStreamController.close();
    super.dispose();
  }
}

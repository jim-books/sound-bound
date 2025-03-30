import 'package:flutter/material.dart';

class DrumElement {
  final String id;
  String name;
  double volume;
  String soundFilter;
  Offset position;

  DrumElement({
    required this.id,
    required this.name,
    this.volume = 1.0,
    this.soundFilter = 'normal',
    required this.position,
  });
}

class DrumConfigModel extends ChangeNotifier {
  double _sittingHeight = 0.0;
  final List<DrumElement> _drumElements = [];
  
  // Getters
  double get sittingHeight => _sittingHeight;
  List<DrumElement> get drumElements => List.unmodifiable(_drumElements);
  
  // Methods to update sitting height
  void setSittingHeight(double height) {
    _sittingHeight = height;
    notifyListeners();
  }
  
  // Methods to manage drum elements
  void addDrumElement(DrumElement element) {
    _drumElements.add(element);
    notifyListeners();
  }
  
  void updateDrumPosition(String id, Offset newPosition) {
    final index = _drumElements.indexWhere((element) => element.id == id);
    if (index != -1) {
      _drumElements[index].position = newPosition;
      notifyListeners();
    }
  }
  
  void updateDrumSettings(String id, {String? name, double? volume, String? soundFilter}) {
    final index = _drumElements.indexWhere((element) => element.id == id);
    if (index != -1) {
      if (name != null) _drumElements[index].name = name;
      if (volume != null) _drumElements[index].volume = volume;
      if (soundFilter != null) _drumElements[index].soundFilter = soundFilter;
      notifyListeners();
    }
  }
  
  void removeDrumElement(String id) {
    _drumElements.removeWhere((element) => element.id == id);
    notifyListeners();
  }
}

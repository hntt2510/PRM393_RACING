import 'package:flutter/material.dart';

class Horse {
  final int id;
  final String name;
  final Color color;
  double position; // 0.0 - 1.0 cho animation
  double speed; // Tốc độ ngẫu nhiên

  Horse({
    required this.id,
    required this.name,
    required this.color,
    this.position = 0.0,
    this.speed = 1.0,
  });

  Horse copyWith({
    int? id,
    String? name,
    Color? color,
    double? position,
    double? speed,
  }) {
    return Horse(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      position: position ?? this.position,
      speed: speed ?? this.speed,
    );
  }
}

// Purpose: Model for lottery ball in the drawing machine
// Author: Auto-generated

import 'package:flutter/material.dart';

class LotteryBall {
  final String number;
  Offset position;
  bool isSelected;
  final Color color;

  LotteryBall({
    required this.number,
    required this.position,
    this.isSelected = false,
    Color? color,
  }) : color = color ?? _generateBallColor(number);

  /// Generate a color based on the ball number
  static Color _generateBallColor(String number) {
    final int numValue = int.tryParse(number) ?? 0;
    final colors = [
      Colors.amber,
      Colors.orange,
      Colors.yellow.shade700,
      Colors.amber.shade700,
      Colors.orange.shade700,
    ];
    return colors[numValue % colors.length];
  }

  /// Create a copy of the ball with updated properties
  LotteryBall copyWith({
    String? number,
    Offset? position,
    bool? isSelected,
    Color? color,
  }) {
    return LotteryBall(
      number: number ?? this.number,
      position: position ?? this.position,
      isSelected: isSelected ?? this.isSelected,
      color: color ?? this.color,
    );
  }

  @override
  String toString() {
    return 'LotteryBall(number: $number, position: $position, isSelected: $isSelected)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LotteryBall && other.number == number;
  }

  @override
  int get hashCode => number.hashCode;
}
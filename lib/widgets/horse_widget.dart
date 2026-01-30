import 'package:flutter/material.dart';
import '../models/horse.dart';

class HorseWidget extends StatelessWidget {
  final Horse horse;
  final bool isWinner;
  final double? size;

  const HorseWidget({
    super.key,
    required this.horse,
    this.isWinner = false,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    final horseSize = size ?? 60.0;

    return Stack(
      alignment: Alignment.center,
      children: [
        // Horse body với shadow để tạo độ sâu
        Container(
          width: horseSize,
          height: horseSize * 0.8,
          decoration: BoxDecoration(
            color: horse.color,
            borderRadius: BorderRadius.circular(horseSize * 0.3),
            border: Border.all(
              color: Colors.brown.shade700,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 4,
                offset: const Offset(2, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Horse head
              Container(
                width: horseSize * 0.4,
                height: horseSize * 0.3,
                decoration: BoxDecoration(
                  color: horse.color.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(horseSize * 0.15),
                ),
              ),
              const SizedBox(height: 4),
              // Horse name
              Text(
                horse.name,
                style: TextStyle(
                  fontSize: horseSize * 0.15,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      color: Colors.black.withValues(alpha: 0.5),
                      blurRadius: 2,
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        // Winner decoration
        if (isWinner)
          Positioned(
            top: -horseSize * 0.2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withValues(alpha: 0.5),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Text(
                'WINNER!',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

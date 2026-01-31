import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../models/horse.dart';

class HorseWidget extends StatelessWidget {
  final Horse horse;
  final bool isWinner;
  final double? size;
  final bool isRacing;

  const HorseWidget({
    super.key,
    required this.horse,
    this.isWinner = false,
    this.size,
    this.isRacing = false,
  });

  @override
  Widget build(BuildContext context) {
    final horseSize = size ?? 60.0;

    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        // Glow effect for winner
        if (isWinner)
          Container(
            width: horseSize * 1.5,
            height: horseSize * 1.5,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  horse.color.withOpacity(0.4),
                  horse.color.withOpacity(0.1),
                  horse.color.withOpacity(0.0),
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),
        // Lottie Animation Container với background đẹp và màu sắc
        Container(
          width: horseSize * 1.2,
          height: horseSize * 1.2,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                horse.color.withOpacity(0.2),
                horse.color.withOpacity(0.05),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: horse.color.withOpacity(0.3),
                blurRadius: isWinner ? 15 : 8,
                spreadRadius: isWinner ? 4 : 2,
              ),
            ],
          ),
          child: ClipOval(
            child: Transform(
              // Xoay ngựa để đầu hướng về phía finish line (bên phải)
              alignment: Alignment.center,
              transform: Matrix4.identity()..scale(-1.0, 1.0), // Flip ngang để đầu về bên phải
              child: ColorFiltered(
                // Áp dụng màu của ngựa lên animation với nhiều blend mode để màu đẹp hơn
                colorFilter: ColorFilter.matrix([
                  // Matrix để tạo màu từ RGB của horse.color
                  (horse.color.red / 255) * 0.3, 0, 0, 0, 0,
                  0, (horse.color.green / 255) * 0.3, 0, 0, 0,
                  0, 0, (horse.color.blue / 255) * 0.3, 0, 0,
                  0, 0, 0, 1, 0,
                ]),
                child: Lottie.asset(
                  'assets/animations/horse_run.json',
                  width: horseSize * 1.2,
                  height: horseSize * 1.2,
                  fit: BoxFit.contain,
                  repeat: isRacing || isWinner,
                  animate: true,
                  frameRate: FrameRate.max,
                ),
              ),
            ),
          ),
        ),
        // Horse name badge với design đẹp (chỉ hiển thị khi racing hoặc winner)
        if (isRacing || isWinner)
          Positioned(
            bottom: -horseSize * 0.3,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    horse.color,
                    horse.color.withOpacity(0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: horse.color.withOpacity(0.5),
                    blurRadius: 8,
                    spreadRadius: 2,
                    offset: const Offset(0, 3),
                  ),
                ],
                border: Border.all(
                  color: Colors.white.withOpacity(0.8),
                  width: 2,
                ),
              ),
              child: Text(
                horse.name,
                style: TextStyle(
                  fontSize: horseSize * 0.2,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.8,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.7),
                      blurRadius: 4,
                      offset: const Offset(1, 1),
                    ),
                  ],
                ),
              ),
            ),
          ),
        // Winner decoration với animation effect đẹp hơn - đặt phía trên, không đè ngựa
        if (isWinner)
          Positioned(
            top: -horseSize * 0.5, // Đặt cao hơn để không đè lên ngựa
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: horseSize * 1.6, // Giới hạn chiều rộng tối đa
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: horseSize * 0.15,
                  vertical: horseSize * 0.1,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.amber.shade400,
                      Colors.orange.shade600,
                      Colors.red.shade500,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.amber.withOpacity(0.9),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                    BoxShadow(
                      color: Colors.orange.withOpacity(0.7),
                      blurRadius: 25,
                      spreadRadius: 3,
                    ),
                  ],
                  border: Border.all(
                    color: Colors.white,
                    width: 4,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.emoji_events,
                      color: Colors.white,
                      size: horseSize * 0.2,
                    ),
                    SizedBox(width: horseSize * 0.05),
                    Flexible(
                      child: Text(
                        'WINNER!',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: horseSize * 0.16,
                          letterSpacing: 1.0,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.7),
                              blurRadius: 6,
                              offset: const Offset(2, 2),
                            ),
                          ],
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        // Speed lines effect khi đang chạy (phía sau ngựa, bên trái vì ngựa chạy sang phải)
        if (isRacing && !isWinner)
          Positioned(
            right: horseSize * 1.1, // Đặt bên phải vì ngựa đã flip, speed lines ở phía sau
            child: Opacity(
              opacity: 0.7,
              child: Container(
                width: horseSize * 0.25,
                height: horseSize * 0.7,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerRight,
                    end: Alignment.centerLeft,
                    colors: [
                      horse.color.withOpacity(0.0),
                      horse.color.withOpacity(0.4),
                      horse.color.withOpacity(0.6),
                      horse.color.withOpacity(0.4),
                      horse.color.withOpacity(0.0),
                    ],
                    stops: const [0.0, 0.3, 0.5, 0.7, 1.0],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

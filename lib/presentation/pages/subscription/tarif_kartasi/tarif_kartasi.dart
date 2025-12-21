import 'package:flutter/material.dart';
import 'package:dotted_line/dotted_line.dart';

class VerticalGrowingDots extends StatelessWidget {
  const VerticalGrowingDots({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      height: 220,
      child: Column(
        children: [
          _circle(10, Colors.deepPurple.shade200),

          _dotted(),

          _circle(10, Colors.deepPurple.shade300),

          _dotted(),

          _circle(10, Colors.deepPurple),
        ],
      ),
    );
  }

  Widget _dotted() {
    return Expanded(
      child: DottedLine(
        direction: Axis.vertical,
        lineThickness: 2,
        dashLength: 6,
        dashGapLength: 6,
        dashColor: Colors.deepPurple.shade100,
      ),
    );
  }

  Widget _circle(double radius, Color color) {
    return Container(
      width: radius * 2,
      height: radius * 2,
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}

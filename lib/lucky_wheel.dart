import 'dart:math';
import 'package:flutter/material.dart';

class LuckyWheel extends StatefulWidget {
  @override
  _LuckyWheelState createState() => _LuckyWheelState();
}

class _LuckyWheelState extends State<LuckyWheel> {
  double _degrees = 0;

  void _spinWheel() {
    setState(() {
      _degrees = Random().nextInt(3600).toDouble() - 1800;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Transform.rotate(
          angle: _degrees * pi / 180,
          child: Container(
            width: 200,
            height: 200,
            child: CustomPaint(
              painter: WheelPainter(),
            ),
          ),
        ),
        ElevatedButton(
          onPressed: _spinWheel,
          child: Text('Spin'),
        ),
      ],
    );
  }
}

class WheelPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width / 2, size.height / 2) - 20;

    canvas.drawCircle(center, radius, paint);

    final textPainter = TextPainter(
      text: TextSpan(
        text: '1',
        style: TextStyle(
          color: Colors.blue,
          fontSize: 30,
          fontWeight: FontWeight.bold,
        ),
      ),
      textAlign: TextAlign.center,
    );

    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        center.dx - textPainter.width / 2,
        center.dy - textPainter.height / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lucky Wheel',
      home: Scaffold(
        appBar: AppBar(
          title: Text('Lucky Wheel'),
        ),
        body: Center(
          child: LuckyWheel(),
        ),
      ),
    );
  }
}
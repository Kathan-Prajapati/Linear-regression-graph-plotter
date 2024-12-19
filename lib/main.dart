import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: FitLineScreen(),
    );
  }
}

class FitLineScreen extends StatefulWidget {
  @override
  _FitLineScreenState createState() => _FitLineScreenState();
}

class _FitLineScreenState extends State<FitLineScreen> {
  final TextEditingController _pointsController = TextEditingController();
  final List<FlSpot> _points = [];
  List<FlSpot> _linePoints = [];

  double _minX = 0;
  double _maxX = 10;
  double _minY = 0;
  double _maxY = 10;
  double _rCoefficient = 0;

  void _calculateFitLine() {
    List<String> inputPoints = _pointsController.text.split(';');
    _points.clear();

    double newMinX = double.infinity;
    double newMaxX = -double.infinity;
    double newMinY = double.infinity;
    double newMaxY = -double.infinity;

    for (var point in inputPoints) {
      var coords = point.split(',');
      if (coords.length == 2) {
        double x = double.parse(coords[0].trim());
        double y = double.parse(coords[1].trim());

        newMinX = x < newMinX ? x : newMinX;
        newMaxX = x > newMaxX ? x : newMaxX;
        newMinY = y < newMinY ? y : newMinY;
        newMaxY = y > newMaxY ? y : newMaxY;

        x = x < _minX ? _minX : (x > _maxX ? _maxX : x);
        y = y < _minY ? _minY : (y > _maxY ? _maxY : y);

        _points.add(FlSpot(x, y));
      }
    }

    if (newMinX < _minX || newMaxX > _maxX || newMinY < _minY || newMaxY > _maxY) {
      setState(() {
        _minX = newMinX - 1;
        _maxX = newMaxX + 1;
        _minY = newMinY - 1;
        _maxY = newMaxY + 1;
      });
    }

    int n = _points.length;
    double sumX = 0.00, sumY = 0.00, sumXY = 0.00, sumX2 = 0.00;

    for (var point in _points) {
      sumX += point.x;
      sumY += point.y;
      sumXY += point.x * point.y;
      sumX2 += point.x * point.x;
    }

    double m = (n * sumXY - sumX * sumY) / (n * sumX2 - sumX * sumX);
    double c = (sumY - m * sumX) / n;

    _linePoints.clear();
    double minX = _points.map((e) => e.x).reduce((a, b) => a < b ? a : b);
    double maxX = _points.map((e) => e.x).reduce((a, b) => a > b ? a : b);

    for (double x = minX; x <= maxX; x += 0.1) {
      double y = m * x + c;
      y = y < _minY ? _minY : (y > _maxY ? _maxY : y);

      _linePoints.add(FlSpot(x, y));
    }

    // Calculate the coefficient of determination (R)
    double sumXYDiff = 0;
    double sumXDiff = 0;
    double sumYDiff = 0;
    double sumXSqDiff = 0;
    double sumYSqDiff = 0;

    for (var point in _points) {
      double predictedY = m * point.x + c;
      sumXYDiff += (point.x - sumX / n) * (point.y - sumY / n);
      sumXDiff += (point.x - sumX / n) * (point.x - sumX / n);
      sumYDiff += (point.y - sumY / n) * (point.y - sumY / n);
    }

    _rCoefficient = sumXYDiff / sqrt(sumXDiff * sumYDiff);

    setState(() {});
  }

  void _increaseMinX() {
    setState(() {
      _minX += 10;
    });
  }

  void _decreaseMinX() {
    setState(() {
      _minX -= 10;
    });
  }

  void _resetMinX() {
    setState(() {
      _minX = 0;
    });
  }

  void _increaseMaxX() {
    setState(() {
      _maxX += 10;
    });
  }

  void _decreaseMaxX() {
    setState(() {
      _maxX -= 10;
    });
  }

  void _resetMaxX() {
    setState(() {
      _maxX = 10;
    });
  }

  void _increaseMinY() {
    setState(() {
      _minY += 10;
    });
  }

  void _decreaseMinY() {
    setState(() {
      _minY -= 10;
    });
  }

  void _resetMinY() {
    setState(() {
      _minY = 0;
    });
  }

  void _increaseMaxY() {
    setState(() {
      _maxY += 10;
    });
  }

  void _decreaseMaxY() {
    setState(() {
      _maxY -= 10;
    });
  }

  void _resetMaxY() {
    setState(() {
      _maxY = 10;
    });
  }

  @override
  Widget build(BuildContext context) {
    double sumX = 0, sumY = 0, sumXY = 0, sumX2 = 0;
    int n = _points.length;
    for (var point in _points) {
      sumX += point.x;
      sumY += point.y;
      sumXY += point.x * point.y;
      sumX2 += point.x * point.x;
    }

    double m = (n * sumXY - sumX * sumY) / (n * sumX2 - sumX * sumX);
    double c = (sumY - m * sumX) / n;
    String equation;
    if (c >= 0) {
      equation = 'y = ${m.toStringAsFixed(4)}x + ${c.toStringAsFixed(4)}';
    } else {
      c = c * (-1);
      equation = 'y = ${m.toStringAsFixed(4)}x - ${c.toStringAsFixed(4)}';
    }

    String relationshipMessage;

    if (_rCoefficient <= 0.5 && _rCoefficient >= -0.5) {
      relationshipMessage = "It's unwise to use a linear regression model for your data.";
    } else if ((_rCoefficient > 0.5 && _rCoefficient < 0.8) || (_rCoefficient < -0.5 && _rCoefficient > -0.8)) {
      relationshipMessage = "It's acceptable to use a linear regression model for your data.";
    } else {
      relationshipMessage = "A linear model will be most accurate for your data.";
    }

    return Scaffold(
      appBar: AppBar(title: Text('Best Fit Line Calculator')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _pointsController,
              decoration: InputDecoration(
                labelText: 'Enter Points (x,y) separated by semicolons',
                hintText: 'e.g., 1,2; 2,3; 3,5',
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _calculateFitLine,
              child: Text('Calculate Best Fit Line'),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('X Min:'),
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: _decreaseMinX,
                          child: Text('Decrease X Min'),
                        ),
                        SizedBox(width: 10),
                        Text('${_minX.toStringAsFixed(1)}'),
                        SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: _increaseMinX,
                          child: Text('Increase X Min'),
                        ),
                      ],
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('X Max:'),
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: _decreaseMaxX,
                          child: Text('Decrease X Max'),
                        ),
                        SizedBox(width: 10),
                        Text('${_maxX.toStringAsFixed(1)}'),
                        SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: _increaseMaxX,
                          child: Text('Increase X Max'),
                        ),
                      ],
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Y Min:'),
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: _decreaseMinY,
                          child: Text('Decrease Y Min'),
                        ),
                        SizedBox(width: 10),
                        Text('${_minY.toStringAsFixed(1)}'),
                        SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: _increaseMinY,
                          child: Text('Increase Y Min'),
                        ),
                      ],
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Y Max:'),
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: _decreaseMaxY,
                          child: Text('Decrease Y Max'),
                        ),
                        SizedBox(width: 10),
                        Text('${_maxY.toStringAsFixed(1)}'),
                        SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: _increaseMaxY,
                          child: Text('Increase Y Max'),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 10),
            // Reset Buttons Row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _resetMinX,
                  child: Text('Reset X Min'),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _resetMaxX,
                  child: Text('Reset X Max'),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _resetMinY,
                  child: Text('Reset Y Min'),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _resetMaxY,
                  child: Text('Reset Y Max'),
                ),
              ],
            ),
            SizedBox(height: 20),
            Expanded(
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(show: true),
                  borderData: FlBorderData(show: true),
                  minX: _minX,
                  maxX: _maxX,
                  minY: _minY,
                  maxY: _maxY,
                  lineBarsData: [
                    LineChartBarData(
                      spots: _points,
                      isCurved: false,
                      color: Colors.white,
                      dotData: FlDotData(show: true),
                      belowBarData: BarAreaData(show: false),
                    ),
                    LineChartBarData(
                      spots: _linePoints,
                      isCurved: false,
                      dotData: FlDotData(show: false),
                      belowBarData: BarAreaData(show: false),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Equation: $equation',
              style: TextStyle(fontSize: 18, color: Colors.purple, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Align(
              alignment: Alignment.bottomRight,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'R: ${_rCoefficient.toStringAsFixed(3)}',
                    style: TextStyle(fontSize: 18, color: Colors.orange, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 5),
                  Text(
                    relationshipMessage,
                    style: TextStyle(fontSize: 16, color: Colors.blue, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}













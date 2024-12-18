import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

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

  void _calculateFitLine() {
    List<String> inputPoints = _pointsController.text.split(';');
    _points.clear();
    for (var point in inputPoints) {
      var coords = point.split(',');
      if (coords.length == 2) {
        double x = double.parse(coords[0].trim());
        double y = double.parse(coords[1].trim());
        _points.add(FlSpot(x, y));
      }
    }

    int n = _points.length;
    double sumX = 0, sumY = 0, sumXY = 0, sumX2 = 0;

    for (var point in _points) {
      sumX += point.x;
      sumY += point.y;
      sumXY += point.x * point.y;
      sumX2 += point.x * point.x;
    }

    double m = (n * sumXY - sumX * sumY) / (n * sumX2 - sumX * sumX);  // Slope
    double c = (sumY - m * sumX) / n;  // Intercept

    _linePoints.clear();
    double minX = _points.map((e) => e.x).reduce((a, b) => a < b ? a : b);
    double maxX = _points.map((e) => e.x).reduce((a, b) => a > b ? a : b);

    for (double x = minX; x <= maxX; x += 0.1) {
      _linePoints.add(FlSpot(x, m * x + c));
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // Calculate the equation of the line
    double sumX = 0, sumY = 0, sumXY = 0, sumX2 = 0;
    int n = _points.length;
    for (var point in _points) {
      sumX += point.x;
      sumY += point.y;
      sumXY += point.x * point.y;
      sumX2 += point.x * point.x;
    }

    double m = (n * sumXY - sumX * sumY) / (n * sumX2 - sumX * sumX);  // Slope
    double c = (sumY - m * sumX) / n;  // Intercept
    String equation = 'y = ${m.toStringAsFixed(2)}x + ${c.toStringAsFixed(2)}';

    return Scaffold(
      appBar: AppBar(title: Text('Best Fit Line App')),
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
            // Scaling options in one row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // X Min Slider
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('X Min:'),
                    Slider(
                      min: -20,
                      max: 20,
                      value: _minX,
                      onChanged: (value) {
                        setState(() {
                          _minX = value;
                        });
                      },
                    ),
                    Text('${_minX.toStringAsFixed(1)}'),
                  ],
                ),
                // X Max Slider
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('X Max:'),
                    Slider(
                      min: -20,
                      max: 20,
                      value: _maxX,
                      onChanged: (value) {
                        setState(() {
                          _maxX = value;
                        });
                      },
                    ),
                    Text('${_maxX.toStringAsFixed(1)}'),
                  ],
                ),
                // Y Min Slider
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Y Min:'),
                    Slider(
                      min: -20,
                      max: 20,
                      value: _minY,
                      onChanged: (value) {
                        setState(() {
                          _minY = value;
                        });
                      },
                    ),
                    Text('${_minY.toStringAsFixed(1)}'),
                  ],
                ),
                // Y Max Slider
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Y Max:'),
                    Slider(
                      min: -20,
                      max: 20,
                      value: _maxY,
                      onChanged: (value) {
                        setState(() {
                          _maxY = value;
                        });
                      },
                    ),
                    Text('${_maxY.toStringAsFixed(1)}'),
                  ],
                ),
              ],
            ),
            SizedBox(height: 20),
            // Graph
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
                      color: Colors.blue,
                      dotData: FlDotData(
                        show: true,  // Show dots at each point
                      ),
                      belowBarData: BarAreaData(show: false),
                    ),
                    LineChartBarData(
                      spots: _linePoints,
                      isCurved: false,
                      color: Colors.red,
                      dotData: FlDotData(show: false),  // No dots for the red line
                      belowBarData: BarAreaData(show: false),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Equation: $equation',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}








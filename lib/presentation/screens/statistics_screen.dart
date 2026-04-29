import 'package:flutter/material.dart';
import 'package:smart_home_pro/core/constants/colors.dart';
import 'package:smart_home_pro/services/firebase_service.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:math' as math;

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  bool _isLoading = true;
  
  Map<String, double> _deviceUsage = {};
  double _totalUnits = 0;
  double _allowedUnits = 10;
  String _warningState = 'NORMAL';
  String _peakStart = '18:00';
  String _peakEnd = '23:00';
  
  final Map<String, String> _deviceLabels = {
    'light1': 'Lights',
    'fan1': 'Fan',
    'curtain1': 'Curtains',
    'motor1': 'Water Motor',
  };
  
  final Map<String, Color> _deviceColors = {
    'light1': AppColors.accentAmber,
    'fan1': AppColors.primaryBlue,
    'curtain1': AppColors.accentPurple,
    'motor1': AppColors.primaryGreen,
  };

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.wait([
      _loadUsageData(),
      _loadSettings(),
    ]);
    setState(() => _isLoading = false);
  }

  Future<void> _loadUsageData() async {
    final devicesSnapshot = await FirebaseService.database.child('usage/devices').once();
    if (devicesSnapshot.snapshot.value != null) {
      final devices = devicesSnapshot.snapshot.value as Map<dynamic, dynamic>;
      _deviceUsage.clear();
      devices.forEach((key, value) {
        _deviceUsage[key.toString()] = (value as num).toDouble();
      });
    }
    
    final totalSnapshot = await FirebaseService.database.child('usage/total_consumed_units').once();
    if (totalSnapshot.snapshot.value != null) {
      _totalUnits = (totalSnapshot.snapshot.value as num).toDouble();
    }
    
    final warningSnapshot = await FirebaseService.database.child('usage/warning_state').once();
    if (warningSnapshot.snapshot.value != null) {
      _warningState = warningSnapshot.snapshot.value.toString();
    }
  }

  Future<void> _loadSettings() async {
    final allowedSnapshot = await FirebaseService.database.child('settings/allowed_units').once();
    if (allowedSnapshot.snapshot.value != null) {
      _allowedUnits = (allowedSnapshot.snapshot.value as num).toDouble();
    }
    
    final peakStartSnap = await FirebaseService.database.child('settings/peak_start').once();
    if (peakStartSnap.snapshot.value != null) {
      _peakStart = peakStartSnap.snapshot.value.toString();
    }
    
    final peakEndSnap = await FirebaseService.database.child('settings/peak_end').once();
    if (peakEndSnap.snapshot.value != null) {
      _peakEnd = peakEndSnap.snapshot.value.toString();
    }
  }

  double _getTotalCost() {
    return _totalUnits * 25;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.bgLightBlue,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final totalCost = _getTotalCost();
    final unitPercentage = (_totalUnits / _allowedUnits * 100).clamp(0, 100);
    final sortedDevices = _deviceUsage.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    return Scaffold(
      backgroundColor: AppColors.bgLightBlue,
      appBar: AppBar(
        title: const Text('Statistics'),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Unit Usage Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: _totalUnits >= _allowedUnits ? 
                    LinearGradient(colors: [AppColors.error, AppColors.error.withOpacity(0.8)]) :
                    LinearGradient(colors: [AppColors.primaryBlue, AppColors.primaryBlue.withOpacity(0.8)]),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Energy Consumption', style: TextStyle(color: Colors.white, fontSize: 14)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                        child: Text(_warningState, style: const TextStyle(color: Colors.white, fontSize: 11)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('${_totalUnits.toStringAsFixed(2)} kWh', style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('Limit: $_allowedUnits units', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: unitPercentage / 100,
                    backgroundColor: Colors.white.withOpacity(0.3),
                    color: unitPercentage > 80 ? Colors.orange : Colors.white,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Cost Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: AppColors.cardShadow),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Estimated Cost', style: TextStyle(fontSize: 14, color: AppColors.mediumGray)),
                      Text('Based on PKR 25/unit', style: TextStyle(fontSize: 11, color: AppColors.mediumGray)),
                    ],
                  ),
                  Text('Rs ${totalCost.toStringAsFixed(0)}', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.primaryGreen)),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Device Breakdown
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: AppColors.cardShadow),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Device-wise Breakdown', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 16),
                  
                  // Donut Chart
                  SizedBox(
                    height: 180,
                    child: Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CustomPaint(
                            size: const Size(150, 150),
                            painter: DonutChartPainter(
                              values: _deviceUsage.values.toList(),
                              colors: _deviceUsage.keys.map((k) => _deviceColors[k] ?? AppColors.mediumGray).toList(),
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('${_totalUnits.toStringAsFixed(2)}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                              const Text('Total kWh', style: TextStyle(fontSize: 11, color: AppColors.mediumGray)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Devices List
                  ...sortedDevices.map((entry) {
                    final deviceId = entry.key;
                    final usage = entry.value;
                    final percent = _totalUnits > 0 ? (usage / _totalUnits * 100).round() : 0;
                    final color = _deviceColors[deviceId] ?? AppColors.mediumGray;
                    
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _deviceLabels[deviceId] ?? deviceId,
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                            ),
                          ),
                          Text('${usage.toStringAsFixed(3)} kWh', style: TextStyle(fontSize: 13, color: color, fontWeight: FontWeight.w600)),
                          const SizedBox(width: 8),
                          SizedBox(
                            width: 40,
                            child: Text('$percent%', style: const TextStyle(fontSize: 12, color: AppColors.mediumGray), textAlign: TextAlign.right),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Peak Hours Info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: AppColors.cardShadow),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: AppColors.error.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.timer, color: AppColors.error),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Peak Hours', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                        Text('$_peakStart - $_peakEnd', style: const TextStyle(fontSize: 12, color: AppColors.mediumGray)),
                        const Text('Higher rates apply during this time', style: TextStyle(fontSize: 11, color: AppColors.mediumGray)),
                      ],
                    ),
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

// Donut Chart Painter
class DonutChartPainter extends CustomPainter {
  final List<double> values;
  final List<Color> colors;

  DonutChartPainter({required this.values, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    final total = values.isEmpty ? 1 : values.reduce((a, b) => a + b);
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;
    
    double startAngle = -math.pi / 2;
    
    for (int i = 0; i < values.length; i++) {
      final sweepAngle = (values[i] / total) * 2 * math.pi;
      final paint = Paint()
        ..color = colors[i % colors.length]
        ..style = PaintingStyle.stroke
        ..strokeWidth = 20
        ..strokeCap = StrokeCap.round;
      
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
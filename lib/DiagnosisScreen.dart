import 'dart:convert';
import 'dart:io';
import 'package:calolect/homepage.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'upload screen.dart';

class DiagnosisScreen extends StatelessWidget {
  final String diagnosisClass;
  final File imageFile;
  final double confidence;
  final Map<String, dynamic> diagnosisInfo;
  final List<double> confidenceScores;

  const DiagnosisScreen({
    super.key,
    required this.diagnosisClass,
    required this.imageFile,
    required this.confidence,
    required this.diagnosisInfo,
    required this.confidenceScores,
  });

  // Define all 4 class names and colors for the chart
  static const List<String> chartClassNames = [
    'Irrelevant',
    'Adenocarcinoma',
    'Normal',
    'Squamous Cell'
  ];

  static const List<Color> chartColors = [
    Color(0xFF070707),  // Grey for Irrelevant
    Color(0xFFD32F2F),  // Red for Adeno
    Color(0xFF388E3C),  // Green for Normal
    Color(0xFFFF8C00),  // Orange for Squamous
  ];

  String get diagnosisDescription {
    switch (diagnosisClass) {
      case 'lung_aca':
        return 'Adenocarcinoma is a type of non-small cell lung cancer that begins in mucus-producing cells.';
      case 'lung_n':
        return 'No signs of malignancy detected in the lung tissue.';
      case 'lung_scc':
        return 'Squamous Cell Carcinoma is a type of non-small cell lung cancer that begins in the thin, flat cells lining the airways.';
      case 'irrelvent':
        return 'The uploaded image does not appear to be a valid lung CT scan.';
      default:
        return 'Diagnosis results are being analyzed.';
    }
  }

  Color get diagnosisColor {
    switch (diagnosisClass) {
      case 'lung_aca':
        return chartColors[1]; // Red for Adeno
      case 'lung_n':
        return chartColors[2]; // Green for Normal
      case 'lung_scc':
        return chartColors[3]; // Orange for Squamous
      case 'irrelvent':
        return chartColors[0]; // Grey for Irrelevant
      default:
        return const Color(0xFF020202);
    }
  }

  String get diagnosisTitle {
    switch (diagnosisClass) {
      case 'lung_aca':
        return 'Adenocarcinoma Detected';
      case 'lung_n':
        return 'Normal Lung Tissue';
      case 'lung_scc':
        return 'Squamous Cell Carcinoma Detected';
      case 'irrelvent':
        return 'Irrelevant Image';
      default:
        return 'Analysis Results';
    }
  }

  Future<void> saveToHistory(BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final newEntry = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'diagnosisClass': diagnosisClass,
        'diagnosisTitle': diagnosisTitle,
        'imagePath': imageFile.path,
        'confidence': confidence,
        'confidenceScores': confidenceScores,
        'diagnosisInfo': diagnosisInfo,
        'dateTime': DateTime.now().toIso8601String(),
      };

      final historyList = prefs.getStringList('history') ?? [];
      historyList.add(json.encode(newEntry));
      await prefs.setStringList('history', historyList);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Report saved to history'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save report: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  // Enhanced chart method
  Widget _buildEnhancedChart() {
    // Ensure we have exactly 4 scores for the chart (pad with 0 if needed)
    final chartScores = List<double>.filled(4, 0.0);
    for (int i = 0; i < confidenceScores.length && i < 4; i++) {
      chartScores[i] = confidenceScores[i];
    }

    return Container(
      height: 400,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          const Text(
            'AI Model Confidence Distribution',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Predicted: $diagnosisTitle',
            style: TextStyle(
              color: diagnosisColor,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceBetween,
                  groupsSpace: 20,
                  barGroups: chartScores.asMap().entries.map((entry) {
                    final index = entry.key;
                    final score = entry.value;
                    final isHighest = score == chartScores.reduce((a, b) => a > b ? a : b);

                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: score,
                          color: isHighest ? chartColors[index].withOpacity(1.0) : chartColors[index].withOpacity(0.7),
                          width: 24,
                          borderRadius: BorderRadius.circular(6),
                          // Add gradient effect for the highest bar
                          gradient: isHighest ? LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              chartColors[index],
                              chartColors[index].withOpacity(0.8),
                            ],
                          ) : null,
                        ),
                      ],
                    );
                  }).toList(),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 50,
                        interval: 0.2,
                        getTitlesWidget: (value, meta) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Text(
                            '${(value * 100).toInt()}%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 60,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          final score = chartScores[index];
                          final isHighest = score == chartScores.reduce((a, b) => a > b ? a : b);

                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Column(
                              children: [
                                Transform.rotate(
                                  angle: -0.3,
                                  child: Text(
                                    chartClassNames[index],
                                    style: TextStyle(
                                      color: isHighest ? chartColors[index] : Colors.white,
                                      fontSize: 10,
                                      fontWeight: isHighest ? FontWeight.bold : FontWeight.w500,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${(score * 100).toStringAsFixed(1)}%',
                                  style: TextStyle(
                                    color: isHighest ? chartColors[index] : Colors.white70,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(),
                    rightTitles: const AxisTitles(),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.white.withOpacity(0.4),
                        width: 1,
                      ),
                      left: BorderSide(
                        color: Colors.white.withOpacity(0.4),
                        width: 2,
                      ),
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 0.2,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: Colors.white.withOpacity(0.2),
                      strokeWidth: 1,
                      dashArray: [5, 3],
                    ),
                  ),
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchCallback: (FlTouchEvent event, BarTouchResponse? response) {
                      // Handle touch events if needed
                    },
                    touchTooltipData: BarTouchTooltipData(
                      tooltipBorderRadius: BorderRadius.circular(13),
                      tooltipPadding: const EdgeInsets.all(8),
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final className = chartClassNames[group.x.toInt()];
                        final confidence = rod.toY;
                        return BarTooltipItem(
                          '$className\n${(confidence * 100).toStringAsFixed(1)}%',
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        );
                      },
                    ),
                  ),
                  maxY: 1.0,
                  minY: 0.0,
                ),
              ),
            ),
          ),

        ],
      ),
    );
  }

  // Results summary method
  Widget _buildResultsSummary() {
    // Find the highest confidence score and its index
    double maxConfidence = confidenceScores.reduce((a, b) => a > b ? a : b);
    int maxIndex = confidenceScores.indexOf(maxConfidence);

    // Get second highest for comparison
    List<double> sortedScores = List.from(confidenceScores)..sort((a, b) => b.compareTo(a));
    double secondHighest = sortedScores.length > 1 ? sortedScores[1] : 0.0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: diagnosisColor.withOpacity(0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Analysis Summary',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: diagnosisColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Primary Diagnosis: $diagnosisTitle',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: diagnosisColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Confidence Level: ${(maxConfidence * 100).toStringAsFixed(1)}%',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Certainty: ${maxConfidence - secondHighest > 0.3 ? "High" : maxConfidence - secondHighest > 0.1 ? "Moderate" : "Low"}',
            style: TextStyle(
              fontSize: 14,
              color: maxConfidence - secondHighest > 0.3 ? Colors.green :
              maxConfidence - secondHighest > 0.1 ? Colors.orange : Colors.red,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF184542).withOpacity(0.9),
              const Color(0xFF6AB4BC).withOpacity(0.9),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Image.asset(
                        'assets/logo.png',
                        height: 50,
                        errorBuilder: (context, error, stackTrace) => const Icon(
                          Icons.broken_image,
                          color: Colors.white,
                          size: 50,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.home, color: Colors.white),
                        onPressed: () => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const HomePage()),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Diagnosis Report',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Confidence: ${(confidence * 100).toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: Image.file(
                      imageFile,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Center(
                        child: Icon(
                          Icons.broken_image,
                          size: 50,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      border: Border.all(
                        color: diagnosisColor.withOpacity(0.5),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Text(
                            diagnosisTitle,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: diagnosisColor,
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),
                        Text(
                          diagnosisDescription,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 20),
                        if (diagnosisInfo['severity'] != null)
                          _buildDiagnosisItem('Severity', diagnosisInfo['severity'].toString()),
                        if (diagnosisInfo['stage'] != null)
                          _buildDiagnosisItem('Stage', diagnosisInfo['stage'].toString()),
                        if (diagnosisInfo['recommendation'] != null)
                          _buildDiagnosisItem('Recommendation', diagnosisInfo['recommendation'].toString()),
                        if (diagnosisInfo['followUp'] != null)
                          _buildDiagnosisItem('Follow Up', diagnosisInfo['followUp'].toString()),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  _buildResultsSummary(),
                  const SizedBox(height: 20),
                  _buildEnhancedChart(),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => saveToHistory(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF184542),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'SAVE TO HISTORY',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => UploadScreen()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: const BorderSide(color: Colors.white),
                          ),
                          child: const Text('NEW SCAN'),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => const HomePage()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: const BorderSide(color: Colors.white),
                          ),
                          child: const Text('HOME'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Note: This AI analysis is for informational purposes only. Always consult a medical professional for diagnosis.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDiagnosisItem(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
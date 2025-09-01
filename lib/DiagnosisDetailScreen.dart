import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'history items.dart';

class DiagnosisDetailScreen extends StatelessWidget {
  final HistoryItem item;
  const DiagnosisDetailScreen({Key? key, required this.item}) : super(key: key);

  Color get diagnosisColor {
    switch (item.diagnosisClass) {
      case 'lung_aca':
        return Colors.red;
      case 'lung_n':
        return Colors.green;
      case 'lung_scc':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String get diagnosisDescription {
    switch (item.diagnosisClass) {
      case 'lung_aca':
        return 'Adenocarcinoma (Lung ACA) is a type of non-small cell lung cancer.';
      case 'lung_n':
        return 'No cancer detected. The lung is healthy.';
      case 'lung_scc':
        return 'Squamous Cell Carcinoma (Lung SCC) is a form of non-small cell lung cancer.';
      default:
        return 'Unknown diagnosis';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/logo.png', height: 50),
            SizedBox(width: 10),
          ],
        ),
        backgroundColor: Color(0xFF184542),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF184542),
              Color(0xFF6AB4BC),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Diagnosis Details',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Card(
                          elevation: 6,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Color(0xFF4D6160),
                                  Color(0xFF3B6265),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Center(
                                    child: Container(
                                      width: 150,
                                      height: 150,
                                      decoration: BoxDecoration(
                                        border: Border.all(color: diagnosisColor),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: item.imagePath != null
                                          ? Image.file(
                                        File(item.imagePath!),
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) =>
                                            Icon(Icons.error, color: Colors.white),
                                      )
                                          : Icon(Icons.image_not_supported, color: Colors.white),
                                    ),
                                  ),
                                  SizedBox(height: 20),
                                  _DiagnosisRow('Diagnosis', item.diagnosisTitle ?? 'Unknown Diagnosis', Colors.white),
                                  SizedBox(height: 8),
                                  Text(
                                    diagnosisDescription,
                                    style: TextStyle(fontSize: 14, color: Colors.white70),
                                  ),
                                  SizedBox(height: 8),
                                  _DiagnosisRow(
                                    'Date & Time',
                                    item.dateTime != null
                                        ? '${item.dateTime!.day}/${item.dateTime!.month}/${item.dateTime!.year} ${item.dateTime!.hour}:${item.dateTime!.minute.toString().padLeft(2, '0')}'
                                        : 'Unknown Date',
                                    Colors.white,
                                  ),
                                  _DiagnosisRow(
                                    'Confidence',
                                    '${(item.confidence * 100).toStringAsFixed(1)}%',
                                    Colors.white,
                                  ),
                                  if (item.diagnosisInfo['severity'] != null)
                                    _DiagnosisRow(
                                      'Severity',
                                      item.diagnosisInfo['severity']!,
                                      Colors.white,
                                    ),
                                  if (item.diagnosisInfo['stage'] != null)
                                    _DiagnosisRow(
                                      'Stage',
                                      item.diagnosisInfo['stage']!,
                                      Colors.white,
                                    ),
                                  if (item.diagnosisInfo['recommendation'] != null)
                                    _DiagnosisRow(
                                      'Recommendation',
                                      item.diagnosisInfo['recommendation']!,
                                      Colors.white,
                                    ),
                                  if (item.diagnosisInfo['followUp'] != null)
                                    _DiagnosisRow(
                                      'Follow Up',
                                      item.diagnosisInfo['followUp']!,
                                      Colors.white,
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        final prefs = await SharedPreferences.getInstance();
                        final historyList = prefs.getStringList('history') ?? [];
                        final updatedHistory = historyList.where((h) {
                          final map = Map<String, dynamic>.from(json.decode(h));
                          return map['id'] != item.id;
                        }).toList();

                        await prefs.setStringList('history', updatedHistory);

                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Record deleted')),
                        );
                      },
                      child: Text('Delete'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        minimumSize: Size(120, 40),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text('Back'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF184542),
                        foregroundColor: Colors.white,
                        minimumSize: Size(120, 40),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget _DiagnosisRow(String title, String value, Color textColor) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4.0),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$title: ', style: TextStyle(fontWeight: FontWeight.w500, color: textColor)),
        Expanded(child: Text(value, style: TextStyle(color: textColor))),
      ],
    ),
  );
}
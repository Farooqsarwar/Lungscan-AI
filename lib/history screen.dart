import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'DiagnosisDetailScreen.dart';
import 'history items.dart';

class HistoryScreen extends StatefulWidget {
  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<HistoryItem?> _historyItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyList = prefs.getStringList('history') ?? [];

      setState(() {
        _historyItems = historyList.map((item) {
          try {
            final decoded = json.decode(item);
            return HistoryItem.fromMap(decoded is Map<String, dynamic> ? decoded : {});
          } catch (e) {
            print('Error decoding history item: $e');
            return null;
          }
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading history: $e')),
      );
      print(e);
    }
  }

  Future<void> _deleteItem(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final updatedHistory = _historyItems.where((item) => item?.id != id).toList();
      final updatedHistoryStrings = updatedHistory.map((item) => item != null ? json.encode(item.toMap()) : '').toList();

      await prefs.setStringList('history', updatedHistoryStrings);

      setState(() {
        _historyItems = updatedHistory;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting item: $e')),
      );
      print(e);
    }
  }

  Color _getDiagnosisColor(String? diagnosisClass) {
    switch (diagnosisClass) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/logo.png', height: 50),
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
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Diagnosis History',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 30),
              Expanded(
                child: _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : _historyItems.isEmpty
                    ? Center(child: Text('No diagnosis history found', style: TextStyle(color: Colors.white)))
                    : ListView.builder(
                  itemCount: _historyItems.length,
                  itemBuilder: (context, index) {
                    final item = _historyItems[index];
                    if (item == null) return SizedBox.shrink();
                    return Card(
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
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DiagnosisDetailScreen(item: item),
                              ),
                            ).then((_) => _loadHistory());
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: item.imagePath != null
                                      ? Image.file(
                                    File(item.imagePath!),
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => Icon(Icons.error),
                                  )
                                      : Icon(Icons.image_not_supported, color: Colors.white),
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.diagnosisTitle ?? 'Unknown Diagnosis',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      SizedBox(height: 5),
                                      Text(
                                        item.dateTime != null
                                            ? '${item.dateTime!.day}/${item.dateTime!.month}/${item.dateTime!.year} - ${item.dateTime!.hour}:${item.dateTime!.minute.toString().padLeft(2, '0')}'
                                            : 'Unknown Date',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.white70,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _deleteItem(item.id),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
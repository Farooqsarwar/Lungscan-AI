import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

import 'DiagnosisScreen.dart';

class UploadScreen extends StatefulWidget {
  @override
  _UploadScreenState createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  File? _selectedImage;
  late Interpreter _classifierInterpreter;
  bool _modelsLoaded = false;
  bool _isPredicting = false;
  final List<String> classNames = [
    "irrelvent",
    "lung_aca",
    "lung_n",
    "lung_scc"
  ];

  @override
  void initState() {
    super.initState();
    _loadModels();
  }

  Future<void> _loadModels() async {
    try {
      // Load the new model
      _classifierInterpreter =
      await Interpreter.fromAsset('assets/lung_cancer_model.tflite');
      setState(() => _modelsLoaded = true);
    } catch (e) {
      print("Model loading error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Failed to load model. Please restart the app.'),
          backgroundColor: Colors.red.withOpacity(0.8),
        ),
      );
    }
  }

  Future<void> _pickImage() async {
    if (!_modelsLoaded) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Model is loading. Please wait...'),
          backgroundColor: const Color(0x90FFFFFF),
        ),
      );
      return;
    }

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _selectedImage = File(pickedFile.path));
    }
  }

  Future<void> _predictImage() async {
    if (_selectedImage == null) return;

    setState(() => _isPredicting = true);

    try {
      final imageBytes = await _selectedImage!.readAsBytes();
      final image = img.decodeImage(imageBytes);
      if (image == null) throw Exception('Invalid image');

      final input = _preprocessForClassifier(image);
      final output = List.filled(1 * 4, 0.0).reshape([1, 4]);

      _classifierInterpreter.run(input, output);

      List<double> outputValues = List<double>.from(output[0]);
      double maxConfidence = outputValues.reduce((a, b) => a > b ? a : b);
      int predictedIndex = outputValues.indexOf(maxConfidence);
      String predictedClass = classNames[predictedIndex];

      // Create diagnosis info based on the predicted class
      Map<String, dynamic> diagnosisInfo = _getDiagnosisInfo(
          predictedClass, maxConfidence);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              DiagnosisScreen(
                diagnosisClass: predictedClass,
                imageFile: _selectedImage!,
                confidence: maxConfidence,
                confidenceScores: outputValues,
                diagnosisInfo: diagnosisInfo,
              ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Analysis failed. Please try another image.'),
          backgroundColor: const Color(0x90FFFFFF),
        ),
      );
    } finally {
      if (mounted) setState(() => _isPredicting = false);
    }
  }

  List<List<List<List<double>>>> _preprocessForClassifier(img.Image image) {
    // Resize to 224x224 as expected by the new model
    final resized = img.copyResize(image, width: 224, height: 224);
    List<List<List<List<double>>>> input = List.generate(1, (batch) =>
        List.generate(224, (y) =>
            List.generate(224, (x) =>
                List.generate(3, (c) => 0.0))));

    for (int y = 0; y < 224; y++) {
      for (int x = 0; x < 224; x++) {
        final pixel = resized.getPixel(x, y);
        input[0][y][x][0] = pixel.r / 255.0;
        input[0][y][x][1] = pixel.g / 255.0;
        input[0][y][x][2] = pixel.b / 255.0;
      }
    }
    return input;
  }

  Map<String, dynamic> _getDiagnosisInfo(String diagnosisClass,
      double confidence) {
    switch (diagnosisClass) {
      case 'irrelvent':
        return {
          'severity': 'None',
          'stage': 'N/A',
          'recommendation': 'Image not relevant for lung analysis',
          'followUp': 'Please upload a proper lung CT scan',
        };
      case 'lung_aca':
        return {
          'severity': confidence > 0.8 ? 'High' : confidence > 0.6
              ? 'Moderate'
              : 'Low',
          'stage': 'Requires further staging',
          'recommendation': 'Immediate consultation with oncologist',
          'followUp': 'CT scan within 1-2 weeks',
        };
      case 'lung_n':
        return {
          'severity': 'None',
          'stage': 'N/A',
          'recommendation': 'Continue regular screening',
          'followUp': 'Annual chest X-ray',
        };
      case 'lung_scc':
        return {
          'severity': confidence > 0.8 ? 'High' : confidence > 0.6
              ? 'Moderate'
              : 'Low',
          'stage': 'Requires further staging',
          'recommendation': 'Immediate consultation with oncologist',
          'followUp': 'CT scan within 1-2 weeks',
        };
      default:
        return {
          'severity': 'Unknown',
          'stage': 'Unknown',
          'recommendation': 'Consult with specialist',
          'followUp': 'Follow-up as recommended',
        };
    }
  }

  @override
  void dispose() {
    _classifierInterpreter.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF4BA1AE),
        centerTitle: true,
        titleTextStyle: const TextStyle(
          color: Colors.black54,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF4BA1AE),
              Color(0xFF73B5C1),
              Color(0xFF82BDC8),
              Color(0xFF92C6CF),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                const SizedBox(height: 30),
                const Text(
                  'Upload Lung CT Scan',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'For AI-assisted analysis',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(
                      color: const Color(0x90FFFFFF),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFF4BA1AE),
                        width: 2,
                      ),
                    ),
                    child: _selectedImage != null
                        ? ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.file(_selectedImage!, fit: BoxFit.cover),
                    )
                        : const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.cloud_upload,
                          size: 60,
                          color: Colors.black54,
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Tap to select image',
                          style: TextStyle(color: Colors.black87),
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _selectedImage != null ? (_isPredicting ? null : _predictImage) : _pickImage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0x90FFFFFF),
                      foregroundColor: const Color(0xFF4BA1AE),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      // Disable button when loading
                      disabledBackgroundColor: const Color(0x90FFFFFF),
                    ),
                    child: _isPredicting
                        ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        color: Color(0xFF4BA1AE),
                        strokeWidth: 3,
                      ),
                    )
                        : Text(
                      _selectedImage != null ? 'ANALYZE IMAGE' : 'SELECT IMAGE',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),                const SizedBox(height: 20),
                const Text(
                  'For medical purposes only. Consult a doctor for diagnosis.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
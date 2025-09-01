import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:calolect/profile%20screen.dart';
import 'package:calolect/signup%20screen.dart';
import 'package:calolect/upload%20screen.dart';
import 'package:calolect/welcome%20screen.dart';
import 'history screen.dart';
import 'login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://ygvrbylerasqpsttwvrc.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InlndnJieWxlcmFzcXBzdHR3dnJjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTA0MTM0ODUsImV4cCI6MjA2NTk4OTQ4NX0.ertN4k7pfXAmZdpfvHiesYJNsAcbSUTLMVWEEqFOdhE',
  );

  bool isLoggedIn = false;
  String username = '';

  try {
    final supabase = Supabase.instance.client;
    final session = supabase.auth.currentSession;

    isLoggedIn = session != null;
    if (isLoggedIn) {
      // Get user profile data
      final user = supabase.auth.currentUser;
      username = user?.email ?? user!.userMetadata?['username'] ?? '';

      // Store in shared preferences for offline access
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('username', username);
    } else {
      // Check shared preferences as fallback
      final prefs = await SharedPreferences.getInstance();
      isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
      username = prefs.getString('username') ?? '';
    }
  } catch (e) {
    debugPrint('Error checking auth status: $e');
    // Fallback to shared preferences
    try {
      final prefs = await SharedPreferences.getInstance();
      isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
      username = prefs.getString('username') ?? '';
    } catch (e) {
      debugPrint('Using memory fallback storage');
    }
  }

  runApp(CalCollectApp(isLoggedIn: isLoggedIn, username: username));
}

class CalCollectApp extends StatelessWidget {
  final bool isLoggedIn;
  final String username;

  const CalCollectApp({
    Key? key,
    required this.isLoggedIn,
    required this.username,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Lung Cancer Detection',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Color(0xFF8BC34A),
        colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFF8BC34A)),
        fontFamily: 'Roboto',
      ),
      routes: {
        '/': (context) => WelcomeScreen(),
        '/signup': (context) => SignUpScreen(),
        '/login': (context) => LoginScreen(),
        '/upload': (context) => UploadScreen(),
        '/history': (context) => HistoryScreen(),
        '/profile': (context) => ProfileScreen(),
      },
      initialRoute: '/',
    );
  }
}

final Map<String, Map<String, dynamic>> LUNG_CANCER_CLASSES = {
  'lung_aca': {
    'severity': 'High',
    'stage': 'Requires further assessment',
    'recommendation': 'Immediate consultation with an oncologist is recommended.',
    'followUp': 'Schedule a follow-up within 1-2 weeks.'
  },
  'lung_n': {
    'severity': 'None',
    'stage': 'No cancer detected',
    'recommendation': 'Continue regular check-ups.',
    'followUp': 'Schedule a routine follow-up in 12 months.'
  },
  'lung_scc': {
    'severity': 'High',
    'stage': 'Requires further assessment',
    'recommendation': 'Immediate consultation with an oncologist is recommended.',
    'followUp': 'Schedule a follow-up within 1-2 weeks.'
  }
};

const List<String> LUNG_CANCER_CLASS_NAMES = [
  "lung_aca", // Adenocarcinoma
  "lung_n",   // No cancer
  "lung_scc", // Squamous Cell Carcinoma
];
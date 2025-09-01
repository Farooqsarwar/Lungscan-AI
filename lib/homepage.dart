import 'dart:io';
import 'package:calolect/login.dart';
import 'package:calolect/profile%20screen.dart';
import 'package:calolect/user%20controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'upload%20screen.dart';
import 'Risk_fector.dart';
import 'chatbot/chat%20bot.dart';
import 'history%20screen.dart';
import 'bmi_calculator.dart';
import 'health_tips.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final UserController userController = Get.put(UserController());

  Future<void> _updateProfilePicture() async {
    final action = await showDialog<String>(
      context: context,
      builder: (context) =>
          Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF184542), Color(0xFF3B6265)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Profile Picture Options',
                    style: TextStyle(fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF184542),
                      minimumSize: const Size.fromHeight(40),
                    ),
                    onPressed: () => Navigator.pop(context, 'camera'),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Take Photo'),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF184542),
                      minimumSize: const Size.fromHeight(40),
                    ),
                    onPressed: () => Navigator.pop(context, 'gallery'),
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Choose from Gallery'),
                  ),
                  const SizedBox(height: 8),
                  if (userController.userPhotoPath != null)
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(40),
                      ),
                      onPressed: () => Navigator.pop(context, 'remove'),
                      icon: const Icon(Icons.delete),
                      label: const Text('Remove Profile Picture'),
                    ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                        'Cancel', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
          ),
    );

    if (action == null) return;

    userController.isLoading = true;

    try {
      if (action == 'remove') {
        await userController.updateProfilePicture(null);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile picture removed')),
        );
        return;
      }

      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: action == 'camera' ? ImageSource.camera : ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        await userController.updateProfilePicture(pickedFile.path);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile picture updated')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating profile picture: $e')),
      );
    } finally {
      userController.isLoading = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Image.asset('assets/logo.png', height: 50),
            const SizedBox(width: 30),
            const Text(
              'LungScan AI',
              style: TextStyle(
                fontSize: 20,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          Builder(
            builder: (context) =>
                IconButton(
                  icon: const Icon(Icons.menu, color: Colors.white),
                  onPressed: () => Scaffold.of(context).openEndDrawer(),
                ),
          ),
        ],
        backgroundColor: const Color(0xFF184542),
      ),
      endDrawer: Drawer(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF184542), Color(0xFF6AB4BC)],
            ),
          ),
          child: Obx(
                () =>
                ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    Container(
                      height: 320,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 24),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0xFF184542), Color(0xFF3B6265)],
                        ),
                      ),
                      child: userController
                          .isLoading // Fixed: Use public isLoading getter
                          ? const Center(
                          child: CircularProgressIndicator(color: Colors.white))
                          : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Stack(
                            children: [
                              CircleAvatar(
                                radius: 80,
                                backgroundColor: Colors.transparent,
                                backgroundImage: userController.userPhotoPath !=
                                    null
                                    ? FileImage(
                                    File(userController.userPhotoPath!))
                                    : const AssetImage(
                                    'assets/logo.png') as ImageProvider,
                                child: userController.userPhotoPath == null
                                    ? const Icon(
                                    Icons.person, color: Color(0xFF184542),
                                    size: 40)
                                    : null,
                              ) ,
                              Positioned(
                                top: 0,
                                right: 0,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                          color: Colors.black26, blurRadius: 4),
                                    ],
                                  ),
                                  child: IconButton(
                                    icon: const Icon(Icons.add, size: 20,
                                        color: Colors.black),
                                    onPressed: _updateProfilePicture,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            userController.userName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        children: [
                          _buildDrawerOption(
                            context,
                            'Account',
                            Icons.account_box,
                                () {
                              Get.to(() => const ProfileScreen());
                            },
                          ),
                          _buildDrawerOption(context, 'Home', Icons.home, () {
                            Navigator.pop(context);
                          }),
                          _buildDrawerOption(
                              context, 'Logout', Icons.logout, () async {
                            try {
                              await userController.logout();
                              Get.offAll(() => LoginScreen());
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text('Error logging out: $e')),
                              );
                            }
                          }),
                          _buildDrawerOption(context, 'About', Icons.info, () {
                            showDialog(
                              context: context,
                              builder: (context) =>
                                  Dialog(
                                    backgroundColor: Colors.transparent,
                                    child: Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            Color(0xFF184542),
                                            Color(0xFF3B6265)
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: SingleChildScrollView(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment
                                              .start,
                                          children: [
                                            const Text(
                                              'About LungScan AI',
                                              style: TextStyle(
                                                  fontSize: 22,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white),
                                            ),
                                            const SizedBox(height: 16),
                                            const Text(
                                              'LungScan AI is an innovative mobile application designed to assist in the early detection and management of lung cancer...',
                                              style: TextStyle(fontSize: 16,
                                                  color: Colors.white),
                                            ),
                                            const SizedBox(height: 20),
                                            const Text(
                                              'Key Features',
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white),
                                            ),
                                            const SizedBox(height: 10),
                                            const Text(
                                                '• Lung CT Scan Analysis: Upload and analyze CT scans for early detection.',
                                                style: TextStyle(
                                                    color: Colors.white)),
                                            const Text(
                                                '• Risk Factors: Learn about lung cancer risk factors and prevention.',
                                                style: TextStyle(
                                                    color: Colors.white)),
                                            const Text(
                                                '• Health History: Track scan results and health records securely.',
                                                style: TextStyle(
                                                    color: Colors.white)),
                                            const Text(
                                                '• BMI Calculator: Monitor body mass index for health insights.',
                                                style: TextStyle(
                                                    color: Colors.white)),
                                            const Text(
                                                '• Health Tips: Access expert tips for maintaining lung health.',
                                                style: TextStyle(
                                                    color: Colors.white)),
                                            const Text(
                                                '• Chat Assistant: Get instant answers to health-related questions.',
                                                style: TextStyle(
                                                    color: Colors.white)),
                                            const SizedBox(height: 20),
                                            const Text(
                                              'Our Mission',
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white),
                                            ),
                                            const SizedBox(height: 10),
                                            const Text(
                                              'Our mission is to make advanced healthcare accessible through AI-driven technology...',
                                              style: TextStyle(fontSize: 16,
                                                  color: Colors.white),
                                            ),
                                            const SizedBox(height: 16),
                                            Align(
                                              alignment: Alignment.centerRight,
                                              child: ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.white,
                                                  foregroundColor: const Color(
                                                      0xFF184542),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius
                                                        .circular(10),
                                                  ),
                                                ),
                                                child: const Text('Close'),
                                                onPressed: () =>
                                                    Navigator.pop(context),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ],
                ),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF184542), Color(0xFF6AB4BC)],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              const Center(
                child: Text(
                  'Need Health Assistance?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  hintText: 'Quick Help',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide.none,
                  ),
                ),
                onSubmitted: (query) {
                  if (query
                      .trim()
                      .isNotEmpty) {
                    Get.to(() => Chatbot(initialQuery: query));
                  }
                },
              ),
              const SizedBox(height: 20),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  childAspectRatio: 1,
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  children: [
                    _buildMainOption(context, 'Lung CT scan',
                        Icons.health_and_safety_rounded),
                    _buildMainOption(context, 'Risk Factors', Icons.warning),
                    _buildMainOption(context, 'History', Icons.history),
                    _buildMainOption(
                        context, 'BMI Calculator', Icons.calculate),
                    _buildMainOption(
                        context, 'Health Tips', Icons.medical_services),
                    _buildMainOption(
                        context, 'Chat Assistant', Icons.chat_bubble_outline),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainOption(BuildContext context, String title, IconData icon) {
    return Card(
      elevation: 6,
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF4D6160), Color(0xFF3B6265)],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            switch (title) {
              case 'Lung CT scan':
                Get.to(() => UploadScreen());
                break;
              case 'Risk Factors':
                Get.to(() => const LungCancerRiskFactorsScreen());
                break;
              case 'History':
                Get.to(() => HistoryScreen());
                break;
              case 'BMI Calculator':
                Get.to(() => const BMICalculatorScreen());
                break;
              case 'Health Tips':
                Get.to(() => const HealthTipsScreen());
                break;
              case 'Chat Assistant':
                Get.to(() => const Chatbot());
                break;
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: const Color(0xFF184542), size: 28),
                ),
                const SizedBox(height: 10),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerOption(BuildContext context,
      String title,
      IconData icon,
      VoidCallback onTap,) {
    return Card(
      elevation: 4,
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF4D6160), Color(0xFF3B6265)],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          leading: Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFF184542), size: 24),
          ),
          title: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          onTap: onTap,
        ),
      ),
    );
  }
}
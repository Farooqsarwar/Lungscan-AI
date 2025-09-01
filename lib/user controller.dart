import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserController extends GetxController {
  final supabase = Supabase.instance.client;
  final _userName = 'Guest User'.obs;
  final _userPhotoPath = Rx<String?>(null);
  final _isLoading = false.obs;

  String get userName => _userName.value;
  String? get userPhotoPath => _userPhotoPath.value;
  bool get isLoading => _isLoading.value;
  set isLoading(bool value) => _isLoading.value = value; // Added setter for public access

  @override
  void onInit() {
    super.onInit();
    loadUserData();
  }

  Future<void> loadUserData() async {
    if (_isLoading.value) return;
    _isLoading.value = true;

    try {
      final user = supabase.auth.currentUser;
      String username = 'Guest User';
      String? photoPath;

      if (user != null) {
        final userProfile = await supabase
            .from('users')
            .select('name')
            .eq('id', user.id)
            .maybeSingle();

        if (userProfile != null) {
          username = userProfile['name'] ?? user.email?.split('@')[0] ?? 'Guest User';
        } else {
          username = user.userMetadata?['name'] ?? user.email?.split('@')[0] ?? 'Guest User';
        }
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('username', username);
      photoPath = prefs.getString('userPhotoPath');

      _userName.value = username;
      _userPhotoPath.value = photoPath;
    } catch (e) {
      debugPrint('Error loading user data: $e');
      final prefs = await SharedPreferences.getInstance();
      _userName.value = prefs.getString('username') ?? 'Guest User';
      _userPhotoPath.value = prefs.getString('userPhotoPath');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> updateUserName(String newName) async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) throw Exception('User not found');

      await supabase.from('users').update({
        'name': newName,
      }).eq('id', user.id);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('username', newName);

      _userName.value = newName;
    } catch (e) {
      throw Exception('Error updating name: $e');
    }
  }

  Future<void> updateProfilePicture(String? photoPath) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (photoPath == null) {
        await prefs.remove('userPhotoPath');
      } else {
        await prefs.setString('userPhotoPath', photoPath);
      }

      _userPhotoPath.value = photoPath;
    } catch (e) {
      throw Exception('Error updating profile picture: $e');
    }
  }

  Future<void> logout() async {
    _isLoading.value = true;
    try {
      await supabase.auth.signOut();
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      _userName.value = 'Guest User';
      _userPhotoPath.value = null;
    } catch (e) {
      throw Exception('Error logging out: $e');
    } finally {
      _isLoading.value = false;
    }
  }
}
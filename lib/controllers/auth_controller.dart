import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/app_user.dart';
import '../routes/app_pages.dart';
import '../services/auth_service.dart';
import 'navigation_controller.dart';

class AuthController extends GetxController {
  final RxBool isLoading = false.obs;
  final List<String> roles = const [
    'Warehouse Operator',
    'Delivery Agent',
    'Customer',
  ];
  final RxString selectedRole = 'Warehouse Operator'.obs;
  final Rxn<AppUser> currentUser = Rxn<AppUser>();

  late final TextEditingController emailController;
  late final TextEditingController passwordController;

  final AuthService _authService = AuthService();
  StreamSubscription<User?>? _authSubscription;

  @override
  void onInit() {
    emailController = TextEditingController();
    passwordController = TextEditingController();
    _authSubscription = _authService.authChanges.listen(_onAuthStateChanged);
    super.onInit();
  }

  Future<void> _onAuthStateChanged(User? user) async {
    if (user == null) {
      currentUser.value = null;
      return;
    }

    final profile = await _authService.fetchUserProfile(user.uid);
    currentUser.value = profile;
  }

  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final role = selectedRole.value;

    if (email.isEmpty || password.isEmpty) {
      Get.snackbar(
        'Missing info',
        'Enter your credentials to continue.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isLoading.value = true;

    try {
      final credential = await _authService.signIn(email, password);
      final profile = await _authService.fetchUserProfile(credential.user!.uid);

      if (profile == null) {
        await _authService.signOut();
        Get.snackbar(
          'Profile missing',
          'No profile found for this user. Contact support.',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      if (profile.role != role) {
        await _authService.signOut();
        Get.snackbar(
          'Role mismatch',
          'This account is registered as ${profile.role}.',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      currentUser.value = profile;
      _handlePostLoginNavigation(profile.role);
      Get.snackbar(
        'Welcome back',
        'Signed in as ${profile.role}.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.black.withValues(alpha: 0.85),
        colorText: Colors.white,
      );
    } on FirebaseAuthException catch (error) {
      Get.snackbar(
        'Login failed',
        _mapFirebaseError(error),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent.withValues(alpha: 0.2),
      );
    } catch (error) {
      Get.snackbar(
        'Login failed',
        error.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void updateRole(String? role) {
    if (role == null || !roles.contains(role)) {
      return;
    }
    selectedRole.value = role;
  }

  Future<void> logout() async {
    try {
      await _authService.signOut();
      Get.find<NavigationController>().changeTab(0);
      currentUser.value = null;
      passwordController.clear();
      Get.offAllNamed(Routes.login);
    } catch (error) {
      Get.snackbar(
        'Logout failed',
        error.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void _handlePostLoginNavigation(String role) {
    final route = switch (role) {
      'Warehouse Operator' => Routes.warehouseHome,
      'Delivery Agent' => Routes.deliveryHome,
      'Customer' => Routes.customerHome,
      _ => null,
    };

    if (route == null) {
      Get.snackbar(
        'Unsupported role',
        'No screen configured for $role yet.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (route == Routes.warehouseHome) {
      Get.find<NavigationController>().changeTab(0);
    }

    Get.offAllNamed(route);
  }

  String _mapFirebaseError(FirebaseAuthException error) {
    switch (error.code) {
      case 'user-not-found':
        return 'No user found for that email.';
      case 'wrong-password':
        return 'Incorrect password. Try again.';
      case 'invalid-email':
        return 'Email format looks invalid.';
      case 'user-disabled':
        return 'This account has been disabled.';
      default:
        return error.message ?? 'Unknown authentication error occurred.';
    }
  }

  @override
  void onClose() {
    _authSubscription?.cancel();
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}

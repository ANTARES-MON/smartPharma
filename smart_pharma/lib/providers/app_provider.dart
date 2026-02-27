import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../models/user_model.dart';
import '../services/api_service.dart';
import 'reservation_provider.dart'; 
import 'pharmacist_notification_provider.dart'; 

final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

final authProvider = StateNotifierProvider<AuthNotifier, UserModel?>((ref) {
  final api = ref.watch(apiServiceProvider);
  return AuthNotifier(api, ref); 
});

final isLoggedInProvider = Provider<bool>((ref) => ref.watch(authProvider) != null);

final isPharmacistProvider = Provider<bool>((ref) {
  final user = ref.watch(authProvider);
  return user?.isPharmacist ?? false;
});

class AuthNotifier extends StateNotifier<UserModel?> {
  final ApiService _apiService;
  final FlutterSecureStorage _storage;
  final Ref _ref; 

  bool _isCheckingLogin = false;

  AuthNotifier(this._apiService, this._ref) 
      : _storage = const FlutterSecureStorage(), 
        super(null);

  Future<void> checkLoginStatus() async {
    if (_isCheckingLogin) return;
    _isCheckingLogin = true;

    try {
      final token = await _storage.read(key: 'auth_token');
      
      if (token == null) {
        return;
      }

      _apiService.setToken(token);

      final response = await _apiService.getUserData();
      
      if (response.statusCode == 200) {
        final userData = (response.data is Map && response.data.containsKey('user')) 
            ? response.data['user'] 
            : response.data;
            
        if (userData['pharmacy'] == null && userData['pharmacyId'] == null) {
           final localPharmacyId = await _storage.read(key: 'user_pharmacy_id');
           if (localPharmacyId != null) {
             userData['pharmacyId'] = localPharmacyId;
           }
        }
        
        state = UserModel.fromJson(userData);

        await _ref.read(reservationProvider.notifier).loadReservations();

        if (state?.isPharmacist == true) {
          await _ref.read(pharmacistNotificationProvider.notifier).fetchNotifications();
        }

      } else {
        await logout();
      }
    } catch (e) {
      debugPrint("Auto-login failed: $e");
    } finally {
      _isCheckingLogin = false;
    }
  }

  Future<bool> performLogin(String email, String password) async {
    try {
      final response = await _apiService.login({
        'email': email,
        'motDePasse': password,
      });

      if (response.statusCode == 200) {
        final data = response.data;
        final userData = data['user'];

        if (userData == null) {
          return false;
        }

        dynamic rawToken = data['access_token'] ?? data['token'];
        if (rawToken == null) {
          return false;
        }

        String tokenString;
        if (rawToken is Map) {
          tokenString = rawToken['token'].toString();
        } else {
          tokenString = rawToken.toString();
        }

        _apiService.setToken(tokenString);

        await saveUserSession(userData, tokenString);

        try {
          String? fcmToken = await FirebaseMessaging.instance.getToken();
          if (fcmToken != null) {
            await _apiService.updateDeviceToken(fcmToken);
          }
        } catch (e) {
          debugPrint("Failed to update device token: $e");
        }

        await _ref.read(reservationProvider.notifier).loadReservations();

        final user = UserModel.fromJson(userData);
        if (user.isPharmacist == true) {
          await _ref.read(pharmacistNotificationProvider.notifier).fetchNotifications();
        }

        return true;
      }
      
      return false;
    } catch (e, stackTrace) {
      debugPrint("Login error: $e");
      debugPrint("Stack trace: $stackTrace");
      return false;
    }
  }

  Future<bool> performGoogleLogin(String idToken) async {
    try {
      final response = await _apiService.googleLogin(idToken);

      if (response.statusCode == 200) {
        final data = response.data;
        final userData = data['user'];

        if (userData == null) {
          return false;
        }

        dynamic rawToken = data['access_token'] ?? data['token'];
        if (rawToken == null) {
          return false;
        }

        String tokenString;
        if (rawToken is Map) {
          tokenString = rawToken['token'].toString();
        } else {
          tokenString = rawToken.toString();
        }

        _apiService.setToken(tokenString);

        await saveUserSession(userData, tokenString);

        try {
          String? fcmToken = await FirebaseMessaging.instance.getToken();
          if (fcmToken != null) {
            await _apiService.updateDeviceToken(fcmToken);
          }
        } catch (e) {
          debugPrint("Failed to update device token: $e");
        }

        await _ref.read(reservationProvider.notifier).loadReservations();

        final user = UserModel.fromJson(userData);
        if (user.isPharmacist == true) {
          await _ref.read(pharmacistNotificationProvider.notifier).fetchNotifications();
        }

        return true;
      }
      
      return false;
    } catch (e, stackTrace) {
      debugPrint("Google login error: $e");
      debugPrint("Stack trace: $stackTrace");
      return false;
    }
  }

  Future<bool> performFacebookLogin(String accessToken) async {
    try {
      final response = await _apiService.facebookLogin(accessToken);

      if (response.statusCode == 200) {
        final data = response.data;
        final userData = data['user'];

        if (userData == null) {
          return false;
        }

        dynamic rawToken = data['access_token'] ?? data['token'];
        if (rawToken == null) {
          return false;
        }

        String tokenString;
        if (rawToken is Map) {
          tokenString = rawToken['token'].toString();
        } else {
          tokenString = rawToken.toString();
        }

        _apiService.setToken(tokenString);

        await saveUserSession(userData, tokenString);

        try {
          String? fcmToken = await FirebaseMessaging.instance.getToken();
          if (fcmToken != null) {
            await _apiService.updateDeviceToken(fcmToken);
          }
        } catch (e) {
          debugPrint("Failed to update device token: $e");
        }

        await _ref.read(reservationProvider.notifier).loadReservations();

        final user = UserModel.fromJson(userData);
        if (user.isPharmacist == true) {
          await _ref.read(pharmacistNotificationProvider.notifier).fetchNotifications();
        }

        return true;
      }
      
      return false;
    } catch (e, stackTrace) {
      debugPrint("Facebook login error: $e");
      debugPrint("Stack trace: $stackTrace");
      return false;
    }
  }

  Future<void> saveUserSession(Map<String, dynamic> userData, String token) async {
    try {
      await _storage.write(key: 'auth_token', value: token);
      
      final user = UserModel.fromJson(userData);
      
      await _storage.write(key: 'user_id', value: user.id.toString());
      await _storage.write(key: 'user_name', value: user.name);
      await _storage.write(key: 'user_email', value: user.email);
      await _storage.write(key: 'user_role', value: user.role);

      if (user.pharmacyId != null) {
        await _storage.write(key: 'user_pharmacy_id', value: user.pharmacyId.toString());
      }

      state = user;
    } catch (e) {
      debugPrint("Session save error: $e");
    }
  }

  Future<void> logout() async {
    try { await _apiService.logout(); } catch (_) {}
    await _storage.deleteAll();
    
    _apiService.setToken(""); 
    
    state = null;
  }

  Future<void> updateProfile(Map<String, String> data, File? photo) async {
    try {
      final response = await _apiService.updateProfileWithImage(data, photo);
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = response.data;
        final userData = (responseData is Map && responseData.containsKey('user'))
            ? responseData['user']
            : responseData;

        var updatedUser = UserModel.fromJson(userData);

        if (state != null && updatedUser.pharmacyId == null) {
          updatedUser = updatedUser.copyWith(
            pharmacyId: state!.pharmacyId,
            pharmacy: state!.pharmacy,
          );
        }

        state = updatedUser;

        await _storage.write(key: 'user_name', value: updatedUser.name);
        await _storage.write(key: 'user_email', value: updatedUser.email);
        
        if (updatedUser.photo != null) {
          await _storage.write(key: 'user_photo', value: updatedUser.photo);
        }
        if (updatedUser.phone != null) {
           await _storage.write(key: 'user_phone', value: updatedUser.phone);
        }
      }
    } catch (e) {
      debugPrint("Update profile error: $e");
      rethrow;
    }
  }
}
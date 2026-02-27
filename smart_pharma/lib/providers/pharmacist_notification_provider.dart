import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../services/api_service.dart';
import 'app_provider.dart'; 

class PharmacistNotification {
  final int id;
  final String title;
  final String message;
  final String type;
  final bool isRead;
  final DateTime createdAt;
  final Map<String, dynamic>? data;

  PharmacistNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    this.isRead = false,
    required this.createdAt,
    this.data,
  });

  factory PharmacistNotification.fromJson(Map<String, dynamic> json) {
    String dateStr = json['created_at'] ?? '';
    DateTime finalDate;
    if (dateStr.isEmpty) {
      finalDate = DateTime.now();
    } else {
      if (!dateStr.endsWith('Z') && !dateStr.contains('T')) {
        dateStr += 'Z'; 
      }
      finalDate = DateTime.parse(dateStr).toLocal();
    }

    Map<String, dynamic>? parsedData;
    if (json['data'] != null) {
      if (json['data'] is Map<String, dynamic>) {
        parsedData = json['data'];
      } else if (json['data'] is String) {
        try {
          parsedData = jsonDecode(json['data']);
        } catch (e) {
          debugPrint("Error decoding data: $e");
        }
      }
    }

    String finalMessage = json['message'] ?? '';
    String finalTitle = json['titre'] ?? json['title'] ?? 'Notification';
    String finalType = json['type'] ?? 'order';

    if (finalType != 'order') {
      if (finalTitle.toLowerCase().contains('commande') || 
          finalMessage.toLowerCase().contains('commande') ||
          finalType == 'new_reservation') {
        finalType = 'order';
      }
    }

    if (parsedData != null) {
      String? patientName = parsedData['nom_patient'] 
                         ?? parsedData['patient_name'] 
                         ?? parsedData['user_name']
                         ?? parsedData['name'];
      
      if (patientName == null) {
         if (parsedData['user'] is Map) patientName = parsedData['user']['name'] ?? parsedData['user']['nomComplet'];
         if (parsedData['utilisateur'] is Map) patientName = parsedData['utilisateur']['nomComplet'];
         if (parsedData['reservation'] is Map) {
            final res = parsedData['reservation'];
            patientName = res['nom_patient'] ?? res['user_name'];
         }
      }

      String? medName = parsedData['medication_name'] 
                     ?? parsedData['medicament_nom'] 
                     ?? parsedData['med_name']
                     ?? parsedData['nom_medicament'];
      
      if (medName == null) {
         if (parsedData['medication'] is Map) medName = parsedData['medication']['name'] ?? parsedData['medication']['nom'];
         if (parsedData['medicament'] is Map) medName = parsedData['medicament']['nom'];
         if (parsedData['reservation'] is Map) {
             final res = parsedData['reservation'];
             medName = res['medication_name'] ?? res['nom_medicament'];
         }
      }

      if (patientName != null && medName != null) {
        finalMessage = "$patientName a commandé $medName";
        finalType = 'order';
      } 
      else if (patientName != null) {
        finalMessage = "$patientName a passé une commande";
        finalType = 'order';
      }
    }

    return PharmacistNotification(
      id: json['id'] ?? 0,
      title: finalTitle,
      message: finalMessage, 
      type: finalType,
      isRead: (json['lu'] == 1 || json['lu'] == true || json['is_read'] == true),
      createdAt: finalDate,
      data: parsedData,
    );
  }
}

class PharmacistNotificationState {
  final List<PharmacistNotification> notifications;
  final bool isLoading;
  final String? errorMessage;

  PharmacistNotificationState({
    this.notifications = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  PharmacistNotificationState copyWith({
    List<PharmacistNotification>? notifications,
    bool? isLoading,
    String? errorMessage,
  }) {
    return PharmacistNotificationState(
      notifications: notifications ?? this.notifications,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

final pharmacistNotificationProvider = StateNotifierProvider<PharmacistNotificationNotifier, PharmacistNotificationState>((ref) {
  final api = ref.watch(apiServiceProvider);
  return PharmacistNotificationNotifier(api);
});

final pharmacistUnreadCountProvider = Provider<int>((ref) {
  final notifications = ref.watch(pharmacistNotificationProvider).notifications;
  return notifications.where((n) => !n.isRead).length;
});

class PharmacistNotificationNotifier extends StateNotifier<PharmacistNotificationState> {
  final ApiService _apiService;

  PharmacistNotificationNotifier(this._apiService) : super(PharmacistNotificationState()) {
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    state = state.copyWith(isLoading: true);

    try {
      final response = await _apiService.get('/api/reservation/notifications');
      
      final dynamic payload = response.data;
      final List<dynamic> data = (payload is Map && payload.containsKey('data')) 
          ? payload['data'] 
          : (payload is List ? payload : []);

      final notifications = data.map((json) => PharmacistNotification.fromJson(json)).toList();
      
      notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      state = state.copyWith(
        notifications: notifications,
        isLoading: false,
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        state = state.copyWith(notifications: [], isLoading: false);
        return;
      }
      debugPrint("Notification fetch error: ${e.message}");
      state = state.copyWith(isLoading: false, errorMessage: e.message);
    } catch (e) {
      debugPrint("Notification fetch error: $e");
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> markAllAsRead() async {
    final updatedNotifications = state.notifications.map((n) => 
      PharmacistNotification(
        id: n.id, title: n.title, message: n.message, type: n.type,
        isRead: true, createdAt: n.createdAt, data: n.data,
      )
    ).toList();

    state = state.copyWith(notifications: updatedNotifications);

    try {
      await _apiService.post('/api/reservation/notifications/mark-read', {});
    } catch (e) {
      debugPrint("Mark read error: $e");
      fetchNotifications();
    }
  }

  Future<void> clearAll() async {
    state = state.copyWith(notifications: []);
    try {
      await _apiService.delete('/reservation/notifications/clear');
    } catch (e) {
      debugPrint("Clear notifications error: $e");
    }
  }

  void addNotification(PharmacistNotification notification) {
    if (state.notifications.any((n) => n.id == notification.id)) return;

    final updatedNotifications = [notification, ...state.notifications];
    updatedNotifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    
    state = state.copyWith(notifications: updatedNotifications);
  }

  void markAsRead(int notificationId) {
    final updatedNotifications = state.notifications.map((n) {
      if (n.id == notificationId) {
        return PharmacistNotification(
          id: n.id, title: n.title, message: n.message, type: n.type,
          isRead: true, createdAt: n.createdAt, data: n.data,
        );
      }
      return n;
    }).toList();

    state = state.copyWith(notifications: updatedNotifications);

    _apiService.post('/api/reservation/notifications/mark-read', {'id': notificationId})
        .catchError((e) {
          debugPrint("Mark notification read error: $e");
          return Response(requestOptions: RequestOptions(path: ''), statusCode: 500);
        });
  }

  void reset() {
    state = PharmacistNotificationState();
  }
}
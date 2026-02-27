import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../services/api_service.dart';
import '../services/websocket_service.dart';
import 'app_provider.dart';

class AppNotification {
  final int id;
  final String title;
  final String message;
  final bool isRead;
  final DateTime createdAt;
  final Map<String, dynamic>? data;

  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.isRead,
    required this.createdAt,
    this.data,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
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
          debugPrint("Error decoding notification data: $e");
        }
      }
    }

    return AppNotification(
      id: json['id'] ?? 0,
      title: json['titre'] ?? json['title'] ?? 'Notification',
      message: json['message'] ?? '',
      isRead:
          (json['lu'] == 1 || json['lu'] == true || json['is_read'] == true),
      createdAt: finalDate,
      data: parsedData,
    );
  }
}

class NotificationNotifier extends StateNotifier<List<AppNotification>> {
  final ApiService _apiService;
  final int? _userId;
  final WebSocketService _webSocket = WebSocketService.instance;

  NotificationNotifier(this._apiService, this._userId) : super([]) {
    if (_userId != null) {
      fetchNotifications();
      _setupWebSocket();
    }
  }

  void _setupWebSocket() {
    if (_userId == null) return;

    _webSocket.initialize(
      userId: _userId.toString(),
      onNotification: (data) {
        fetchNotifications();
      },
    );
  }

  Future<void> fetchNotifications() async {
    try {
      final Response response = await _apiService.get(
        '/api/reservation/notifications',
      );
      final dynamic payload = response.data;

      final List<dynamic> dataList =
          (payload is Map && payload.containsKey('data'))
          ? payload['data']
          : (payload is List ? payload : []);

      final notifications = dataList
          .map((json) => AppNotification.fromJson(json))
          .toList();

      notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      state = notifications;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        state = [];
        return;
      }
      debugPrint("Notification fetch error: ${e.message}");
      state = [];
    } catch (e) {
      debugPrint("Notification fetch error: $e");
      state = [];
    }
  }

  void markAsRead(int notificationId) {
    state = state.map((n) {
      if (n.id == notificationId) {
        return AppNotification(
          id: n.id,
          title: n.title,
          message: n.message,
          isRead: true,
          createdAt: n.createdAt,
          data: n.data,
        );
      }
      return n;
    }).toList();

    _apiService.post('/api/reservation/notifications/mark-read', {
      'id': notificationId,
    });
  }

  Future<void> markAllAsRead() async {
    state = state
        .map(
          (n) => AppNotification(
            id: n.id,
            title: n.title,
            message: n.message,
            isRead: true,
            createdAt: n.createdAt,
            data: n.data,
          ),
        )
        .toList();

    try {
      await _apiService.post('/api/reservation/notifications/mark-read', {});
    } catch (e) {
      debugPrint("Mark all read error: $e");
    }
  }

  Future<void> clearAll() async {
    state = [];
    try {
      await _apiService.delete('/reservation/notifications/clear');
    } catch (e) {
      debugPrint("Clear error: $e");
    }
  }

  void addNotification(AppNotification notification) {
    if (state.any((n) => n.id == notification.id)) return;

    final updated = [notification, ...state];
    updated.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    state = updated;
  }
}

final clientNotificationProvider =
    StateNotifierProvider<NotificationNotifier, List<AppNotification>>((ref) {
      final api = ref.watch(apiServiceProvider);
      final user = ref.watch(authProvider);

      return NotificationNotifier(api, user?.id);
    });

final clientUnreadCountProvider = Provider<int>((ref) {
  final notifications = ref.watch(clientNotificationProvider);
  return notifications.where((n) => !n.isRead).length;
});

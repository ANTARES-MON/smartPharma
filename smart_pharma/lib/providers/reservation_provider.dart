import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';

import '../models/reservation.dart';
import '../services/api_service.dart';
import 'app_provider.dart';
import 'client_notification_provider.dart';

enum ReservationStatus { idle, loading, success, error }

class ReservationState {
  final List<Reservation> reservations;
  final ReservationStatus status;
  final String? errorMessage;

  ReservationState({
    this.reservations = const [],
    this.status = ReservationStatus.idle,
    this.errorMessage,
  });

  ReservationState copyWith({
    List<Reservation>? reservations,
    ReservationStatus? status,
    String? errorMessage,
  }) {
    return ReservationState(
      reservations: reservations ?? this.reservations,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

final reservationProvider = StateNotifierProvider<ReservationNotifier, ReservationState>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return ReservationNotifier(apiService, ref);
});

class ReservationNotifier extends StateNotifier<ReservationState> {
  final ApiService _apiService;
  final Ref _ref;

  ReservationNotifier(this._apiService, this._ref) : super(ReservationState());

  Future<void> loadReservations({String? pharmacyId}) async {
    if (state.status == ReservationStatus.loading) return;

    state = state.copyWith(status: ReservationStatus.loading);

    try {
      final user = _ref.read(authProvider);
      if (user == null) {
        throw "User not authenticated";
      }

      Response response;

      if (pharmacyId != null || (user.isPharmacist == true)) {
        final targetId = pharmacyId ?? user.pharmacyId.toString();
        response = await _apiService.getPharmacyReservations(targetId);
      } else {
        response = await _apiService.getUserReservations();
      }

      dynamic responseData = response.data;
      if (responseData is Map && responseData.containsKey('data')) {
        responseData = responseData['data'];
      } else if (responseData is Map && responseData.containsKey('reservations')) {
        responseData = responseData['reservations'];
      }

      final List<dynamic> listData = (responseData is List) ? responseData : [];

      final List<Reservation> list = listData
          .map((json) => Reservation.fromJson(json))
          .toList();

      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      state = state.copyWith(
          reservations: list,
          status: ReservationStatus.success
      );

    } catch (e) {
      if (e is DioException && e.response?.statusCode == 401) {
        debugPrint("Reservation load aborted: Unauthorized (401)");
        state = state.copyWith(status: ReservationStatus.idle);
        return;
      }

      debugPrint("Error loading reservations: $e");
      state = state.copyWith(
          status: ReservationStatus.error,
          errorMessage: "Impossible de charger les réservations"
      );
    }
  }

  Future<bool> makeReservation(Map<String, dynamic> reservationData) async {
    state = state.copyWith(status: ReservationStatus.loading);

    try {
      final response = await _apiService.createReservation(reservationData);

      if (response.statusCode == 201 || response.statusCode == 200) {
        final responseData = (response.data is Map && response.data.containsKey('data'))
            ? response.data['data']
            : response.data;

        final createdReservation = Reservation.fromJson(responseData);

        state = state.copyWith(
          status: ReservationStatus.success,
          reservations: [createdReservation, ...state.reservations],
        );

        _ref.read(clientNotificationProvider.notifier).fetchNotifications();

        return true;
      } else {
        throw Exception('Server returned ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Reservation error: $e');
      state = state.copyWith(
          status: ReservationStatus.error,
          errorMessage: "Échec de la réservation"
      );
      return false;
    }
  }

  Future<bool> updateStatus(String reservationId, String newStatus) async {
    final previousReservations = state.reservations;

    state = state.copyWith(
      reservations: state.reservations.map((res) {
        return res.id == reservationId ? res.copyWith(status: newStatus) : res;
      }).toList(),
    );

    try {
      await _apiService.updateReservationStatus(reservationId, newStatus);

      _ref.read(clientNotificationProvider.notifier).fetchNotifications();

      return true;
    } catch (e) {
      debugPrint("Update failed: $e");
      state = state.copyWith(
          reservations: previousReservations,
          errorMessage: "Erreur de connexion. Annulation..."
      );
      loadReservations();
      return false;
    }
  }

  void reset() {
    state = ReservationState();
  }
}
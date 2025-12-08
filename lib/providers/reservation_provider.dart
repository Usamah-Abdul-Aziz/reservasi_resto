import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/reservation.dart';

class ReservationProvider extends ChangeNotifier {
  List<Reservation> _reservations = [];
  late SharedPreferences _prefs;
  bool _isInitialized = false;

  List<Reservation> get reservations => _reservations;
  bool get isInitialized => _isInitialized;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _loadReservations();
    _isInitialized = true;
    notifyListeners();
  }

  void _loadReservations() {
    final savedReservations = _prefs.getStringList('reservations') ?? [];
    _reservations = savedReservations
        .map((json) => Reservation.fromMap(jsonDecode(json)))
        .toList();
  }

  Future<void> _saveReservations() async {
    final jsonList = _reservations
        .map((res) => jsonEncode(res.toMap()))
        .toList();
    await _prefs.setStringList('reservations', jsonList);
  }

  Future<void> addReservation(Reservation reservation) async {
    _reservations.add(reservation);
    await _saveReservations();
    notifyListeners();
  }

  Future<void> updateReservation(Reservation reservation) async {
    final index = _reservations.indexWhere((r) => r.id == reservation.id);
    if (index != -1) {
      _reservations[index] = reservation;
      await _saveReservations();
      notifyListeners();
    }
  }

  Future<void> deleteReservation(String id) async {
    _reservations.removeWhere((r) => r.id == id);
    await _saveReservations();
    notifyListeners();
  }

  Reservation? getReservationById(String id) {
    try {
      return _reservations.firstWhere((r) => r.id == id);
    } catch (e) {
      return null;
    }
  }

  List<Reservation> getReservationsByStatus(ReservationStatus status) {
    return _reservations.where((r) => r.status == status).toList();
  }


  List<Reservation> getUpcomingReservations() {
    final now = DateTime.now();
    return _reservations
        .where((r) =>
            r.reservationDate.isAfter(now) &&
            r.status != ReservationStatus.cancelled)
        .toList()
      ..sort((a, b) => a.reservationDate.compareTo(b.reservationDate));
  }

  List<Reservation> getReservationsByDate(DateTime date) {
    return _reservations
        .where((r) =>
            r.reservationDate.year == date.year &&
            r.reservationDate.month == date.month &&
            r.reservationDate.day == date.day)
        .toList();
  }
}

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/app_notification.dart';
import '../models/reservation.dart';

class NotificationProvider extends ChangeNotifier {
  List<AppNotification> _notifications = [];
  bool _isLoading = false;
  
  // Supabase client
  final SupabaseClient _supabase = Supabase.instance.client;
  RealtimeChannel? _notificationChannel;

  List<AppNotification> get notifications => _notifications;
  List<AppNotification> get unreadNotifications => 
      _notifications.where((n) => !n.isRead).toList();
  int get unreadCount => unreadNotifications.length;
  bool get isLoading => _isLoading;

  /// Initialize dan load notifikasi dari Supabase
  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _loadNotifications();
      _subscribeToRealtimeNotifications();
    } catch (e) {
      print('Error initializing notifications: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Load notifikasi dari database
  Future<void> _loadNotifications() async {
    try {
      final response = await _supabase
          .from('admin_notifications')
          .select()
          .order('createdAt', ascending: false)
          .limit(50);

      _notifications = (response as List)
          .map((item) => AppNotification.fromMap(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error loading notifications: $e');
      _notifications = [];
    }
  }

  /// Subscribe ke realtime updates untuk notifikasi
  void _subscribeToRealtimeNotifications() {
    _notificationChannel = _supabase.channel('admin_notifications_changes');
    
    _notificationChannel!.on(
      RealtimeListenTypes.postgresChanges,
      ChannelFilter(
        event: 'INSERT',
        schema: 'public',
        table: 'admin_notifications',
      ),
      (payload, [ref]) {
        final newNotification = AppNotification.fromMap(
          payload['new'] as Map<String, dynamic>,
        );
        _notifications.insert(0, newNotification);
        notifyListeners();
      },
    ).subscribe();
  }

  /// Tambah notifikasi baru (untuk reservasi baru)
  Future<void> addNewReservationNotification(Reservation reservation) async {
    final notification = AppNotification(
      title: '🔔 Reservasi Baru!',
      message: '${reservation.guestName} - ${reservation.numberOfGuests} orang\n'
          'Jam ${reservation.reservationTime.hour.toString().padLeft(2, '0')}:'
          '${reservation.reservationTime.minute.toString().padLeft(2, '0')}',
      type: NotificationType.newReservation,
      reservationId: reservation.id,
    );

    await _saveNotification(notification);
  }

  /// Tambah notifikasi reminder
  Future<void> addReminderNotification(Reservation reservation) async {
    final notification = AppNotification(
      title: '⏰ Reminder Reservasi',
      message: '${reservation.guestName} akan datang dalam 3 jam!\n'
          'Jam ${reservation.reservationTime.hour.toString().padLeft(2, '0')}:'
          '${reservation.reservationTime.minute.toString().padLeft(2, '0')}',
      type: NotificationType.reminder,
      reservationId: reservation.id,
    );

    await _saveNotification(notification);
  }

  /// Tambah notifikasi pembatalan
  Future<void> addCancellationNotification(Reservation reservation) async {
    final notification = AppNotification(
      title: '❌ Reservasi Dibatalkan',
      message: '${reservation.guestName} membatalkan reservasi\n'
          'Jam ${reservation.reservationTime.hour.toString().padLeft(2, '0')}:'
          '${reservation.reservationTime.minute.toString().padLeft(2, '0')}',
      type: NotificationType.cancellation,
      reservationId: reservation.id,
    );

    await _saveNotification(notification);
  }

  /// Simpan notifikasi ke database
  Future<void> _saveNotification(AppNotification notification) async {
    try {
      await _supabase.from('admin_notifications').insert(notification.toMap());
      
      // Tambah ke local list juga
      _notifications.insert(0, notification);
      notifyListeners();
    } catch (e) {
      print('Error saving notification: $e');
      // Tetap tambah ke local list meskipun gagal simpan ke DB
      _notifications.insert(0, notification);
      notifyListeners();
    }
  }

  /// Tandai notifikasi sebagai dibaca
  Future<void> markAsRead(String notificationId) async {
    try {
      await _supabase
          .from('admin_notifications')
          .update({'isRead': true})
          .eq('id', notificationId);

      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        _notifications[index] = _notifications[index].copyWith(isRead: true);
        notifyListeners();
      }
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }

  /// Tandai semua notifikasi sebagai dibaca
  Future<void> markAllAsRead() async {
    try {
      await _supabase
          .from('admin_notifications')
          .update({'isRead': true})
          .eq('isRead', false);

      _notifications = _notifications
          .map((n) => n.copyWith(isRead: true))
          .toList();
      notifyListeners();
    } catch (e) {
      print('Error marking all notifications as read: $e');
    }
  }

  /// Hapus notifikasi
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _supabase
          .from('admin_notifications')
          .delete()
          .eq('id', notificationId);

      _notifications.removeWhere((n) => n.id == notificationId);
      notifyListeners();
    } catch (e) {
      print('Error deleting notification: $e');
    }
  }

  /// Hapus semua notifikasi
  Future<void> clearAllNotifications() async {
    try {
      await _supabase.from('admin_notifications').delete().neq('id', '');
      
      _notifications.clear();
      notifyListeners();
    } catch (e) {
      print('Error clearing notifications: $e');
    }
  }

  @override
  void dispose() {
    _notificationChannel?.unsubscribe();
    super.dispose();
  }
}

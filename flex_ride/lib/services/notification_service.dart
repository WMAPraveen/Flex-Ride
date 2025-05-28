import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flex_ride/models/notification_model.dart';

class NotificationService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Add a new notification
  static Future<void> addNotification({
    required String title,
    required String message,
    required String type,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final notification = NotificationModel(
        id: '',
        title: title,
        message: message,
        timestamp: DateTime.now(),
        type: type,
        additionalData: additionalData,
      );

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('notifications')
          .add(notification.toMap());
    } catch (e) {
      print('Error adding notification: $e');
    }
  }

  // Get notifications stream
  static Stream<List<NotificationModel>> getNotificationsStream() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('notifications')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => NotificationModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  // Mark notification as read
  static Future<void> markAsRead(String notificationId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('notifications')
          .doc(notificationId)
          .update({'isRead': true});
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }

  // Get unread notification count
  static Stream<int> getUnreadCountStream() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value(0);

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('notifications')
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // Delete notification
  static Future<void> deleteNotification(String notificationId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('notifications')
          .doc(notificationId)
          .delete();
    } catch (e) {
      print('Error deleting notification: $e');
    }
  }

  // Add payment success notification
  static Future<void> addPaymentSuccessNotification({
    required String vehicleName,
    required double amount,
    required String bookingId,
  }) async {
    await addNotification(
      title: 'Payment Successful!',
      message: 'Your payment of Rs.${amount.toStringAsFixed(2)} for $vehicleName has been processed successfully.',
      type: 'payment_success',
      additionalData: {
        'vehicleName': vehicleName,
        'amount': amount,
        'bookingId': bookingId,
      },
    );
  }
}
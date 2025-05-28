import 'package:flex_ride/services/notification_service.dart';

import 'package:flutter/material.dart';
import 'package:flex_ride/features/home/home.dart';
// Import your notification service
// import 'package:flex_ride/services/notification_service.dart';

class PaymentSuccessPage extends StatelessWidget {
  final String? vehicleName;
  final double? amount;
  final String? bookingId;
  
  const PaymentSuccessPage({
    Key? key,
    this.vehicleName,
    this.amount,
    this.bookingId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Add notification when the page is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _addPaymentNotification();
    });

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle,
                  color: Colors.green.shade700,
                  size: 80,
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Payment Successful!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                vehicleName != null && amount != null
                    ? 'Your booking for $vehicleName has been confirmed and payment of Rs.${amount!.toStringAsFixed(2)} has been processed successfully.'
                    : 'Your booking has been confirmed and payment has been processed successfully.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              if (bookingId != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.confirmation_number, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        'Booking ID: $bookingId',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const HomeScreen()),
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: const Text(
                    'BACK TO HOME',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () {
                  // Navigate to booking details or receipt
                  _showBookingDetails(context);
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.black),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'VIEW BOOKING DETAILS',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addPaymentNotification() async {
    try {
      await NotificationService.addPaymentSuccessNotification(
        vehicleName: vehicleName ?? 'Vehicle',
        amount: amount ?? 0.0,
        bookingId: bookingId ?? 'N/A',
      );
    } catch (e) {
      print('Error adding payment notification: $e');
    }
  }

  void _showBookingDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Booking Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (vehicleName != null) ...[
              Text('Vehicle: $vehicleName'),
              const SizedBox(height: 8),
            ],
            if (amount != null) ...[
              Text('Amount Paid: Rs.${amount!.toStringAsFixed(2)}'),
              const SizedBox(height: 8),
            ],
            if (bookingId != null) ...[
              Text('Booking ID: $bookingId'),
              const SizedBox(height: 8),
            ],
            Text('Payment Time: ${DateTime.now().toString()}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
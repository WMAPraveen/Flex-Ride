
import 'package:flex_ride/features/vehicledetails/payment_sucess.dart';
import 'package:flex_ride/widgets/booking_summary_item.dart';
import 'package:flex_ride/widgets/creaditcard_icon.dart';
import 'package:flutter/material.dart';

class PaymentDetailsPage extends StatefulWidget {
  final Map<String, dynamic> bookingDetails;

  const PaymentDetailsPage({
    Key? key,
    required this.bookingDetails,
  }) : super(key: key);

  @override
  State<PaymentDetailsPage> createState() => _PaymentDetailsPageState();
}

class _PaymentDetailsPageState extends State<PaymentDetailsPage> {
  final cardNumberController = TextEditingController();
  final cardHolderController = TextEditingController();
  final expiryDateController = TextEditingController();
  final cvvController = TextEditingController();
  bool agreedToTerms = false;
  String selectedCardType = 'Visa';

  final List<String> cardTypes = [
    'Visa',
    'MasterCard',
    'American Express',
    'Discover',
  ];

  void _processPayment() {
    if (cardNumberController.text.isEmpty ||
        cardHolderController.text.isEmpty ||
        expiryDateController.text.isEmpty ||
        cvvController.text.isEmpty ||
        !agreedToTerms) {
      // Show validation error
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all required fields and agree to terms'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Here you would normally call your payment API

    // Navigate to success page
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentSuccessPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Payment Details',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.black,
        centerTitle: true,
        elevation: 0,
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Booking summary
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Booking Summary',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  BookingSummaryItem(
                    label: 'Name',
                    value: widget.bookingDetails['name'],
                  ),
                  BookingSummaryItem(
                    label: 'Date',
                    value:
                        '${widget.bookingDetails['date'].day}/${widget.bookingDetails['date'].month}/${widget.bookingDetails['date'].year}',
                  ),
                  BookingSummaryItem(
                    label: 'Time',
                    value:
                        '${widget.bookingDetails['time'].hour}:${widget.bookingDetails['time'].minute.toString().padLeft(2, '0')}',
                  ),
                  BookingSummaryItem(
                    label: 'Driver',
                    value: widget.bookingDetails['withDriver'] ? 'Yes' : 'No',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Payment information
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Payment Details',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          Icon(Icons.lock, size: 16, color: Colors.green),
                          SizedBox(width: 4),
                          Text(
                            'Secure Payment',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.green,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Card type selector
                  DropdownButtonFormField<String>(
                    value: selectedCardType,
                    decoration: InputDecoration(
                      labelText: 'Card Type',
                      floatingLabelStyle: TextStyle(color: Colors.black),
                      prefixIcon: const Icon(
                        Icons.credit_card,
                        color: Colors.red,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: Colors.red,
                          width: 2,
                        ),
                      ),
                    ),
                    items: cardTypes.map((String cardType) {
                      return DropdownMenuItem<String>(
                        value: cardType,
                        child: Text(cardType),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          selectedCardType = newValue;
                        });
                      }
                    },
                  ),

                  const SizedBox(height: 16),

                  // Card number
                  TextField(
                    controller: cardNumberController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Card Number',
                      floatingLabelStyle: TextStyle(color: Colors.black),
                      hintText: 'XXXX XXXX XXXX XXXX',
                      prefixIcon: const Icon(
                        Icons.credit_card,
                        color: Colors.red,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: Colors.red,
                          width: 2,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Card holder name
                  TextField(
                    controller: cardHolderController,
                    decoration: InputDecoration(
                      labelText: 'Card Holder Name',
                      floatingLabelStyle: TextStyle(color: Colors.black),
                      prefixIcon: const Icon(Icons.person, color: Colors.red),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: Colors.red,
                          width: 2,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Expiry date and CVV
                  Row(
                    children: [
                      // Expiry date
                      Expanded(
                        child: TextField(
                          controller: expiryDateController,
                          keyboardType: TextInputType.datetime,
                          decoration: InputDecoration(
                            labelText: 'Expiry (MM/YY)',
                            floatingLabelStyle: TextStyle(color: Colors.black),
                            hintText: 'MM/YY',
                            prefixIcon: const Icon(
                              Icons.date_range,
                              color: Colors.red,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: Colors.red,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 16),

                      // CVV
                      Expanded(
                        child: TextField(
                          controller: cvvController,
                          keyboardType: TextInputType.number,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: 'CVV',
                            floatingLabelStyle: TextStyle(color: Colors.black),
                            hintText: '123',
                            prefixIcon: const Icon(
                              Icons.security,
                              color: Colors.red,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: Colors.red,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Supported cards
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CreditCardIcon(type: CreditCardType.visa),
                        const SizedBox(width: 12),
                        CreditCardIcon(type: CreditCardType.mastercard),
                        const SizedBox(width: 12),
                        CreditCardIcon(type: CreditCardType.amex),
                        const SizedBox(width: 12),
                        CreditCardIcon(type: CreditCardType.discover),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Terms and conditions
            CheckboxListTile(
              title: const Text('I agree to the Terms and Conditions'),
              value: agreedToTerms,
              activeColor: Colors.black,
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              onChanged: (bool? value) {
                setState(() {
                  agreedToTerms = value ?? false;
                });
              },
            ),

            const SizedBox(height: 24),

            // Pay Now button
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _processPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: const Text(
                  'PAY NOW',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Contact button
            Center(
              child: TextButton.icon(
                onPressed: () {
                  // Handle contact click
                },
                icon: const Icon(Icons.support_agent, color: Colors.black),
                label: const Text(
                  'Need Help?',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// Credit card type enum
enum CreditCardType {
  visa,
  mastercard,
  amex,
  discover,
}

// Credit card icon widget
class CreditCardIcon extends StatelessWidget {
  final CreditCardType type;

  const CreditCardIcon({Key? key, required this.type}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: _buildCardLogo(),
    );
  }

  Widget _buildCardLogo() {
    switch (type) {
      case CreditCardType.visa:
        return _buildVisaLogo();
      case CreditCardType.mastercard:
        return _buildMastercardLogo();
      case CreditCardType.amex:
        return _buildAmexLogo();
      case CreditCardType.discover:
        return _buildDiscoverLogo();
    }
  }

  // VISA logo
  Widget _buildVisaLogo() {
    return Row(
      children: [
        Container(
          height: 20,
          width: 32,
          decoration: BoxDecoration(
            color: const Color(0xFF1A1F71),
            borderRadius: BorderRadius.circular(4),
          ),
          alignment: Alignment.center,
          child: const Text(
            'VISA',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              fontStyle: FontStyle.italic,
              letterSpacing: -0.5,
            ),
          ),
        ),
      ],
    );
  }

  // Mastercard logo
  Widget _buildMastercardLogo() {
    return SizedBox(
      height: 20,
      width: 32,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            child: Container(
              height: 20,
              width: 20,
              decoration: const BoxDecoration(
                color: Color(0xFFFF5F00),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            right: 0,
            child: Container(
              height: 20,
              width: 20,
              decoration: const BoxDecoration(
                color: Color(0xFFEB001B),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            left: 6,
            child: Container(
              height: 20,
              width: 20,
              decoration: BoxDecoration(
                color: const Color(0xFF0099DF).withOpacity(0.8),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Amex logo
  Widget _buildAmexLogo() {
    return Container(
      height: 20,
      width: 32,
      decoration: BoxDecoration(
        color: const Color(0xFF2E77BB),
        borderRadius: BorderRadius.circular(4),
      ),
      alignment: Alignment.center,
      child: const Text(
        'AMEX',
        style: TextStyle(
          color: Colors.white,
          fontSize: 9,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // Discover logo
  Widget _buildDiscoverLogo() {
    return Container(
      height: 20,
      width: 40,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF67F00), Color(0xFFFF9B36)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      alignment: Alignment.center,
      child: const Text(
        'DISCOVER',
        style: TextStyle(
          color: Colors.white,
          fontSize: 7,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

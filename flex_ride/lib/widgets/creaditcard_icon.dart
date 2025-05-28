import 'package:flutter/material.dart';

enum CreditCardType { visa, mastercard, amex, discover }

// Credit card icon widget
class CreditCardIcon extends StatelessWidget {
  final CreditCardType type;

  const CreditCardIcon({Key? key, required this.type}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(6),
      ),
      child: _getCardIcon(),
    );
  }

  Widget _getCardIcon() {
    Color iconColor;
    IconData iconData;
    String label;

    switch (type) {
      case CreditCardType.visa:
        iconColor = Colors.blue.shade800;
        iconData = Icons.credit_card;
        label = 'Visa';
        break;
      case CreditCardType.mastercard:
        iconColor = Colors.orange;
        iconData = Icons.credit_card;
        label = 'MC';
        break;
      case CreditCardType.amex:
        iconColor = Colors.blue;
        iconData = Icons.credit_card;
        label = 'Amex';
        break;
      case CreditCardType.discover:
        iconColor = Colors.orange.shade800;
        iconData = Icons.credit_card;
        label = 'Disc';
        break;
    }

    return Row(
      children: [
        Icon(iconData, size: 16, color: iconColor),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: iconColor,
          ),
        ),
      ],
    );
  }
}
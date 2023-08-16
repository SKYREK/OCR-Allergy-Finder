import 'package:flutter/material.dart';

class CapsuleWidget extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final VoidCallback onEdit;

  const CapsuleWidget({
    required this.text,
    required this.onPressed,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFfb6d65)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                text,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFFfb6d65),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),

              ),
            ),
          ),
          IconButton(
            onPressed: onEdit,
            icon: const Icon(
              Icons.edit,
              color: Color(0xFFAE81DA),
            ),
          ),
          IconButton(
            onPressed: onPressed,
            icon: const Icon(
              Icons.delete,
              color: Color(0xFFfb6d65),
            ),
          ),
        ],
      ),
    );
  }
}

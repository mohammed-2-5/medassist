import 'package:flutter/material.dart';

class ScanMedicationProcessingView extends StatelessWidget {
  const ScanMedicationProcessingView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Scanning medication label...'),
          SizedBox(height: 8),
          Text(
            'This may take a few seconds',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

class ErrorHandler extends StatelessWidget {
  const ErrorHandler({super.key, required this.error, this.onRetry});
  final String error;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Text('An error occurred: $error'),
          ElevatedButton(
            onPressed: () {
              if (onRetry != null) {
                onRetry!();
              } else {
                Navigator.pop(context);
              }
            },
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

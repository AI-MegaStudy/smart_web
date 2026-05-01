import 'package:flutter/material.dart';

Future<void> showAppAlertDialog(
  BuildContext context, {
  required String message,
  String title = 'Harvest Slot 내용:',
}) {
  return showDialog<void>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      );
    },
  );
}

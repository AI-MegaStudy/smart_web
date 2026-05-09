import 'package:flutter/material.dart';

Future<void> showAppAlertDialog(
  BuildContext context, {
  required String message,
  String title = 'Harvest Slot 안내',
  VoidCallback? onConfirm,
}) {
  return showDialog<void>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm?.call();
            },
            child: const Text('확인'),
          ),
        ],
      );
    },
  );
}

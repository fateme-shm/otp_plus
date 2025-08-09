import 'package:flutter/material.dart';
import 'package:otp_plus/utils/enum/snack_bar_type.dart';

void showSnackBar({
  required String message,
  required SnackBarType type,
  required BuildContext context,
}) {
  final snackBar = SnackBar(
    content: Text(message),
    behavior: SnackBarBehavior.floating,
    backgroundColor: type == SnackBarType.error ? Colors.red : Colors.green,
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

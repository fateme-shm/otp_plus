import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:otp_plus/otp_plus.dart';
import 'package:otp_plus/utils/enum/otp_field_shape.dart';

void main() {
  testWidgets(
    'OtpPlusInputs displays correct number of fields and triggers onCompleted',
    (WidgetTester tester) async {
      String completedCode = '';

      // Build the widget with 4-digit OTP
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OtpPlusInputs(
              length: 4,
              shape: OtpFieldShape.square,
              onComplete: (code) {
                completedCode = code;
              },
            ),
          ),
        ),
      );

      // Verify that the correct number of text fields are rendered
      final textFields = find.byType(TextField);
      expect(textFields, findsNWidgets(4));

      // Enter one digit in each field
      await tester.enterText(textFields.at(0), '1');
      await tester.pump();
      await tester.enterText(textFields.at(1), '2');
      await tester.pump();
      await tester.enterText(textFields.at(2), '3');
      await tester.pump();
      await tester.enterText(textFields.at(3), '4');
      await tester.pump();

      // Check if onCompleted was triggered with correct value
      expect(completedCode, '1234');
    },
  );
}

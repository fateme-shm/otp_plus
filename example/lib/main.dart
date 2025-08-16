import 'package:flutter/material.dart';
import 'package:otp_plus/otp_plus.dart';
import 'package:otp_plus/utils/enum/otp_field_shape.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test OTP Plus'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          const SizedBox(height: 70),
          Text(
            'Input your code here:',
            style: TextStyle(
              fontSize: 20,
              color: Colors.black,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 30),
          Center(
            child: OtpPlusInputs(
              size: 50,
              length: 6,
              shape: OtpFieldShape.square,
              textDirection: TextDirection.ltr,
              onChanged: (code) {
                debugPrint('On Changed : $code');
              },
              onSubmit: (code) {
                debugPrint('On Submit : $code');
              },
              //Add optional values here
              onComplete: (code) {
                // Add OTP verification logic here
                debugPrint('OTP completed: $code');
              },
            ),
          ),
        ],
      ),
    );
  }
}

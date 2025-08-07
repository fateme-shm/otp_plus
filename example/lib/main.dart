import 'package:flutter/material.dart';
import 'package:otp_plus/otp_plus.dart';

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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Input your code here:', style: TextStyle(fontSize: 20)),
            const SizedBox(height: 30),
            Center(
              child: OtpPlusInputs(
                length: 6,
                shape: OtpFieldShape.square,
                size: 50,
                obscureText: true,
                //Add optional values here
                onCompleted: (code) {
                  // Add OTP verification logic here
                  debugPrint('OTP entered: $code');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

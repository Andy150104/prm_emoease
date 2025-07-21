import 'package:flutter/material.dart';

class SubscriptionPaymentPage extends StatelessWidget {
  const SubscriptionPaymentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thanh toán'),
        backgroundColor: Colors.deepPurple,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Quét mã QR để thanh toán:', style: TextStyle(fontSize: 16)),
            SizedBox(height: 16),
            Image(
              image: AssetImage('assets/images/qr_mock.png'),
              width: 250,
              height: 250,
            ),
          ],
        ),
      ),
    );
  }
}

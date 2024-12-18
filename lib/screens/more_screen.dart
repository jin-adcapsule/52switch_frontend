import 'package:flutter/material.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('')),
      body: Center(
        child: Text(
          'Additional Options and Settings',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class PersonCardView extends StatelessWidget {
  const PersonCardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Jannis Neuhaus'),
      ),
      body: Center(
        child: Text(
          'Du bist blöd',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class DummyPersonView extends StatelessWidget {
  final String name;

  const DummyPersonView({Key? key, required this.name}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kontakt Info'),
      ),
      body: Center(
        child: Text(
          'Diese Person heißt $name.',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
import 'dart:math';

import 'package:connect2/components/graph_view/graph_view_canvas.dart';
import 'package:connect2/components/graph_view/node.dart';
import 'package:flutter/material.dart';

class GraphScreen extends StatefulWidget {
  const GraphScreen({super.key});

  @override
  GraphScreenState createState() => GraphScreenState();
}

class GraphScreenState extends State<GraphScreen> {
  List<Node> nodes = [];
  Random random = Random();

  @override void initState() {
    super.initState();
    // Todo implement loading nodes from contacts
    for (int i = 0; i < 25; i++) {
      nodes.add(
        Node(
          Offset(
            random.nextDouble() * 256,
            random.nextDouble() * 256
          ),
          [],
          false,
          "Hallo Welt"
        )
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO develop pretty empty state
    if (nodes.isEmpty) {
      return const Scaffold(
        body: Center(
          child: Text("Loading...")
        )
      );
    }

    return Scaffold(
      body: Center(
        child: GraphViewCanvas(initialNodes: nodes)
      ),
    );
  }
}
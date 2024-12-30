import 'dart:math';

import 'package:connect2/components/graph_view/graph_view_canvas.dart';
import 'package:connect2/components/graph_view/node.dart';
import 'package:connect2/services/contact_service.dart';
import 'package:flutter/material.dart';

class GraphScreen extends StatefulWidget {
  const GraphScreen({super.key});

  @override
  GraphScreenState createState() => GraphScreenState();
}

class GraphScreenState extends State<GraphScreen> {
  List<Node> nodes = [];
  Random random = Random();
  ContactService contactService = ContactService();

  @override
  void initState() {
    super.initState();
    _initNodes();
  }

  void _initNodes() async {
    // Asynchron auf neue Nodes warten
    final newNodes = await contactService.getGraphViewNodes();

    // setState synchron aufrufen
    if (mounted) {
      setState(() {
        nodes = newNodes;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO develop pretty empty state
    if (nodes.isEmpty) {
      return const Scaffold(body: Center(child: Text("Loading...")));
    }

    return Scaffold(
      body: Center(child: GraphViewCanvas(initialNodes: nodes)),
    );
  }
}

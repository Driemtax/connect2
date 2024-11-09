import 'dart:async';
import 'dart:math';

import 'package:connect2/components/graph_view/force_directed_graph_algorithm.dart';
import 'package:connect2/components/graph_view/node.dart';
import 'package:flutter/material.dart';

class GraphViewCanvas extends StatefulWidget {
  const GraphViewCanvas({super.key});

  @override
  GraphViewState createState() => GraphViewState();
}

class GraphViewState extends State<GraphViewCanvas> {
  List<Node> nodes = [];
  Random random = Random();

  @override
  void initState() {
    super.initState();
    nodes.add(Node(const Offset(150.0, 300.0), [], true, "Center Force"));
    for (int i = 0; i < 30; i++) {
      nodes.add(Node(
          Offset(random.nextDouble() * 256, random.nextDouble() * 256),
          [],
          false, "Lukas Heberling"));
    }

    // Center force node
    for (var node in nodes) {
      node.addEdgeTo(nodes[0]);
      nodes[0].addEdgeTo(node);
    }

    nodes[1].addEdgeTo(nodes[0]);
    nodes[0].addEdgeTo(nodes[1]);
    nodes[12].addEdgeTo(nodes[0]);
    nodes[0].addEdgeTo(nodes[12]);

    for (int i = 2; i < 12; i++) {
      nodes[1].addEdgeTo(nodes[i]);
      nodes[i].addEdgeTo(nodes[1]);
    }

    for (int i = 12; i < 25; i++) {
      nodes[12].addEdgeTo(nodes[i]);
      nodes[i].addEdgeTo(nodes[12]);
    }

    Timer.periodic(const Duration(milliseconds: 3), (timer) {
      setState(() {
        nodes = eadesAlgorithm(nodes);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CustomPaint(
        size: const Size(300, 600),
        painter: GraphPainter(nodes, Theme.of(context).primaryColor, Theme.of(context).focusColor, random),
      ),
    );
  }
}

class GraphPainter extends CustomPainter {
  final List<Node> nodes;
  final Color nodeColor;
  final Color edgeColor;
  Random random;

  GraphPainter(this.nodes, this.nodeColor, this.edgeColor, this.random);

  @override
  void paint(Canvas canvas, Size size) {
    final nodePaint = Paint()
      ..color = nodeColor
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 5.0;

    final edgePaint = Paint()
      ..color = edgeColor
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 1.0;
    const textStyle = TextStyle(
      color: Colors.black,
      fontSize: 10,
    );

    for (var node in nodes) {
      final textSpan = TextSpan(
        text: node.name,
        style: textStyle,
      );
      final textPainter = TextPainter(text: textSpan, textDirection: TextDirection.ltr);
      textPainter.layout(
        minWidth: 0,
        maxWidth: size.width,
      );
      for (var toNode in node.edgesTo) {
        canvas.drawLine(node.pos, toNode.pos, edgePaint);
      }
      canvas.drawCircle(node.pos, 5, nodePaint);
      textPainter.paint(canvas, Offset(node.pos.dx - (textPainter.size.width / 2), node.pos.dy - 17.5));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

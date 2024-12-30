import 'dart:async';
import 'dart:math';

import 'package:connect2/components/graph_view/force_directed_graph_algorithm.dart';
import 'package:connect2/components/graph_view/node.dart';
import 'package:connect2/screens/dummy_person.dart';
import 'package:flutter/material.dart';

class GraphViewCanvas extends StatefulWidget {
  final List<Node> initialNodes;
  const GraphViewCanvas({super.key, required this.initialNodes});

  @override
  GraphViewCanvasState createState() => GraphViewCanvasState();
}

class GraphViewCanvasState extends State<GraphViewCanvas> {
  List<Node> nodes = [];
  Random random = Random();
  Timer? _timer;
  Offset graphOffset = Offset.zero; // Offset für Verschiebungen

  @override
  void initState() {
    super.initState();
    nodes = List.from(widget.initialNodes);
    Node centerForce =
        Node(const Offset(150.0, 300.0), [], NodeType.centerNode, '');
    for (var node in nodes) {
      connectNodes(node, centerForce);
    }
    nodes.add(centerForce);

    _timer = Timer.periodic(const Duration(milliseconds: 3), (timer) {
      if (mounted) {
        setState(() {
          nodes = forceDirectedGraphAlgorithm(nodes);
        });
      } else {
        timer.cancel();
      }
    });

    Future.delayed(const Duration(seconds: 10), () {
      _timer?.cancel();
    });
  }

  void handleNodeTap(Node tappedNode) {
    if (tappedNode.nodeType == NodeType.node) {
      // TODO Change this route to the real person routeee!
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DummyPersonView(name: tappedNode.name),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: (details) {
        setState(() {
          graphOffset += details.delta;
        });
      },
      onTapDown: (details) {
        final tapPosition = details.localPosition - graphOffset;
        for (var node in nodes) {
          final distance = (node.pos - tapPosition).distance;
          if (distance <= 10) {
            handleNodeTap(node);
            return;
          }
        }
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          final canvasSize = Size(constraints.maxWidth, constraints.maxHeight);

          return CustomPaint(
            size: canvasSize,
            painter: GraphPainter(
              nodes,
              Theme.of(context).primaryColor,
              Theme.of(context).focusColor,
              random,
              Theme.of(context).primaryColorDark,
              graphOffset,
            ),
          );
        },
      ),
    );
  }
}

class GraphPainter extends CustomPainter {
  final List<Node> nodes;
  final Color nodeColor;
  final Color tagColor;
  final Color edgeColor;
  final Random random;
  final Offset graphOffset;

  GraphPainter(this.nodes, this.nodeColor, this.edgeColor, this.random,
      this.tagColor, this.graphOffset);

  @override
  void paint(Canvas canvas, Size size) {
    final nodePaint = Paint()
      ..color = nodeColor
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 5.0;

    final tagPaint = Paint()
      ..color = tagColor
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
      final textPainter =
          TextPainter(text: textSpan, textDirection: TextDirection.ltr);
      textPainter.layout(
        minWidth: 0,
        maxWidth: size.width,
      );

      for (var toNode in node.edgesTo) {
        if (toNode.nodeType != NodeType.centerNode &&
            node.nodeType != NodeType.centerNode) {
          canvas.drawLine(
              node.pos + graphOffset, toNode.pos + graphOffset, edgePaint);
        }
      }
      if (node.nodeType != NodeType.centerNode) {
        canvas.drawCircle(node.pos + graphOffset, 5,
            node.nodeType == NodeType.node ? nodePaint : tagPaint);
        textPainter.paint(
            canvas,
            Offset(node.pos.dx + graphOffset.dx - (textPainter.size.width / 2),
                node.pos.dy + graphOffset.dy - 17.5));
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

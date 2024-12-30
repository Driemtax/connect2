import 'package:flutter/services.dart';

enum NodeType { node, centerNode, tag }

void connectNodes(Node fromNode, Node toNode) {
  fromNode.addEdgeTo(toNode);
  toNode.addEdgeTo(fromNode);
}

class Node {
  Offset pos;
  List<Node> edgesTo = [];
  NodeType nodeType;
  String name;
  String? phoneContactId;

  Node({
    required this.pos,
    this.nodeType = NodeType.node,
    this.name = '',
    this.phoneContactId,
  });

  void addEdgeTo(Node toNode) {
    edgesTo.add(toNode);
  }

  void addDisplacement(Offset displacementVector) {
    if (nodeType != NodeType.centerNode) {
      pos = pos + displacementVector;
    }
  }
}

import 'package:flutter/services.dart';

enum NodeType { node, centerNode, tag}

void connectNodes(Node fromNode, Node toNode) {
  fromNode.addEdgeTo(toNode);
  toNode.addEdgeTo(fromNode);
}

class Node {
  Offset pos;
  List<Node> edgesTo;
  NodeType nodeType = NodeType.node;
  String name;

  Node(this.pos, this.edgesTo, this.nodeType, this.name);

  void addEdgeTo(Node toNode) {
    edgesTo.add(toNode);
  }

  void addDisplacement(Offset displacementVector) {
    if (nodeType != NodeType.centerNode) {
      pos = pos + displacementVector;
    }
  }
}

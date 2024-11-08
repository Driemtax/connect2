import 'package:flutter/services.dart';

class Node {
  Offset pos;
  List<Node> edgesTo;
  bool centerNode;

  Node(this.pos, this.edgesTo, this.centerNode);

  void addEdgeTo(Node toNode) {
    edgesTo.add(toNode);
  }

  void addDisplacement(Offset displacementVector) {
    if (!centerNode) {
      pos = pos + displacementVector;
    }
  }
}

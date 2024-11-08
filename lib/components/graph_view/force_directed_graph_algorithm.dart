import 'dart:math';
import 'dart:ui';

import 'package:connect2/components/graph_view/node.dart';

const double repulsionConstant = 1000.0;
const double springConstant = 0.1;
const double idealSpringLength = 5.0;
const double dampingFactor = 0.95; 

double calcEuclideanDistance(Offset p1, Offset p2) {
  double dx = p2.dx - p1.dx;
  double dy = p2.dy - p1.dy;
  return sqrt(dx * dx + dy * dy);
}

Offset calcUnitVector(Offset p1, Offset p2) {
  double length = calcEuclideanDistance(p1, p2);
  double dx = p2.dx - p1.dx;
  double dy = p2.dy - p1.dy;
  if (length == 0) return Offset.zero;
  return Offset(dx / length, dy / length);
}

Offset getRepulsiveForce(Node n1, Node n2) {
  double distance = calcEuclideanDistance(n1.pos, n2.pos) + 1e-9;
  double repulsiveForce = repulsionConstant / (distance * distance);
  Offset direction = calcUnitVector(n2.pos, n1.pos);
  return direction * repulsiveForce;
}

Offset getAttractiveForce(Node n1, Node n2) {
  double distance = calcEuclideanDistance(n1.pos, n2.pos) + 1e-9;
  double attractiveForce = springConstant * log(distance / idealSpringLength);
  Offset direction = calcUnitVector(n1.pos, n2.pos);
  return direction * attractiveForce;
}

Offset calcDisplacement(Node currentNode, List<Node> nodes) {
  Offset totalDisplacement = Offset.zero;
  for (var node in nodes) {
    if (node != currentNode) {
      totalDisplacement += getRepulsiveForce(currentNode, node);
    }
  }
  for (var neighbor in currentNode.edgesTo) {
    totalDisplacement += getAttractiveForce(currentNode, neighbor);
  }
  return totalDisplacement * dampingFactor;
}

List<Node> eadesAlgorithm(List<Node> nodes) {
  for (int i = 0; i < 5; i++) {
    for (var node in nodes) {
      Offset displacement = calcDisplacement(node, nodes);
      node.addDisplacement(displacement);
    }
  }
  return nodes;
}

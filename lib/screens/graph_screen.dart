import 'package:connect2/components/graph_view/graph_view_canvas.dart';
import 'package:connect2/components/graph_view/node.dart';
import 'package:connect2/services/contact_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

class GraphScreen extends StatefulWidget {
  const GraphScreen({super.key});

  @override
  GraphScreenState createState() => GraphScreenState();
}

class GraphScreenState extends State<GraphScreen> {
  List<Node> nodes = [];
  ContactService contactService = ContactService();

  @override
  void initState() {
    super.initState();
    _initNodes();
  }

  void _initNodes() async {
    final newNodes = await contactService.getGraphViewNodes();
    if (mounted) {
      setState(() => nodes = newNodes);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (nodes.isEmpty) {
      return Scaffold(
        body: Center(
          child: Text(FlutterI18n.translate(context, "graph_screen.loading"))
        )
      );
    }

    return Scaffold(
      body: Center(child: GraphViewCanvas(initialNodes: nodes)),
    );
  }
}

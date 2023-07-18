import 'package:flutter/material.dart';

class MyHomePage1 extends StatefulWidget {
  const MyHomePage1({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage1> createState() => _MyHomePage1State();
}

class _MyHomePage1State extends State<MyHomePage1> {
  final List<Widget> boxes = [
    Box(Colors.blue[100]!, key: UniqueKey()),
    Box(Colors.blue[300]!, key: UniqueKey()),
    Box(Colors.blue[500]!, key: UniqueKey()),
    Box(Colors.blue[700]!, key: UniqueKey()),
    Box(Colors.blue[900]!, key: UniqueKey()),
  ];

  _shuffle() {
    setState(() {
      boxes.shuffle();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: ReorderableListView(
          onReorder: (int oldIndex, int newIndex) {
            // 从下往上没问题，但是从上往下就有坑
            final box = boxes.removeAt(oldIndex);
            boxes.insert(newIndex, box);
          },
          children: boxes,

        )
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _shuffle();
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class Box extends StatelessWidget {
  
  final Color color;

  const Box(this.color, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8.0),
      width: 50,
      height: 50,
      color: color,
    );
  }
}

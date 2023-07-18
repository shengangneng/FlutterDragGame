import 'dart:ffi';

import 'package:flutter/material.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // final List<Widget> boxes = [
  //   Box(Colors.blue[100]!, 50.0, 50.0, key: UniqueKey()),
  //   Box(Colors.blue[300]!, 100.0, 100.0, key: UniqueKey()),
  //   Box(Colors.blue[500]!, 150.0, 150.0, key: UniqueKey()),
  //   Box(Colors.blue[700]!, 200.0, 200.0, key: UniqueKey()),
  //   Box(Colors.blue[900]!, 250.0, 250.0, key: UniqueKey()),
  // ];
  
  // final _colors = [
  //   Colors.blue[100]!,
  //   Colors.blue[300]!,
  //   Colors.blue[500]!,
  //   Colors.blue[700]!,
  //   Colors.blue[900]!,
  // ];
  final _colors = List.generate(8, (index) => Colors.blue[(index + 1) * 100]);

  int _blockIndex = 0;
  final _stackKey = GlobalKey();
  double? _stackHeight = 76;

  _shuffle() {
    setState(() {
      _colors.shuffle();
    });
  }

  _checkColor() {
    for (int i = 0; i < _colors.length - 1; i++) {
      // computeLuminance是亮度，亮度越大，代表颜色越深
      double? iN = _colors[i]!.computeLuminance();
      double? iN1 = _colors[i + 1]!.computeLuminance();
      print("$iN --- $iN1");
      if (iN! > iN1!) {
        return;
      }
    }
    showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: const Text('You Win!'),
          children: [
            SimpleDialogOption(
              child: const Text('Play Again'),
              onPressed: () {
                Navigator.pop(context, true);
                _shuffle();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _shuffle();
  }

  @override
  Widget build(BuildContext context) {
    
    final screenSize = MediaQuery.of(context).size;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
              onPressed: () {
                _shuffle();
              },
              icon: const Icon(Icons.refresh))
        ],
      ),
      body: Center(
          child: Column(
            children: [
              const SizedBox(height: 30),
              const Text("拖动色块，完成从深到浅的排序",
                style: TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 24),
              Container(
                margin: const EdgeInsets.all(0),
                width: Box.itemWidth - Box.itemPadding * 2,
                height: Box.itemHeight - Box.itemPadding * 2,
                decoration: BoxDecoration(
                    color: Colors.blue[900],
                    borderRadius: BorderRadius.circular(5)
                ),
                child: const Icon(Icons.lock, color: Colors.white),
              ),
              Expanded(
                child: Listener(
                  onPointerMove: (event) {
                    // print(event);
                    final y = event.position.dy - _stackHeight!;
                    if (y > (_blockIndex + 1) * Box.itemHeight) {
                      // move to right
                      if (_blockIndex >= _colors.length - 1) return;
                      setState(() {
                        final temp = _colors[_blockIndex];
                        _colors[_blockIndex] = _colors[_blockIndex + 1];
                        _colors[_blockIndex + 1] = temp;
                        _blockIndex++;
                      });
                    } else if (y < (_blockIndex * Box.itemHeight)) {
                      // move to left
                      if (_blockIndex <= 0) return;
                      setState(() {
                        final temp = _colors[_blockIndex];
                        _colors[_blockIndex] = _colors[_blockIndex - 1];
                        _colors[_blockIndex - 1] = temp;
                        _blockIndex--;
                      });
                    }
                  },
                  child: Stack(
                    key: _stackKey,
                    children: List.generate(_colors.length, (i) => Box(
                      _colors[i],
                      (screenSize.width - Box.itemWidth) / 2 - 5,
                      50.0*i,
                      onDragStarted: (color) {
                        // _stackHeight = _stackKey.currentContext?.size?.height;
                        // localToGlobal就是把自己的位置转换到全屏的位置。
                        _stackHeight = (_stackKey.currentContext?.findRenderObject() as RenderBox).localToGlobal(Offset.zero).dy;

                        final index = _colors.indexOf(color);
                        _blockIndex = index;
                      },
                      onDragEnded: () {
                        print("heee");
                        _checkColor();
                      },
                      key: ValueKey(_colors[i]),)),
                  ),
                ),
              ),
            ],
          )
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class Box extends StatelessWidget {

  static const itemWidth = 300.0;
  static const itemHeight = 50.0;
  static const itemPadding = 2.0;
  static const itemPaddingOnDrag = 4.0;
  static const itemMargin = 8.0;
  static const animatedDuration = 200;

  final Color? color;
  final double? x;
  final double? y;
  final Function(Color)? onDragStarted;
  final Function()? onDragEnded;

  const Box(this.color, this.x, this.y, {this.onDragStarted, this.onDragEnded, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 这个final定义在build方法里面，和放在外面是不一样的。
    final container = Container(
      margin: const EdgeInsets.all(itemMargin),
      width: itemWidth - itemPadding * 2,
      height: itemHeight - itemPadding * 2,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(5)
      ),
    );
    final bigContainer = Container(
      // 手势放上去之后，变大
      margin: const EdgeInsets.all(itemMargin - itemPaddingOnDrag),
      width: itemWidth + itemPadding * 2 + itemPaddingOnDrag * 2,
      height: itemHeight + itemPadding * 2 + itemPaddingOnDrag * 2,
      decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(5)
      ),
    );

    return AnimatedPositioned(
        top: y,
        left: x,
        duration: const Duration(milliseconds: animatedDuration),
        child: Draggable(
          onDragStarted: () => onDragStarted!(color!),
          onDragEnd: (detail) => onDragEnded!(),
          feedback: bigContainer,
          childWhenDragging: Visibility(
            visible: false,
              child: container
          ),
          child: container,
        ));
  }
}
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

class DragHandler extends StatelessWidget {
  const DragHandler({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Listener(
      // When any pointer is pressed, start dragging the window.
      onPointerDown: (_) async => await windowManager.startDragging(),
      child: const SizedBox.expand(),
    );
  }
}

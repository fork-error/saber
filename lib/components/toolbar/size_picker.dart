
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:saber/components/canvas/tools/pen.dart';
import 'package:saber/i18n/strings.g.dart';

class SizePicker extends StatefulWidget {
  const SizePicker({
    super.key,
    required this.pen,
  });

  final Pen pen;

  @override
  State<SizePicker> createState() => _SizePickerState();
}

class _SizePickerState extends State<SizePicker> {

  final TextEditingController _controller = TextEditingController();

  Offset? startingOffset;
  double startingValue = 0;

  @override
  void initState() {
    super.initState();
    updateValue();
    _controller.addListener(() {
      updateValue(
        newValue: double.tryParse(_controller.text),
        manuallyTypedIn: true,
      );
    });
  }

  Timer? updateTextFieldTimer;
  void updateValue({double? newValue, bool manuallyTypedIn = false}) {
    if (newValue != null) {
      setState(() {
        widget.pen.strokeProperties.size = newValue.clamp(widget.pen.sizeMin, widget.pen.sizeMax).roundToDouble();
      });
    }

    String valueString = widget.pen.strokeProperties.size.round().toString();
    updateTextFieldTimer?.cancel();
    if (manuallyTypedIn) {
      updateTextFieldTimer = Timer(const Duration(milliseconds: 3000), () {
        _controller.text = valueString;
      });
    } else if (_controller.text != valueString) {
      _controller.text = valueString;
    }
  }

  void onDrag(Offset currentOffset) {
    if (startingOffset == null) return;

    final double delta = (currentOffset.dx - startingOffset!.dx) / widget.pen.sizeMax * 4 * widget.pen.sizeStep;
    final double newValue = startingValue + delta ~/ widget.pen.sizeStep * widget.pen.sizeStep;
    setState(() {
      updateValue(newValue: newValue);
    });
  }

  @override
  void didUpdateWidget(SizePicker oldWidget) {
    updateValue();
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return MouseRegion(
      cursor: SystemMouseCursors.resizeLeftRight,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanStart: (DragStartDetails details) {
          startingOffset = details.globalPosition;
          startingValue = widget.pen.strokeProperties.size;
        },
        onPanUpdate: (DragUpdateDetails details) {
          onDrag(details.globalPosition);
        },
        onPanEnd: (DragEndDetails details) {
          startingOffset = null;
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            children: [
              Text(t.editor.penOptions.size),
              Container(
                width: 25,
                height: 25,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: colorScheme.onBackground,
                    width: 1,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 100),
                    width: widget.pen.strokeProperties.size / widget.pen.sizeMax * 25,
                    height: widget.pen.strokeProperties.size / widget.pen.sizeMax * 25,
                    decoration: BoxDecoration(
                      color: colorScheme.onBackground,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 30,
                child: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.only(top: 2),
                  ),
                  style: const TextStyle(
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

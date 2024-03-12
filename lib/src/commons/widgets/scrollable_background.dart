import 'package:phone_cleaner/src/commons/commons.dart';
import 'package:flutter/material.dart';

class ScrollableBackground extends StatefulWidget {
  final ScrollController scrollController;
  final bool isSecondaryBackground;
  const ScrollableBackground({
    Key? key,
    required this.scrollController,
    this.isSecondaryBackground = true,
  }) : super(key: key);

  @override
  State<ScrollableBackground> createState() => ScrollableBackgroundState();
}

class ScrollableBackgroundState extends State<ScrollableBackground> {
  var _offset = 0.0;

  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(_syncOffset);
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_syncOffset);
    super.dispose();
  }

  void _syncOffset() {
    if (!mounted) return;
    setState(() {
      _offset = widget.scrollController.offset;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(0, -_offset),
      child: Background(
        secondaryBackground: widget.isSecondaryBackground,
      ),
    );
  }
}

import 'dart:io';

import 'package:flutter/material.dart';

class ImageCard extends StatelessWidget {
  const ImageCard({
    Key? key,
    required this.width,
    required this.height,
    required this.source,
  }) : super(key: key);

  final double width;
  final double height;
  final String source;

  @override
  Widget build(BuildContext context) {
    final pixelRatio = MediaQuery.of(context).devicePixelRatio;
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          width: 4,
          color: Colors.white,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.15),
            offset: Offset(0, 4),
            blurRadius: 4,
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Image.file(
          File(source),
          cacheHeight: (height * pixelRatio).toInt(),
          errorBuilder: (context, error, stackTrace) {
            // Logger().d('$error $source $stackTrace');
            return const Placeholder();
          },
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

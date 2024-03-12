import 'package:flutter/material.dart';

class ImageBorderGradient extends StatelessWidget {
  const ImageBorderGradient({
    Key? key,
    this.pngPath,
    this.width,
    this.height,
  }) : super(key: key);

  final String? pngPath;
  final double? width;
  final double? height;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? 135,
      height: height ?? 135,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        // gradient: const LinearGradient(
        //   colors: [
        //     Color.fromRGBO(54, 171, 153, 1),
        //     Color.fromRGBO(123, 204, 188, 0.57)
        //   ],
        // ),
        color: const Color.fromRGBO(66, 133, 244, 1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: width != null ? width! - 2 : 133,
        height: height != null ? height! - 2 : 133,
        decoration: pngPath != null
            ? BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                image: DecorationImage(
                  image: AssetImage(pngPath!),
                  fit: BoxFit.cover,
                ))
            : BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.blue,
              ),
      ),
    );
  }
}

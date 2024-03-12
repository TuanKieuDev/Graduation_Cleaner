// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'package:phone_cleaner/services/logger/logger.dart';
import 'package:phone_cleaner/src/commons/commons.dart';
import 'package:phone_cleaner/src/features/file/file.dart';
import 'package:phone_cleaner/src/themes/themes.dart';

class FilePreview extends StatelessWidget {
  const FilePreview({
    Key? key,
    this.width,
    this.height,
    required this.data,
  }) : super(key: key);

  final double? width;
  final double? height;
  final FileCheckboxItemData? data;

  @override
  Widget build(BuildContext context) {
    if (data == null) {
      return const SizedBox.square(
        dimension: imageDisplaySize + .0,
      );
    }

    if (data!.fileType == FileType.photo) {
      return LayoutBuilder(
        builder: (context, constraints) {
          return ImagePreview(
            path: data!.path,
            mediaId: data!.mediaId,
            mediaType: data!.mediaType,
            extension: data!.extensionFile,
            width: width ?? constraints.maxWidth,
            height: height ?? constraints.maxHeight,
          );
        },
      );
    }

    if (data!.fileType == FileType.video) {
      return LayoutBuilder(
        builder: (context, constraints) {
          return VideoPreview(
            mediaId: data!.mediaId,
            mediaType: data!.mediaType,
            width: width ?? constraints.maxWidth,
            height: height ?? constraints.maxHeight,
          );
        },
      );
    }

    if (data!.fileType == FileType.audio) {
      return LayoutBuilder(builder: (context, constraints) {
        return AudioPreview(
          path: data!.path,
          width: width ?? constraints.maxWidth,
          height: height ?? constraints.maxHeight,
        );
      });
    }

    return SizedBox.expand(
      child: Center(
        child: Text(
          data!.extensionFile,
          style: semibold18.copyWith(
            color: CleanerColor.of(context)!.neutral1,
          ),
        ),
      ),
    );
  }
}

class ImagePreview extends StatefulWidget {
  const ImagePreview({
    Key? key,
    required this.path,
    required this.mediaId,
    required this.mediaType,
    required this.extension,
    this.width,
    this.height,
  }) : super(key: key);

  final String path;
  final int mediaId;
  final int mediaType;
  final String extension;
  final double? width;
  final double? height;

  @override
  State<ImagePreview> createState() => _ImagePreviewState();
}

class _ImagePreviewState extends State<ImagePreview> {
  final fileManager = FileManager();

  Uint8List? thumbnail;
  bool hasError = false;
  late int heightCacheSize = widget.height?.round() ?? imageDisplaySize;
  late int widthCacheSize = widget.width?.round() ?? imageDisplaySize;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      heightCacheSize = _calculateHeightCacheSize(context);
      widthCacheSize = _calculateWidthCacheSize(context);
      _getImageThumbnail(heightCacheSize, widthCacheSize);
    });
  }

  @override
  void didUpdateWidget(covariant ImagePreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.height != widget.height) {
      heightCacheSize = _calculateHeightCacheSize(context);
    }

    if (oldWidget.width != widget.width) {
      widthCacheSize = _calculateWidthCacheSize(context);
    }

    if (oldWidget.mediaId != widget.mediaId) {
      thumbnail = null;
      _getImageThumbnail(heightCacheSize, widthCacheSize);
    }
  }

  int _calculateHeightCacheSize(BuildContext context) {
    final pixelRatio = MediaQuery.of(context).devicePixelRatio;
    final cacheSize = widget.height == null
        ? imageDisplaySize
        : (widget.height! * pixelRatio).toInt();
    return cacheSize;
  }

  int _calculateWidthCacheSize(BuildContext context) {
    final pixelRatio = MediaQuery.of(context).devicePixelRatio;
    final cacheSize = widget.width == null
        ? imageDisplaySize
        : (widget.width! * pixelRatio).toInt();
    return cacheSize;
  }

  Future<Uint8List?> _getImageThumbnail(
      int heightCacheSize, int widthCacheSize) async {
    var data = await fileManager
        .loadPhotoOrVideoThumbnail(widget.mediaId, widget.mediaType,
            max(heightCacheSize, widthCacheSize))
        .onError((error, stackTrace) {
      if (mounted) {
        setState(() {
          hasError = true;
        });
      }
      return null;
    });

    if (mounted) {
      setState(() {
        thumbnail = data;
      });
    }

    return data;
  }

  @override
  Widget build(BuildContext context) {
    final cleanerColor = CleanerColor.of(context)!;
    if (hasError) {
      return Image.file(
        File(widget.path),
        cacheHeight: max(heightCacheSize, widthCacheSize),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Center(
            child: Text(
              widget.extension,
              style: semibold18.copyWith(
                color: CleanerColor.of(context)!.neutral1,
              ),
            ),
          );
        },
      );
    }
    return Stack(
      alignment: Alignment.center,
      children: [
        const SizedBox.expand(
          child: DecoratedBox(
            decoration: BoxDecoration(color: Colors.white),
          ),
        ),
        AnimatedOpacity(
          opacity: thumbnail == null ? 0.0 : 1.0,
          duration: const Duration(milliseconds: 300),
          child: thumbnail == null
              ? Container(
                  width: widget.width,
                  height: widget.height,
                  color: cleanerColor.neutral3,
                )
              : Image.memory(
                  thumbnail!,
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                ),
        ),
      ],
    );
  }
}

class VideoPreview extends StatefulWidget {
  final int mediaId;
  final int mediaType;
  final double? width;
  final double? height;

  const VideoPreview({
    Key? key,
    required this.mediaId,
    required this.mediaType,
    this.width,
    this.height,
  }) : super(key: key);

  @override
  State<VideoPreview> createState() => _VideoPreviewState();
}

class _VideoPreviewState extends State<VideoPreview> {
  final fileManager = FileManager();

  Uint8List? thumbnail;
  bool hasError = false;
  late int heightCacheSize = widget.height?.round() ?? imageDisplaySize;
  late int widthCacheSize = widget.width?.round() ?? imageDisplaySize;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      heightCacheSize = _calculateHeightCacheSize(context);
      widthCacheSize = _calculateWidthCacheSize(context);
      _getVideoThumbnail(heightCacheSize, widthCacheSize);
    });
  }

  @override
  void didUpdateWidget(covariant VideoPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.height != widget.height) {
      heightCacheSize = _calculateHeightCacheSize(context);
    }

    if (oldWidget.width != widget.width) {
      widthCacheSize = _calculateWidthCacheSize(context);
    }

    if (oldWidget.mediaId != widget.mediaId) {
      thumbnail = null;
      _getVideoThumbnail(heightCacheSize, widthCacheSize);
    }
  }

  int _calculateHeightCacheSize(BuildContext context) {
    final pixelRatio = MediaQuery.of(context).devicePixelRatio;
    final cacheSize = widget.height == null
        ? imageDisplaySize
        : (widget.height! * pixelRatio).toInt();
    return cacheSize;
  }

  int _calculateWidthCacheSize(BuildContext context) {
    final pixelRatio = MediaQuery.of(context).devicePixelRatio;
    final cacheSize = widget.width == null
        ? imageDisplaySize
        : (widget.width! * pixelRatio).toInt();
    return cacheSize;
  }

  Future<Uint8List?> _getVideoThumbnail(
      int heightCacheSize, int widthCacheSize) async {
    final cacheSize = max(heightCacheSize, widthCacheSize) * 2;

    var data = await fileManager.loadPhotoOrVideoThumbnail(
        widget.mediaId, widget.mediaType, cacheSize);
    if (mounted) {
      setState(() {
        thumbnail = data;
      });
    }

    return data;
  }

  @override
  Widget build(BuildContext context) {
    final cleanerColor = CleanerColor.of(context)!;
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Stack(
        alignment: Alignment.center,
        children: [
          const SizedBox.expand(
            child: DecoratedBox(
              decoration: BoxDecoration(color: Colors.white),
            ),
          ),
          AnimatedOpacity(
            opacity: thumbnail == null ? 0.0 : 1.0,
            duration: const Duration(milliseconds: 300),
            child: thumbnail == null
                ? Container(
                    width: widget.width,
                    height: widget.height,
                    color: cleanerColor.neutral3,
                  )
                : Image.memory(
                    thumbnail!,
                    // cacheHeight: heightCacheSize > widthCacheSize
                    //     ? heightCacheSize
                    //     : null,
                    // cacheWidth: widthCacheSize > heightCacheSize
                    //     ? widthCacheSize
                    //     : null,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                  ),
          ),
          SvgPicture.asset(
            "assets/icons/file/play_video.svg",
            width: 30,
            height: 30,
          ),
        ],
      ),
    );
  }
}

class AudioPreview extends StatefulWidget {
  final String path;
  final double? width;
  final double? height;

  const AudioPreview({
    Key? key,
    required this.path,
    this.width,
    this.height,
  }) : super(key: key);

  @override
  State<AudioPreview> createState() => _AudioPreviewState();
}

class _AudioPreviewState extends State<AudioPreview> {
  Uint8List? thumbnail;
  bool hasError = false;
  late int heightCacheSize = widget.height?.round() ?? imageDisplaySize;
  late int widthCacheSize = widget.width?.round() ?? imageDisplaySize;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _getAudioThumbnail();
    });
  }

  @override
  void didUpdateWidget(covariant AudioPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.path != widget.path) {
      thumbnail = null;
      _getAudioThumbnail();
    }
  }

  Future<Uint8List?> _getAudioThumbnail() async {
    if (thumbnail != null) return thumbnail!;
    final fileManager = FileManager();
    final data = await fileManager.loadAudioThumbnail(widget.path);
    if (mounted) {
      setState(() {
        thumbnail = data;
      });
    }
    return data;
  }

  @override
  Widget build(BuildContext context) {
    appLogger.debug("AudioPreview build");
    final cleanerColor = CleanerColor.of(context)!;
    return Center(
      child: SizedBox(
        width: widget.width,
        height: widget.height,
        child: Stack(
          children: [
            const SizedBox.expand(
              child: DecoratedBox(
                decoration: BoxDecoration(color: Colors.white),
              ),
            ),
            if (thumbnail == null || thumbnail!.isEmpty)
              Center(
                child: SvgPicture.asset(
                  "assets/icons/sound.svg",
                  width: 30,
                  height: 30,
                ),
              ),
            AnimatedOpacity(
              opacity: thumbnail != null && thumbnail!.isNotEmpty ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: thumbnail != null && thumbnail!.isNotEmpty
                  ? Image.memory(
                      thumbnail!,
                      // cacheHeight: heightCacheSize > widthCacheSize
                      //     ? heightCacheSize
                      //     : null,
                      // cacheWidth: widthCacheSize > heightCacheSize
                      //     ? widthCacheSize
                      //     : null,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      width: widget.width,
                      height: widget.height,
                      color: cleanerColor.neutral3,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

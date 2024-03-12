// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

import 'package:phone_cleaner/src/features/file/features/photo_optimizer/controllers/linked_photo_controller_group.dart';

typedef PhotoWidgetBuilder = Widget Function(
  BuildContext context,
  Widget firstPreviewPhoto,
  Widget secondPreviewPhoto,
);

class DualPreviewPhoto extends StatefulWidget {
  const DualPreviewPhoto({
    Key? key,
    required this.firstImageProvider,
    required this.secondImageProvider,
    required this.photoWidgetBuilder,
  }) : super(key: key);

  final FutureOr<ImageProvider>? firstImageProvider;
  final FutureOr<ImageProvider>? secondImageProvider;
  final PhotoWidgetBuilder photoWidgetBuilder;

  @override
  State<DualPreviewPhoto> createState() => _DualPreviewPhotoState();
}

class _DualPreviewPhotoState extends State<DualPreviewPhoto> {
  late LinkedPhotoViewControllerGroup linkedControllers;
  late PhotoViewControllerBase firstController;
  late PhotoViewControllerBase secondController;
  double scaleRatio = 1;

  _ImageProviderHandler? firstImageProviderHandler;
  _ImageProviderHandler? secondImageProviderHandler;

  @override
  void initState() {
    super.initState();
    _initProviderHandlers();

    linkedControllers = LinkedPhotoViewControllerGroup();
    firstController = linkedControllers.addAndGet(1);
    secondController = linkedControllers.addAndGet(scaleRatio);
  }

  void _initProviderHandlers() async {
    if (widget.firstImageProvider != null) {
      firstImageProviderHandler =
          _ImageProviderHandler(await widget.firstImageProvider!)
            ..stream.listen((event) => _updateScaleRatio());
    }

    if (widget.secondImageProvider != null) {
      secondImageProviderHandler =
          _ImageProviderHandler(await widget.secondImageProvider!)
            ..stream.listen((event) => _updateScaleRatio());
    }

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      firstImageProviderHandler?.getImage(context);
      secondImageProviderHandler?.getImage(context);
    });
  }

  void _updateScaleRatio() async {
    if (!(firstImageProviderHandler?.isInitialized ?? false) ||
        !(secondImageProviderHandler?.isInitialized ?? false)) {
      return;
    }

    scaleRatio =
        firstImageProviderHandler!.width! / secondImageProviderHandler!.width!;

    // linkedControllers.updateExternalScale(firstController, 1);
    linkedControllers.updateExternalScale(secondController, scaleRatio);
    // onFirstController(firstController.value);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // We call _getImage here because createLocalImageConfiguration() needs to
    // be called again if the dependencies changed, in case the changes relate
    // to the DefaultAssetBundle, MediaQuery, etc, which that method uses.
    firstImageProviderHandler?.getImage(context);
    secondImageProviderHandler?.getImage(context);
  }

  @override
  void didUpdateWidget(DualPreviewPhoto oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.firstImageProvider != oldWidget.firstImageProvider) {
      if (widget.firstImageProvider is Future) {
        (widget.firstImageProvider as Future<ImageProvider>).then((value) {
          firstImageProviderHandler?.changeImageProvider(context, value);
        });
      } else {
        firstImageProviderHandler?.changeImageProvider(
            context, widget.firstImageProvider as ImageProvider);
      }
    }

    if (widget.secondImageProvider != oldWidget.secondImageProvider) {
      (widget.secondImageProvider as Future<ImageProvider>).then((value) {
        secondImageProviderHandler?.changeImageProvider(context, value);
      });
    }
  }

  @override
  void dispose() {
    firstImageProviderHandler?.dispose();
    secondImageProviderHandler?.dispose();
    linkedControllers.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.photoWidgetBuilder(
      context,
      widget.firstImageProvider == null
          ? const CircularProgressIndicator()
          : FuturePreviewPhoto(
              controller: firstController,
              futureImageProvider: widget.firstImageProvider!,
              // heroAttributes: const PhotoViewHeroAttributes(tag: 'first'),
            ),
      widget.secondImageProvider == null
          ? const CircularProgressIndicator()
          : FuturePreviewPhoto(
              controller: secondController,
              futureImageProvider: widget.secondImageProvider!,
              // heroAttributes: const PhotoViewHeroAttributes(tag: 'second'),
            ),
    );
  }
}

class _ImageProviderHandler {
  _ImageProviderHandler(ImageProvider imageProvider)
      : _imageProvider = imageProvider {
    _streamController = StreamController<Size>();
    stream = _streamController.stream;
  }
  ImageProvider _imageProvider;
  ImageProvider get imageProvider => _imageProvider;

  ImageStream? _imageStream;
  ImageInfo? _imageInfo;

  bool get isInitialized => width != null && height != null;
  int? get width => _imageInfo?.image.width;
  int? get height => _imageInfo?.image.height;

  late final StreamController<Size> _streamController;
  late final Stream<Size> stream;

  void changeImageProvider(BuildContext context, ImageProvider imageProvider) {
    _imageProvider = imageProvider;
    dispose();

    getImage(context);
  }

  void getImage(BuildContext context) {
    final ImageStream? oldImageStream = _imageStream;
    _imageStream =
        imageProvider.resolve(createLocalImageConfiguration(context));

    if (_imageStream!.key != oldImageStream?.key) {
      // If the keys are the same, then we got the same image back, and so we don't
      // need to update the listeners. If the key changed, though, we must make sure
      // to switch our listeners to the new image stream.
      final ImageStreamListener listener = ImageStreamListener(_updateImage);
      oldImageStream?.removeListener(listener);
      _imageStream!.addListener(listener);
    }
  }

  void _updateImage(ImageInfo imageInfo, bool synchronousCall) {
    // Trigger a build whenever the image changes.
    _imageInfo?.dispose();
    _imageInfo = imageInfo;
    _streamController.add(Size(
        imageInfo.image.width.toDouble(), imageInfo.image.height.toDouble()));
  }

  void dispose() {
    _imageStream?.removeListener(ImageStreamListener(_updateImage));
    _imageInfo?.dispose();
    _imageInfo = null;
  }
}

class FuturePreviewPhoto extends StatelessWidget {
  const FuturePreviewPhoto({
    Key? key,
    required this.futureImageProvider,
    this.heroAttributes,
    required this.controller,
  }) : super(key: key);

  final PhotoViewHeroAttributes? heroAttributes;
  final FutureOr<ImageProvider> futureImageProvider;
  final PhotoViewControllerBase<PhotoViewControllerValue> controller;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Future.value(futureImageProvider),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return AnimatedCrossFade(
          crossFadeState: snapshot.hasData
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          firstChild: const Center(
            child: CircularProgressIndicator(),
          ),
          secondChild: snapshot.hasData
              ? PreviewPhoto(
                  heroAttributes: heroAttributes,
                  imageProvider: snapshot.requireData,
                  controller: controller,
                )
              : const SizedBox.shrink(),
          duration: const Duration(seconds: 3),
        );

        // final imageProvider = snapshot.requireData;
        // return PreviewPhoto(
        //   heroAttributes: heroAttributes,
        //   imageProvider: imageProvider,
        //   controller: controller,
        // );
      },
    );
  }
}

class PreviewPhoto extends StatelessWidget {
  const PreviewPhoto({
    Key? key,
    this.heroAttributes,
    required this.imageProvider,
    required this.controller,
  }) : super(key: key);

  final PhotoViewHeroAttributes? heroAttributes;
  final ImageProvider imageProvider;
  final PhotoViewControllerBase<PhotoViewControllerValue> controller;

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: ClipRect(
        child: PhotoView(
          imageProvider: imageProvider,
          backgroundDecoration: const BoxDecoration(color: Colors.transparent),
          gestureDetectorBehavior: HitTestBehavior.opaque,
          minScale: PhotoViewComputedScale.contained * 1.0,
          initialScale: PhotoViewComputedScale.covered,
          heroAttributes: heroAttributes,
          controller: controller,
        ),
      ),
    );
  }
}

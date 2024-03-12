// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:phone_cleaner/src/features/features.dart';
import 'package:phone_cleaner/src/features/file/features/filter/views/layout/file_item.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

import 'package:phone_cleaner/src/commons/commons.dart';

import '../../../themes/themes.dart';

const _previewListHeight = 100.0;
const _photoInfoHeight = 40.0;

class PhotoDetailArgument {
  final int index;
  final int categoryIndex;

  PhotoDetailArgument({
    required this.categoryIndex,
    required this.index,
  });
}

class PhotoDetail extends ConsumerStatefulWidget {
  const PhotoDetail({
    super.key,
    required this.data,
  });

  final PhotoDetailArgument data;

  @override
  ConsumerState<PhotoDetail> createState() => _PhotoDetailState();
}

class _PhotoDetailState extends ConsumerState<PhotoDetail> {
  late PageController pageController;
  late ScrollController scrollController;
  late int currentIndex = widget.data.index;
  late List<FileCheckboxItemData> photos;

  late FileCheckboxItemData? currentPhoto;

  final bool _isDeleting = false;
  @override
  void initState() {
    super.initState();
    pageController = PageController(initialPage: currentIndex);

    scrollController =
        ScrollController(initialScrollOffset: (64 * currentIndex).toDouble());
    photos = ref.read(fileFilterControllerProvider.select((value) => value
            .valueOrNull
            ?.fileDataList[widget.data.categoryIndex]
            .checkboxItems)) ??
        [];

    currentPhoto =
        photos.isNotEmpty ? photos[currentIndex] : photos.firstOrNull;
  }

  void onPageChanged(int index) {
    setState(() {
      currentIndex = index;
      currentPhoto = photos[currentIndex];
    });

    scrollController.animateTo(
      index * 64 - scrollController.position.viewportDimension / 2 + 32,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void onPreviewItemPressed(int index) {
    pageController.jumpToPage(index);
  }

  void toggleFileState(int index) {
    ref
        .read(fileFilterControllerProvider.notifier)
        .toggleFileCheckboxItemDataAtIndex(widget.data.categoryIndex, index);
  }

  @override
  Widget build(BuildContext context) {
    final cleanerColor = CleanerColor.of(context)!;

    if (_isDeleting) {
      return DeleteFileProcessAndResultLottie(
        child: Scaffold(
          backgroundColor: cleanerColor.neutral3,
        ),
      );
    }
    return Scaffold(
      body: Column(
        children: [
          const SecondaryAppBar(title: ''),
          Column(
            children: [
              _PhotoGallery(
                data: photos,
                pageController: pageController,
                onPageChanged: onPageChanged,
              ),
              if (currentPhoto != null)
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                  child: _PhotoInfo(
                    currentIndex: currentIndex,
                    totalCount: photos.length,
                    title: currentPhoto!.name,
                    timeModified: currentPhoto!.timeModified,
                    checked: currentPhoto!.checked,
                    size: currentPhoto!.size,
                  ),
                ),
              _PreviewList(
                itemCount: photos.length,
                currentIndex: currentIndex,
                categoryIndex: widget.data.categoryIndex,
                scrollController: scrollController,
                onPageChanged: onPreviewItemPressed,
              )
            ],
          )
        ],
      ),
    );
  }
}

class _PhotoGallery extends StatelessWidget {
  const _PhotoGallery({
    required this.data,
    required this.pageController,
    required this.onPageChanged,
  });

  final List<FileCheckboxItemData> data;
  final PageController pageController;
  final Function(int index) onPageChanged;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Container(
        width: constraints.maxWidth,
        height: MediaQuery.of(context).size.height -
            _previewListHeight - //FilePreviewListHeight
            _photoInfoHeight - //PhotoInfoHeight
            appBarHeight - //appBarHeight
            16 * 2 - //Padding
            MediaQuery.of(context).viewPadding.top,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
        child: PhotoViewGallery.builder(
          backgroundDecoration: const BoxDecoration(color: Colors.transparent),
          wantKeepAlive: true,
          scrollPhysics: const BouncingScrollPhysics(),
          builder: (BuildContext context, int index) {
            return PhotoViewGalleryPageOptions(
              imageProvider: FileImage(
                File(data[index].path),
              ),
              initialScale: PhotoViewComputedScale.contained,
              maxScale: 3.0,
              minScale: PhotoViewComputedScale.contained,
            );
          },
          itemCount: data.length,
          pageController: pageController,
          onPageChanged: onPageChanged,
        ),
      );
    });
  }
}

class _PhotoInfo extends StatelessWidget {
  const _PhotoInfo({
    Key? key,
    required this.currentIndex,
    required this.totalCount,
    required this.title,
    required this.timeModified,
    required this.checked,
    required this.size,
  }) : super(key: key);

  final int currentIndex;
  final int totalCount;
  final String title;
  final DateTime timeModified;
  final bool checked;
  final DigitalUnit size;

  @override
  Widget build(BuildContext context) {
    final cleanerColor = CleanerColor.of(context)!;
    return SizedBox(
      height: _photoInfoHeight,
      child: Column(
        children: [
          Row(
            children: [
              Text(
                "$currentIndex/$totalCount",
                style: semibold14.copyWith(
                  color: cleanerColor.primary10,
                ),
              ),
              const SizedBox(
                width: 8,
              ),
              // TODO: Padding
              SizedBox(
                width: MediaQuery.of(context).size.width - 100,
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: cleanerColor.primary10),
                ),
              )
            ],
          ),
          const SizedBox(
            height: 8,
          ),
          Row(
            children: [
              Text(
                DateFormat('HH:mm, dd/MM/yyy').format(
                  timeModified,
                ),
                style: regular12.copyWith(
                  color: cleanerColor.neutral1,
                ),
              ),
              const SizedBox(
                width: 8,
              ),
              Text(
                size.toStringOptimal(),
                style: semibold12.copyWith(
                  color:
                      checked ? cleanerColor.primary7 : cleanerColor.neutral5,
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}

class _PreviewList extends StatelessWidget {
  const _PreviewList({
    required this.onPageChanged,
    required this.scrollController,
    required this.categoryIndex,
    required this.currentIndex,
    required this.itemCount,
  });

  final int itemCount;
  final int currentIndex;
  final int categoryIndex;
  final ValueSetter<int> onPageChanged;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _previewListHeight,
      child: ListView.builder(
        itemCount: itemCount,
        scrollDirection: Axis.horizontal,
        controller: scrollController,
        addAutomaticKeepAlives: false,
        itemBuilder: (builder, index) {
          return SizedBox(
            width: 64,
            height: 64,
            child: Stack(
              children: [
                if (index == currentIndex)
                  Container(
                    width: 64,
                    height: 100,
                    decoration: BoxDecoration(
                      color: CleanerColor.of(context)!.primary1,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                FileItem(
                  itemIndex: index,
                  smallItem: true,
                  displayGrid: true,
                  categoryIndex: categoryIndex,
                  onPressed: () => onPageChanged(index),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}

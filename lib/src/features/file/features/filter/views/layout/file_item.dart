// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:phone_cleaner/services/logger/logger.dart';
import 'package:phone_cleaner/src/commons/pages/detail_page.dart';
import 'package:phone_cleaner/src/themes/cleaner_color.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:phone_cleaner/router/router.dart';
import 'package:phone_cleaner/src/commons/commons.dart';
import 'package:phone_cleaner/src/features/file/features/filter/views/layout/file_grid_item.dart';
import 'package:phone_cleaner/src/features/file/features/filter/views/layout/file_list_item.dart';
import 'package:phone_cleaner/src/features/file/file.dart';
import 'package:open_filex/open_filex.dart';

class FileItem extends ConsumerWidget {
  const FileItem({
    super.key,
    required this.itemIndex,
    required this.categoryIndex,
    required this.displayGrid,
    this.smallItem = false,
    this.onPressed,
  });

  final int itemIndex;
  final int categoryIndex;
  final bool displayGrid;
  final bool smallItem;
  final VoidCallback? onPressed;

  @override
  Widget build(context, ref) {
    final data = ref.watch(
      fileFilterControllerProvider.select(
        (value) => value.valueOrNull?.fileDataList
            .elementAtOrNull(categoryIndex)
            ?.checkboxItems
            .elementAtOrNull(itemIndex),
      ),
    );

    void openMenu() {
      if (data == null) return;

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        builder: (context) {
          return DetailPage(
            args: DetailPageArgs(
              name: data.name,
              path: data.path,
              size: data.size.to(DigitalUnitSymbol.byte).value.toInt(),
              lastModified: data.timeModified,
              mimeType: "${data.fileType.mimeTypePrefix}/${data.extensionFile}",
              isCanOpen: data.isFolder ? false : true,
            ),
          );
        },
      );

      return;
    }

    void toggleItem() {
      ref
          .read(fileFilterControllerProvider.notifier)
          .toggleFileCheckboxItemDataAtIndex(categoryIndex, itemIndex);
    }

    void goToPhotoDetail() {
      GoRouter.of(context).pushNamed(
        AppRouter.photoDetail,
        extra: PhotoDetailArgument(
          index: itemIndex,
          categoryIndex: categoryIndex,
        ),
      );
    }

    void onPreviewPressed() {
      if (onPressed != null) {
        onPressed!();
        return;
      }

      if (data == null) {
        return;
      }

      if (data.fileType == FileType.photo) {
        goToPhotoDetail();
        return;
      }

      if (data.fileType == FileType.audio || data.fileType == FileType.video) {
        OpenFilex.open(
          data.path,
          type: "${data.fileType.name}/${data.extensionFile}",
        );
        return;
      }

      OpenFilex.open(data.path);
    }

    appLogger.debug(
        'rebuild: FileItem categoryIndex: $categoryIndex itemIndex: $itemIndex checked: ${data?.checked}');

    return Stack(
      alignment: Alignment.bottomCenter,
      clipBehavior: Clip.none,
      children: [
        displayGrid
            ? FileGridItem(
                data: data,
                smallItem: smallItem,
                onPressed: () => toggleItem(),
                onCheckboxPressed: (_) => toggleItem(),
                onPreviewPressed: () => onPreviewPressed(),
                onLongPressed: () => openMenu(),
              )
            : FileListItem(
                data: data,
                onPressed: () => toggleItem(),
                onCheckboxPressed: (_) => toggleItem(),
                onPreviewPressed: () => onPreviewPressed(),
                onLongPressed: () => openMenu(),
              ),
      ],
    );
  }
}

class _CustomPopupMenuItem<T> extends PopupMenuItem<T> {
  const _CustomPopupMenuItem({
    super.key,
    super.value,
    super.onTap,
    super.enabled = true,
    super.height = kMinInteractiveDimension,
    super.padding,
    super.textStyle,
    super.labelTextStyle,
    super.mouseCursor,
    required super.child,
  }) : super();

  @override
  _CustomPopupMenuItemState<T> createState() => _CustomPopupMenuItemState<T>();
}

class _CustomPopupMenuItemState<T>
    extends PopupMenuItemState<T, _CustomPopupMenuItem<T>> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(
            Radius.circular(8),
          ),
          color: CleanerColor.of(context)!.neutral3,
          boxShadow: const [
            BoxShadow(
              blurRadius: 3,
              spreadRadius: 3,
              color: Color.fromRGBO(0, 0, 0, 0.1),
            )
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 0),
          child: super.build(context),
        ),
      ),
    );
  }
}

class DismissibleDialog<T> extends PopupRoute<T> {
  DismissibleDialog({
    required this.detailArgs,
  });
  final DetailPageArgs detailArgs;

  @override
  Color? get barrierColor => Colors.black.withAlpha(0x50);

  // This allows the popup to be dismissed by tapping the scrim or by pressing
  // the escape key on the keyboard.
  @override
  bool get barrierDismissible => true;

  @override
  String? get barrierLabel => 'Dismissible Dialog';

  @override
  Duration get transitionDuration => const Duration(milliseconds: 300);

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return Center(
      // Provide DefaultTextStyle to ensure that the dialog's text style
      // matches the rest of the text in the app.
      child: DefaultTextStyle(
        style: Theme.of(context).textTheme.bodyMedium!,
        // UnconstrainedBox is used to make the dialog size itself
        // to fit to the size of the content.
        child: FractionallySizedBox(
            heightFactor: 2 / 3,
            child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: DetailPage(args: detailArgs))),
      ),
    );
  }
}

// class _CustomPopupMenu<T> extends StatelessWidget {
//   const _PopupMenu({
//     super.key,
//     required this.route,
//     required this.semanticLabel,
//     this.constraints,
//     required this.clipBehavior,
//   });

//   final _PopupMenuRoute<T> route;
//   final String? semanticLabel;
//   final BoxConstraints? constraints;
//   final Clip clipBehavior;

//   @override
//   Widget build(BuildContext context) {
//     final double unit = 1.0 / (route.items.length + 1.5); // 1.0 for the width and 0.5 for the last item's fade.
//     final List<Widget> children = <Widget>[];
//     final ThemeData theme = Theme.of(context);
//     final PopupMenuThemeData popupMenuTheme = PopupMenuTheme.of(context);
//     final PopupMenuThemeData defaults = theme.useMaterial3 ? _PopupMenuDefaultsM3(context) : _PopupMenuDefaultsM2(context);

//     for (int i = 0; i < route.items.length; i += 1) {
//       final double start = (i + 1) * unit;
//       final double end = clampDouble(start + 1.5 * unit, 0.0, 1.0);
//       final CurvedAnimation opacity = CurvedAnimation(
//         parent: route.animation!,
//         curve: Interval(start, end),
//       );
//       Widget item = route.items[i];
//       if (route.initialValue != null && route.items[i].represents(route.initialValue)) {
//         item = Container(
//           color: Theme.of(context).highlightColor,
//           child: item,
//         );
//       }
//       children.add(
//         _MenuItem(
//           onLayout: (Size size) {
//             route.itemSizes[i] = size;
//           },
//           child: FadeTransition(
//             opacity: opacity,
//             child: item,
//           ),
//         ),
//       );
//     }

//     final CurveTween opacity = CurveTween(curve: const Interval(0.0, 1.0 / 3.0));
//     final CurveTween width = CurveTween(curve: Interval(0.0, unit));
//     final CurveTween height = CurveTween(curve: Interval(0.0, unit * route.items.length));

//     final Widget child = ConstrainedBox(
//       constraints: constraints ?? const BoxConstraints(
//         minWidth: _kMenuMinWidth,
//         maxWidth: _kMenuMaxWidth,
//       ),
//       child: IntrinsicWidth(
//         stepWidth: _kMenuWidthStep,
//         child: Semantics(
//           scopesRoute: true,
//           namesRoute: true,
//           explicitChildNodes: true,
//           label: semanticLabel,
//           child: SingleChildScrollView(
//             padding: const EdgeInsets.symmetric(
//               vertical: _kMenuVerticalPadding,
//             ),
//             child: ListBody(children: children),
//           ),
//         ),
//       ),
//     );

//     return AnimatedBuilder(
//       animation: route.animation!,
//       builder: (BuildContext context, Widget? child) {
//         return FadeTransition(
//           opacity: opacity.animate(route.animation!),
//           child: Material(
//             shape: route.shape ?? popupMenuTheme.shape ?? defaults.shape,
//             color: route.color ?? popupMenuTheme.color ?? defaults.color,
//             clipBehavior: clipBehavior,
//             type: MaterialType.card,
//             elevation: route.elevation ?? popupMenuTheme.elevation ?? defaults.elevation!,
//             shadowColor: route.shadowColor ?? popupMenuTheme.shadowColor ?? defaults.shadowColor,
//             surfaceTintColor: route.surfaceTintColor ?? popupMenuTheme.surfaceTintColor ?? defaults.surfaceTintColor,
//             child: Align(
//               alignment: AlignmentDirectional.topEnd,
//               widthFactor: width.evaluate(route.animation!),
//               heightFactor: height.evaluate(route.animation!),
//               child: child,
//             ),
//           ),
//         );
//       },
//       child: child,
//     );
//   }
// }
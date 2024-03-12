import 'package:phone_cleaner/src/commons/commons.dart';
import 'package:flutter/material.dart';

import '../models/quick_clean_category.dart';

extension QuickCleanCategoryExtension on QuickCleanCategoryType {
  Widget toIcon() {
    switch (this) {
      case QuickCleanCategoryType.hiddenCache:
        return CleanerIcons.hiddenCache.toWidget();
      case QuickCleanCategoryType.visibleCache:
        return CleanerIcons.visibleCache.toWidget();
      case QuickCleanCategoryType.browserData:
        return CleanerIcons.browserData.toWidget();
      case QuickCleanCategoryType.thumbnails:
        return CleanerIcons.thumbnail.toWidget();
      case QuickCleanCategoryType.emptyFolders:
        return CleanerIcons.emptyFolder.toWidget();
      case QuickCleanCategoryType.appData:
        return CleanerIcons.appData.toWidget();
      case QuickCleanCategoryType.downloads:
        return CleanerIcons.download.toWidget();
      case QuickCleanCategoryType.largeOldFiles:
        return CleanerIcons.largeOldFile.toWidget();
      case QuickCleanCategoryType.apkFiles:
        return CleanerIcons.apkFile.toWidget();
    }
  }

  String toName(BuildContext context) {
    switch (this) {
      case QuickCleanCategoryType.hiddenCache:
        return "Hidden caches";
      case QuickCleanCategoryType.visibleCache:
        return "Visible caches";
      case QuickCleanCategoryType.browserData:
        return "Browser data";
      case QuickCleanCategoryType.thumbnails:
        return "Thumbnails";
      case QuickCleanCategoryType.emptyFolders:
        return "Empty folders";
      case QuickCleanCategoryType.appData:
        return "App data";
      case QuickCleanCategoryType.downloads:
        return "Downloads";
      case QuickCleanCategoryType.largeOldFiles:
        return "Large old files";
      case QuickCleanCategoryType.apkFiles:
        return "Installed apk";
    }
  }
}

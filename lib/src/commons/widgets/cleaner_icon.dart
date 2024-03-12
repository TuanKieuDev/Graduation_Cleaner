import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';

enum CleanerIcons {
  aboutApp,
  appGrow,
  apps,
  back,
  battery,
  boost,
  batteryBoost,
  cleaner,
  cloudService,
  cloudService2,
  cloud1,
  cloud2,
  cloud3,
  done,
  feedback,
  information,
  language,
  media,
  menu,
  notification,
  privacy,
  quickClean,
  remove,
  setting,
  tip,
  topic,
  upgrade,
  rocket,
  rocketGas,
  file,
  visibleCache,
  hiddenCache,
  browserData,
  apkFile,
  appData,
  download,
  thunder,
  forwardArrow,
  btnBoost,
  emptyFile,
  emptyFolder,
  rocketStraight,
  thumbnail,
  robot,
  fileImage,
  otherFile,
  fileSound,
  messageLabel1,
  messageLabel2,
  messageLabel3,
  folder,
  largeOldFile,
  sort,
  navIgnore,
  navStop,
  navClean,
  navUninstall,
  navShare,
  navOptimize,
  navBackup,
  data,
  totalTime,
  lastOpened,
  filter,
  grid,
  list,
  expand,
  optionBackup,
  optionDelete,
  optionKeep,
  lock,
  questionMark,
  fileVideo;

  toWidget({
    double? size,
    Color? color,
    BlendMode blendMode = BlendMode.srcIn,
    AlignmentGeometry alignment = Alignment.center,
    BoxFit fit = BoxFit.contain,
  }) =>
      CleanerIcon(
        icon: this,
        size: size,
        blendMode: blendMode,
        alignment: alignment,
        fit: fit,
      );
}

class CleanerIcon extends StatelessWidget {
  const CleanerIcon({
    super.key,
    required this.icon,
    this.size,
    this.color,
    this.blendMode = BlendMode.srcIn,
    this.alignment = Alignment.center,
    this.fit = BoxFit.contain,
  });

  final CleanerIcons icon;
  final double? size;
  final Color? color;
  final BlendMode blendMode;
  final AlignmentGeometry alignment;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    String iconPath = 'assets/icons/';
    switch (icon) {
      case CleanerIcons.aboutApp:
        iconPath += 'about_app.svg';
        break;
      case CleanerIcons.apps:
        iconPath += 'ic_apps.svg';
        break;
      case CleanerIcons.appGrow:
        iconPath += 'app_grow.svg';
        break;
      case CleanerIcons.battery:
        iconPath += 'battery.svg';
        break;
      case CleanerIcons.batteryBoost:
        iconPath += 'battery_boost.svg';
        break;
      case CleanerIcons.back:
        iconPath += 'back_btn.svg';
        break;
      case CleanerIcons.boost:
        iconPath += 'boost.svg';
        break;
      case CleanerIcons.cleaner:
        iconPath += 'cleaner.svg';
        break;
      case CleanerIcons.cloudService:
        iconPath += 'cloud_service.svg';
        break;
      case CleanerIcons.cloudService2:
        iconPath += 'cloud_service2.svg';
        break;
      case CleanerIcons.cloud1:
        iconPath += 'cloud1.svg';
        break;
      case CleanerIcons.cloud2:
        iconPath += 'cloud2.svg';
        break;
      case CleanerIcons.cloud3:
        iconPath += 'cloud3.svg';
        break;
      case CleanerIcons.done:
        iconPath += 'done.svg';
        break;
      case CleanerIcons.feedback:
        iconPath += 'feedback.svg';
        break;
      case CleanerIcons.information:
        iconPath += 'information.svg';
        break;
      case CleanerIcons.language:
        iconPath += 'language.svg';
        break;
      case CleanerIcons.media:
        iconPath += 'ic_media.svg';
        break;
      case CleanerIcons.menu:
        iconPath += 'menu.svg';
        break;
      case CleanerIcons.notification:
        iconPath += 'notification.svg';
        break;
      case CleanerIcons.privacy:
        iconPath += 'privacy.svg';
        break;
      case CleanerIcons.quickClean:
        iconPath += 'quick_clean.svg';
        break;
      case CleanerIcons.setting:
        iconPath += 'setting.svg';
        break;
      case CleanerIcons.tip:
        iconPath += 'ic_tips.svg';
        break;
      case CleanerIcons.topic:
        iconPath += 'topic.svg';
        break;
      case CleanerIcons.upgrade:
        iconPath += 'upgrade.svg';
        break;
      case CleanerIcons.remove:
        iconPath += 'remove.svg';
        break;
      case CleanerIcons.rocket:
        iconPath += 'rocket.svg';
        break;
      case CleanerIcons.rocketGas:
        iconPath += 'rocket_gas.svg';
        break;
      case CleanerIcons.rocketStraight:
        iconPath += 'rocket_straight.svg';
        break;
      case CleanerIcons.robot:
        iconPath += 'robot.svg';
        break;
      case CleanerIcons.file:
        iconPath += 'file.svg';
        break;
      case CleanerIcons.visibleCache:
        iconPath += 'visible_cache.svg';
        break;
      case CleanerIcons.hiddenCache:
        iconPath += 'hidden_cache.svg';
        break;
      case CleanerIcons.browserData:
        iconPath += 'browser_data.svg';
        break;
      case CleanerIcons.apkFile:
        iconPath += 'apk_file.svg';
        break;
      case CleanerIcons.appData:
        iconPath += 'app_data.svg';
        break;
      case CleanerIcons.download:
        iconPath += 'download.svg';
        break;
      case CleanerIcons.emptyFile:
        iconPath += 'empty_file.svg';
        break;
      case CleanerIcons.emptyFolder:
        iconPath += 'empty_folder.svg';
        break;
      case CleanerIcons.thumbnail:
        iconPath += 'thumbnail.svg';
        break;
      case CleanerIcons.largeOldFile:
        iconPath += 'large_old_file.svg';
        break;
      case CleanerIcons.thunder:
        iconPath += 'thunder.svg';
        break;
      case CleanerIcons.forwardArrow:
        iconPath += 'forward_arrow.svg';
        break;
      case CleanerIcons.sort:
        iconPath += 'sort.svg';
        break;
      case CleanerIcons.data:
        iconPath += 'data.svg';
        break;
      case CleanerIcons.totalTime:
        iconPath += 'total_time.svg';
        break;
      case CleanerIcons.lastOpened:
        iconPath += 'last_opened.svg';
        break;
      case CleanerIcons.filter:
        iconPath += 'filter.svg';
        break;
      case CleanerIcons.expand:
        iconPath += 'expand.svg';
        break;
      case CleanerIcons.lock:
        iconPath += 'lock.svg';
        break;
      case CleanerIcons.grid:
        iconPath += 'grid_display.svg';
        break;
      case CleanerIcons.list:
        iconPath += 'list_display.svg';
        break;
      case CleanerIcons.questionMark:
        iconPath += 'question_mark.svg';
        break;
      case CleanerIcons.btnBoost:
        iconPath += 'ic_primary_button/boost.svg';
        break;
      case CleanerIcons.fileImage:
        iconPath += 'file/file_image.svg';
        break;
      case CleanerIcons.otherFile:
        iconPath += 'file/other_file.svg';
        break;
      case CleanerIcons.fileSound:
        iconPath += 'file/file_sound.svg';
        break;
      case CleanerIcons.fileVideo:
        iconPath += 'file/video.svg';
        break;
      case CleanerIcons.messageLabel1:
        iconPath += 'file/message_label1.svg';
        break;
      case CleanerIcons.messageLabel2:
        iconPath += 'file/message_label2.svg';
        break;
      case CleanerIcons.messageLabel3:
        iconPath += 'file/message_label3.svg';
        break;
      case CleanerIcons.folder:
        iconPath += 'file/folder.svg';
        break;
      case CleanerIcons.optionBackup:
        iconPath += 'file/option_backup.svg';
        break;
      case CleanerIcons.optionDelete:
        iconPath += 'file/option_delete.svg';
        break;
      case CleanerIcons.optionKeep:
        iconPath += 'file/option_keep.svg';
        break;
      case CleanerIcons.navIgnore:
        iconPath += 'ic_nav_bar/eye.svg';
        break;
      case CleanerIcons.navClean:
        iconPath += 'ic_nav_bar/clean.svg';
        break;
      case CleanerIcons.navStop:
        iconPath += 'ic_nav_bar/snow.svg';
        break;
      case CleanerIcons.navUninstall:
        iconPath += 'ic_nav_bar/recycle.svg';
        break;
      case CleanerIcons.navShare:
        iconPath += 'ic_nav_bar/share.svg';
        break;
      case CleanerIcons.navOptimize:
        iconPath += 'ic_nav_bar/optimize.svg';
        break;
      case CleanerIcons.navBackup:
        iconPath += 'ic_nav_bar/back_up.svg';
        break;
      default:
        throw UnimplementedError(
            '$icon has not been implemented or does not exist!');
    }

    return SvgPicture.asset(
      iconPath,
      height: size,
      width: size,
      color: color,
      colorBlendMode: blendMode,
      alignment: alignment,
      fit: fit,
    );
  }
}

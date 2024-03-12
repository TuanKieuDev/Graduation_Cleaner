import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationChannel {
  static const junkCleaningChannel = AndroidNotificationChannel(
    'junk_cleaning_channel',
    'Junk Cleaning',
    description: 'Lows storage and unnecessary junk data alerts',
    groupId: 'scheduled_notification_app',
  );

  static const applicationsChannel = AndroidNotificationChannel(
    'applications_channel',
    'Applications',
    description: 'Determining usage levels and increasing size of applications',
    groupId: 'scheduled_notification_app',
  );

  static const photosChannel = AndroidNotificationChannel(
    'photos_channel',
    'Photos',
    description: 'Identifying photo related cleaning opportunities',
    groupId: 'scheduled_notification_app',
  );

  static const otherFilesChannel = AndroidNotificationChannel(
    'other_files_channel',
    'Other Files',
    description: 'Clean and boost tips delivered by thorough device',
    groupId: 'scheduled_notification_app',
  );

  static const commonChannel = AndroidNotificationChannel(
    'common_channel',
    'Common',
    description: 'Everything else',
    groupId: 'other_notification_app',
  );

  static const backgroundOperationsChannel = AndroidNotificationChannel(
    'background_operations_channel',
    'Background Operations',
    description: 'Scanning, photo uploading, etc,.',
    groupId: 'other_notification_app',
  );
}

import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'database_helper.dart';

class BackupService {
  static final BackupService instance = BackupService._init();
  BackupService._init();

  /// Exports local SQLite database into a formatted JSON backup file
  /// and opens the system share dialog (WhatsApp, Telegram, Drive, etc.)
  Future<String?> exportBackup() async {
    try {
      final data = await DatabaseHelper.instance.getAllDataForBackup();
      final jsonString = const JsonEncoder.withIndent('  ').convert(data);

      final tempDir = await getTemporaryDirectory();
      final dateStr = DateTime.now().toIso8601String().replaceAll(':', '-').split('.').first;
      final filePath = '${tempDir.path}/mizan_backup_$dateStr.json';

      final file = File(filePath);
      await file.writeAsString(jsonString);

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          text: 'نسخة احتياطية لبيانات تطبيق ميزان - $dateStr',
          subject: 'نسخة احتياطية - ميزان',
        ),
      );

      return file.path;
    } catch (e) {
      return null;
    }
  }

  /// Lets user select a JSON backup file and restores the database
  Future<bool> importBackup() async {
    try {
      final files = await FilePicker.pickFiles(
        type: FileType.any,
      );

      if (files.isEmpty) {
        return false;
      }

      final path = files.first.path;
      if (path == null) return false;

      final file = File(path);
      final jsonString = await file.readAsString();
      final Map<String, dynamic> data = json.decode(jsonString);

      if (!data.containsKey('categories') || !data.containsKey('transactions')) {
        throw const FormatException('الملف المحدد ليس ملف نسخة احتياطية صالح لتطبيق ميزان');
      }

      await DatabaseHelper.instance.restoreBackupData(data);
      return true;
    } catch (e) {
      return false;
    }
  }
}

import 'dart:typed_data';
import '../../../../shared/models/export_format_enum.dart';
import '../../../../shared/models/save_result.dart';
import '../../../models/database/account.dart';
import '../../../models/database/transaction.dart';

abstract class IExportService {
  Future<Uint8List> exportAllData({required ExportFormat format});

  Future<Uint8List> exportAnalyticsData({
    required List<Transaction> transactions,
    required List<Account> accounts,
    required String period,
    required String baseCurrency,
    required ExportFormat format,
  });

  Future<SaveResult> saveExportedData({
    required Uint8List bytes,
    required String fileNameWithoutExt,
    required ExportFormat format,
  });

  Future<void> shareExportedData({
    required Uint8List bytes,
    required String fileNameWithoutExt,
    required ExportFormat format,
  });
}

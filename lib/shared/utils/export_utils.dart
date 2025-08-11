import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/contracts/services/export/i_export_service.dart';
import '../../core/logging/log.dart';
import '../../core/models/database/account.dart';
import '../../core/models/database/transaction.dart';
import '../../core/providers/export/export_service_provider.dart';
import '../../features/analytics/models/analytics_data.dart';
import 'ui_utils.dart';

class ExportUtils {
  ExportUtils._();

  static Future<void> exportAllData(BuildContext context, WidgetRef ref) async {
    if (!context.mounted) {
      return;
    }
    UiUtils.showLoadingDialog(context, message: 'Preparing export...');
    try {
      final ExportFormat? format = await _pickFormat(context);
      if (format == null) {
        if(context.mounted) {
          UiUtils.hideDialog(context);
        }
        return;
      }
      final IExportService svc = ref.read(exportServiceProvider);
      final Uint8List bytes = await svc.exportAllData(format: format);
      if (!context.mounted) {
        return;
      }
      UiUtils.hideDialog(context);
      await _showExportOptions(context, ref, bytes, 'TrackFi_Complete_Export', format);
    } catch (e) {
      if (context.mounted) {
        UiUtils.hideDialog(context);
        UiUtils.showError(context, 'Failed to export data: $e');
      }
    }
  }

  static Future<void> exportAnalyticsData(
    BuildContext context,
    WidgetRef ref, {
    required List<Transaction> transactions,
    required List<Account> accounts,
    required AnalyticsPeriod period,
    required String baseCurrency,
  }) async {
    if (!context.mounted) {
      return;
    }
    UiUtils.showLoadingDialog(context, message: 'Preparing analytics export...');
    try {
      final ExportFormat? format = await _pickFormat(context, title: 'Export Analytics');
      if (format == null) {
        if(context.mounted) {
          UiUtils.hideDialog(context);
        }
        return;
      }
      final IExportService svc = ref.read(exportServiceProvider);
      final Uint8List bytes = await svc.exportAnalyticsData(
        transactions: transactions,
        accounts: accounts,
        period: period.label,
        baseCurrency: baseCurrency,
        format: format,
      );
      if (!context.mounted) {
        return;
      }
      UiUtils.hideDialog(context);
      final String base = 'TrackFi_Analytics_${period.name}_${DateTime.now().millisecondsSinceEpoch ~/ 1000}';
      await _showExportOptions(context, ref, bytes, base, format);
    } catch (e) {
      if (context.mounted) {
        UiUtils.hideDialog(context);
        UiUtils.showError(context, 'Failed to export analytics: $e');
      }
    }
  }

  static Future<void> _showExportOptions(
    BuildContext context,
    WidgetRef ref,
    Uint8List bytes,
    String baseFileName,
    ExportFormat format,
  ) async {
    final String ext = _extension(format);
    final String _ = _mimeString(format);
    final String fileName = '${baseFileName}_${_stamp()}.$ext';

    await showDialog<void>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        title: const Row(children: <Widget>[Icon(Icons.download_rounded), SizedBox(width: 8), Text('Export Data')]),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text("Your data is ready. Choose how you'd like to save it:", style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: <Widget>[
                  Icon(Icons.insert_drive_file_outlined, color: Theme.of(context).colorScheme.primary, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(fileName, style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600)),
                        Text('${ext.toUpperCase()} • ${(bytes.lengthInBytes / 1024).toStringAsFixed(1)} KB',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          TextButton.icon(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await _saveToDevice(context, ref, bytes, fileName, format);
            },
            icon: const Icon(Icons.save_alt, size: 18),
            label: const Text('Save to Device'),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await _shareData(context, ref, bytes, fileName, format);
            },
            icon: const Icon(Icons.share, size: 18),
            label: const Text('Share'),
          ),
        ],
      ),
    );
  }

  static Future<void> _saveToDevice(
    BuildContext context,
    WidgetRef ref,
    Uint8List bytes,
    String fileNameWithExt,
    ExportFormat format,
  ) async {
    try {
      final IExportService svc = ref.read(exportServiceProvider);
      final bool ok = await svc.saveExportedData(
        bytes: bytes,
        fileNameWithoutExt: fileNameWithExt.replaceAll(RegExp(r'\.(csv|pdf)$'), ''),
        format: format,
      );
      if (!context.mounted) {
        return;
      }
      if (ok) {
        UiUtils.showSuccess(context, 'Saved to Downloads');
      } else {
        UiUtils.showError(context, 'Failed to save file');
      }
    } catch (e, st) {
      await log(message: 'Failed to save exported data to device', error: e, stackTrace: st);
      if (!context.mounted) {
        return;
      }
      UiUtils.showError(context, 'Failed to save file: $e');
    }
  }


  static Future<void> _shareData(
    BuildContext context,
    WidgetRef ref,
    Uint8List bytes,
    String fileNameWithExt,
    ExportFormat format,
  ) async {
    try {
      final IExportService svc = ref.read(exportServiceProvider);
      await svc.shareExportedData(
        bytes: bytes,
        fileNameWithoutExt: fileNameWithExt.replaceAll(RegExp(r'\.(csv|pdf)$'), ''),
        format: format,
      );
      if (context.mounted) {
        UiUtils.showSuccess(context, 'Sharing…');
      }
    } catch (e, st) {
      await log(message: 'Failed to share exported data', error: e, stackTrace: st);
      if (context.mounted) {
        UiUtils.showError(context, 'Failed to share data: $e');
      }
    }
  }

  static Future<ExportFormat?> _pickFormat(BuildContext context, {String title = 'Export Data'}) async {
    ExportFormat? selected = ExportFormat.csv;
    return showDialog<ExportFormat>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        title: Text(title),
        content: StatefulBuilder(
          builder: (BuildContext ctx2, StateSetter setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              RadioListTile<ExportFormat>(
          value: ExportFormat.csv,
          groupValue: selected,
          title: const Text('CSV'),
          onChanged: (ExportFormat? v) => setState(() => selected = v),
              ),
              RadioListTile<ExportFormat>(
          value: ExportFormat.pdf,
          groupValue: selected,
          title: const Text('PDF'),
          onChanged: (ExportFormat? v) => setState(() => selected = v),
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.of(ctx).pop(selected), child: const Text('Continue')),
        ],
      ),
    );
  }

  static String _stamp() {
    final DateTime now = DateTime.now();
    return '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}';
  }

  static String _extension(ExportFormat f) {
    switch (f) {
      case ExportFormat.csv: return 'csv';
      case ExportFormat.pdf: return 'pdf';
    }
  }

  static String _mimeString(ExportFormat f) {
    switch (f) {
      case ExportFormat.csv: return 'text/csv';
      case ExportFormat.pdf: return 'application/pdf';
    }
  }
}

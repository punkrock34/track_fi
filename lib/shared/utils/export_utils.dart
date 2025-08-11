import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_filex/open_filex.dart';
import '../../core/contracts/services/export/i_export_service.dart';
import '../../core/logging/log.dart';
import '../../core/models/database/account.dart';
import '../../core/models/database/transaction.dart';
import '../../core/providers/export/export_service_provider.dart';
import '../../features/analytics/models/analytics_data.dart';
import '../models/export_format_enum.dart';
import '../models/save_result.dart';
import 'ui_utils.dart';

class ExportUtils {
  ExportUtils._();

  static Future<void> exportAllData(BuildContext context, WidgetRef ref) async {
    if (!context.mounted) {
      return;
    }

    try {
      final ExportFormat? format = await _pickFormat(context);

      if (format == null) {
        return;
      }
      
      if (context.mounted) {
        UiUtils.showLoadingDialog(context, message: 'Preparing export...');
      }

      final IExportService svc = ref.read(exportServiceProvider);

      final Uint8List bytes = await svc.exportAllData(format: format);

      if (!context.mounted) {
        return;
      }

      UiUtils.hideDialog(context);

      await _showExportOptions(
        context,
        ref,
        bytes,
        'TrackFi_Export_${_friendlyStamp()}',
        format,
      );
    } catch (e, st) {
      await log(message: 'Export failed', error: e, stackTrace: st);

      if (context.mounted) {
        UiUtils.hideDialog(context);
        UiUtils.showError(context, 'Failed to export data. Please try again.');
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

    try {
      final ExportFormat? format = await _pickFormat(
        context,
        title: 'Export Analytics',
      );

      if (format == null) {
        return;
      }

      if (context.mounted) {
        UiUtils.showLoadingDialog(context, message: 'Preparing analytics export...');
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

      final String base = 'TrackFi_Analytics_${period.name}_${_friendlyStamp()}';

      await _showExportOptions(
        context,
        ref,
        bytes,
        base,
        format,
      );
    } catch (e, st) {
      await log(message: 'Analytics export failed', error: e, stackTrace: st);

      if (context.mounted) {
        UiUtils.hideDialog(context);
        UiUtils.showError(context, 'Failed to export analytics. Please try again.');
      }
    }
  }

  static Future<void> _showExportOptions(
    BuildContext context,
    WidgetRef ref,
    Uint8List bytes,
    String baseFileName,
    ExportFormat format,
  ) {
    final String ext = _extension(format);
    final String fileName = '$baseFileName.$ext';
    final double kb = bytes.lengthInBytes / 1024;
    final String sizeLabel = kb >= 1024 ? '${(kb / 1024).toStringAsFixed(2)} MB' : '${kb.toStringAsFixed(1)} KB';

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Row(
          children: <Widget>[
            Icon(Icons.download_rounded, size: 20),
            SizedBox(width: 8),
            Text('Export Ready'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Your data export is ready. Choose how to save it:',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.insert_drive_file_outlined,
                    color: Theme.of(context).colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          fileName,
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          '${ext.toUpperCase()} • $sizeLabel',
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
          TextButton(
            onPressed: () => Navigator.of(dialogContext, rootNavigator: true).pop(),
            child: const Text('Cancel'),
          ),
          TextButton.icon(
            onPressed: () async {
              Navigator.of(dialogContext, rootNavigator: true).pop();
              await _saveToDevice(context, ref, bytes, baseFileName, format);
            },
            icon: const Icon(Icons.save_alt, size: 18),
            label: const Text('Save to Device'),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              Navigator.of(dialogContext, rootNavigator: true).pop();
              await _shareData(context, ref, bytes, baseFileName, format);
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
    String baseFileName,
    ExportFormat format,
  ) async {
    if (context.mounted) {
      UiUtils.showLoadingDialog(context, message: 'Saving to device...');
    }

    try {
      final IExportService svc = ref.read(exportServiceProvider);

      final SaveResult result = await svc.saveExportedData(
        bytes: bytes,
        fileNameWithoutExt: baseFileName,
        format: format,
      );

      if (!context.mounted) {
        return;
      }

      UiUtils.hideDialog(context);

      if (result.success) {
        if (result.path != null && result.path!.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Saved: ${result.displayName ?? 'file'}'),
              action: SnackBarAction(
                label: 'Open file',
                onPressed: () {
                  OpenFilex.open(result.path!);
                },
              ),
              duration: const Duration(seconds: 6),
            ),
          );
        } else {
          UiUtils.showSuccess(context, 'File saved');
        }
      } else {
        UiUtils.showError(context, 'Failed to save file. Please try sharing instead.');
      }
    } catch (e, st) {
      await log(message: 'Failed to save file', error: e, stackTrace: st);

      if (context.mounted) {
        UiUtils.hideDialog(context);
        UiUtils.showError(context, 'Failed to save file. Please try sharing instead.');
      }
    }
  }

  static Future<void> _shareData(
    BuildContext context,
    WidgetRef ref,
    Uint8List bytes,
    String baseFileName,
    ExportFormat format,
  ) async {
    if (context.mounted) {
      UiUtils.showLoadingDialog(context, message: 'Preparing to share...');
    }

    try {
      final IExportService svc = ref.read(exportServiceProvider);

      await svc.shareExportedData(
        bytes: bytes,
        fileNameWithoutExt: baseFileName,
        format: format,
      );

      if (context.mounted) {
        UiUtils.hideDialog(context);
        UiUtils.showSuccess(context, 'Ready to share');
      }
    } catch (e, st) {
      await log(message: 'Failed to share file', error: e, stackTrace: st);

      if (context.mounted) {
        UiUtils.hideDialog(context);
        UiUtils.showError(context, 'Failed to share file. Please try again.');
      }
    }
  }

  static Future<ExportFormat?> _pickFormat(
    BuildContext context, {
    String title = 'Export Data',
  }) {
    return showDialog<ExportFormat>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        ExportFormat? selected = ExportFormat.csv;

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) => AlertDialog(
            title: Text(title),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                RadioListTile<ExportFormat>(
                  value: ExportFormat.csv,
                  groupValue: selected,
                  title: const Text('CSV Spreadsheet'),
                  subtitle: const Text('Comma-separated values, easy to analyze'),
                  onChanged: (ExportFormat? value) {
                    setState(() => selected = value);
                  },
                ),
                RadioListTile<ExportFormat>(
                  value: ExportFormat.pdf,
                  groupValue: selected,
                  title: const Text('PDF Document'),
                  subtitle: const Text('Formatted document for viewing'),
                  onChanged: (ExportFormat? value) {
                    setState(() => selected = value);
                  },
                ),
              ],
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context, rootNavigator: true).pop(selected),
                child: const Text('Continue'),
              ),
            ],
          ),
        );
      },
    );
  }

  static String _friendlyStamp() {
    final DateTime now = DateTime.now();

    final String year = now.year.toString().padLeft(4, '0');
    final String month = now.month.toString().padLeft(2, '0');
    final String day = now.day.toString().padLeft(2, '0');
    final String hour = now.hour.toString().padLeft(2, '0');
    final String minute = now.minute.toString().padLeft(2, '0');

    return '$year-$month-${day}_$hour-$minute';
  }

  static String _extension(ExportFormat format) {
    switch (format) {
      case ExportFormat.csv:
        return 'csv';
      case ExportFormat.pdf:
        return 'pdf';
    }
  }
}

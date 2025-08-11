import 'dart:convert';
import 'dart:typed_data';

import 'package:file_saver/file_saver.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

import '../../../shared/utils/category_utils.dart';
import '../../../shared/utils/currency_utils.dart';
import '../../../shared/utils/date_utils.dart' as date_utils;
import '../../contracts/services/database/storage/i_account_storage_service.dart';
import '../../contracts/services/database/storage/i_category_storage_service.dart';
import '../../contracts/services/database/storage/i_transaction_storage_service.dart';
import '../../contracts/services/export/i_export_service.dart';
import '../../logging/log.dart';
import '../../models/database/account.dart';
import '../../models/database/transaction.dart';

class ExportService implements IExportService {
  ExportService({
    required this.accountStorage,
    required this.transactionStorage,
    required this.categoryStorage,
  });

  final IAccountStorageService accountStorage;
  final ITransactionStorageService transactionStorage;
  final ICategoryStorageService categoryStorage;

  @override
  Future<Uint8List> exportAllData({required ExportFormat format}) async {
    final List<Account> accounts = await accountStorage.getAll();
    final List<Transaction> allTransactions = <Transaction>[];
    for (final Account account in accounts) {
      final List<Transaction> ts = await transactionStorage.getAllByAccount(account.id);
      allTransactions.addAll(ts);
    }
    allTransactions.sort((Transaction a, Transaction b) => b.transactionDate.compareTo(a.transactionDate));
    switch (format) {
      case ExportFormat.csv:
        final String csv = _buildAllDataCsv(accounts, allTransactions);
        return _encodeCsv(csv);
      case ExportFormat.pdf:
        return _buildAllDataPdf(accounts, allTransactions);
    }
  }

  @override
  Future<Uint8List> exportAnalyticsData({
    required List<Transaction> transactions,
    required List<Account> accounts,
    required String period,
    required String baseCurrency,
    required ExportFormat format,
  }) async {
    switch (format) {
      case ExportFormat.csv:
        final String csv = _buildAnalyticsCsv(transactions, accounts, period, baseCurrency);
        return _encodeCsv(csv);
      case ExportFormat.pdf:
        return _buildAnalyticsPdf(transactions, accounts, period, baseCurrency);
    }
  }

  @override
  Future<bool> saveExportedData({
    required Uint8List bytes,
    required String fileNameWithoutExt,
    required ExportFormat format,
  }) async {
    try {
      final String ext = _ext(format);      // 'csv' or 'pdf'
      final MimeType mt = _mime(format);    // MimeType.text or MimeType.pdf
      await FileSaver.instance.saveFile(
        name: fileNameWithoutExt,
        bytes: bytes,
        fileExtension: ext,
        mimeType: mt,
      );
      return true;
    } catch (e, st) {
      await log(message: 'Failed to save exported data', error: e, stackTrace: st);
      return false;
    }
  }

  @override
  Future<void> shareExportedData({
    required Uint8List bytes,
    required String fileNameWithoutExt,
    required ExportFormat format,
  }) async {
    final String name = '$fileNameWithoutExt.${_ext(format)}';
    final String mime = _mimeString(format); // 'text/csv' or 'application/pdf'
    final XFile xf = XFile.fromData(bytes, name: name, mimeType: mime);
    await Share.shareXFiles(<XFile>[xf], subject: name, text: 'TrackFi Data Export');
  }

  MimeType _mime(ExportFormat f) {
    switch (f) {
      case ExportFormat.csv: return MimeType.text;
      case ExportFormat.pdf: return MimeType.pdf;
    }
  }

  Uint8List _encodeCsv(String csv) {
    const List<int> bom = <int>[0xEF, 0xBB, 0xBF];
    final Uint8List content = utf8.encode(csv);
    return Uint8List.fromList(List<int>.from(bom)..addAll(content));
  }

  String _buildAllDataCsv(List<Account> accounts, List<Transaction> transactions) {
    final StringBuffer b = StringBuffer();
    b.writeln('${_q('Export Date')},${_q(DateTime.now().toIso8601String())}');
    b.writeln('${_q('Total Accounts')},${_q('${accounts.length}')}');
    b.writeln('${_q('Total Transactions')},${_q('${transactions.length}')}');
    b.writeln();
    b.writeln(_q('=== ACCOUNTS ==='));
    b.writeln(<String>[
      'Account ID','Name','Type','Balance','Currency','Bank Name','Account Number','Sort Code','Source','Status','Created At','Updated At'
    ].map(_q).join(','));
    for (final Account a in accounts) {
      b.writeln(_row(<String>[
        a.id, a.name, a.type, a.balance.toString(), a.currency,
        a.bankName ?? '', a.accountNumber ?? '', a.sortCode ?? '',
        a.source, if (a.isActive) 'Active' else 'Inactive',
        a.createdAt.toIso8601String(), a.updatedAt.toIso8601String()
      ]));
    }
    b.writeln();
    b.writeln(_q('=== TRANSACTIONS ==='));
    b.writeln(<String>[
      'Transaction ID','Account Name','Account ID','Amount','Currency','Description','Category','Type','Transaction Date','Reference','Balance After','Status','Created At'
    ].map(_q).join(','));
    for (final Transaction t in transactions) {
      final Account? acc = accounts.cast<Account?>().firstWhere((Account? a) => a?.id == t.accountId, orElse: () => null);
      final String categoryName = t.categoryId != null ? CategoryUtils.getCategoryName(t.categoryId!) : '';
      b.writeln(_row(<String>[
        t.id,
        acc?.name ?? 'Unknown Account',
        t.accountId,
        t.amount.toString(),
        acc?.currency ?? 'RON',
        t.description,
        categoryName,
        t.type.name.toUpperCase(),
        t.transactionDate.toIso8601String(),
        t.reference ?? '',
        t.balanceAfter?.toString() ?? '',
        t.status,
        t.createdAt.toIso8601String(),
      ]));
    }
    return b.toString();
  }

  Future<Uint8List> _buildAllDataPdf(List<Account> accounts, List<Transaction> transactions) async {
    final pw.Document pdf = pw.Document();
    pdf.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context c) => <pw.Widget>[
        pw.Text('TrackFi Export', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 6),
        pw.Text('Export Date: ${DateTime.now().toIso8601String()}'),
        pw.SizedBox(height: 12),
        pw.Text('Accounts', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
        pw.Table.fromTextArray(
          headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          headers: <String>['Name','Type','Balance','Currency','Status'],
          data: accounts.map((Account a) => <String>[
            a.name, a.type, a.balance.toStringAsFixed(2), a.currency, if (a.isActive) 'Active' else 'Inactive'
          ]).toList(),
        ),
        pw.SizedBox(height: 12),
        pw.Text('Transactions (latest first)', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
        pw.Table.fromTextArray(
          headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          headers: <String>['Date','Account','Desc','Type','Amount'],
          data: transactions.take(500).map((Transaction t) {
            final String date = date_utils.DateUtils.formatDate(t.transactionDate);
            final String type = t.type.name.toUpperCase();
            final String amount = t.amount.toStringAsFixed(2);
            return <String>[date, t.accountId, t.description, type, amount];
          }).toList(),
        ),
      ],
    ));
    return pdf.save();
  }

  String _buildAnalyticsCsv(List<Transaction> transactions, List<Account> accounts, String period, String baseCurrency) {
    final StringBuffer b = StringBuffer();
    b.writeln(_q('TrackFi Analytics Export'));
    b.writeln('${_q('Export Date')},${_q(DateTime.now().toIso8601String())}');
    b.writeln('${_q('Period')},${_q(period)}');
    b.writeln('${_q('Base Currency')},${_q(baseCurrency)}');
    b.writeln('${_q('Total Transactions')},${_q('${transactions.length}')}');
    b.writeln();
    final double totalIncome = transactions.where((Transaction t) => t.type == TransactionType.credit).fold(0.0, (double s, Transaction t) => s + t.amount);
    final double totalExpenses = transactions.where((Transaction t) => t.type == TransactionType.debit).fold(0.0, (double s, Transaction t) => s + t.amount.abs());
    final double netIncome = totalIncome - totalExpenses;
    b.writeln(_q('=== SUMMARY ==='));
    b.writeln('${_q('Total Income')},${_q('${CurrencyUtils.getCurrencySymbol(baseCurrency)}${totalIncome.toStringAsFixed(2)}')}');
    b.writeln('${_q('Total Expenses')},${_q('${CurrencyUtils.getCurrencySymbol(baseCurrency)}${totalExpenses.toStringAsFixed(2)}')}');
    b.writeln('${_q('Net Income')},${_q('${CurrencyUtils.getCurrencySymbol(baseCurrency)}${netIncome.toStringAsFixed(2)}')}');
    b.writeln();
    b.writeln(_q('=== CATEGORY BREAKDOWN ==='));
    b.writeln(<String>['Category','Type','Amount','Transaction Count','Percentage of Total'].map(_q).join(','));
    final Map<String, List<Transaction>> categoryGroups = <String, List<Transaction>>{};
    for (final Transaction t in transactions) {
      final String id = t.categoryId ?? 'uncategorized';
      categoryGroups.putIfAbsent(id, () => <Transaction>[]).add(t);
    }
    final List<MapEntry<String, List<Transaction>>> entries = categoryGroups.entries.toList()
      ..sort((MapEntry<String, List<Transaction>> a, MapEntry<String, List<Transaction>> b) {
        final double aa = a.value.fold(0.0, (double s, Transaction t) => s + t.amount.abs());
        final double bb = b.value.fold(0.0, (double s, Transaction t) => s + t.amount.abs());
        return bb.compareTo(aa);
      });
    for (final MapEntry<String, List<Transaction>> e in entries) {
      final String name = CategoryUtils.getCategoryName(e.key);
      final String type = CategoryUtils.getCategoryType(e.key);
      final double amount = e.value.fold(0.0, (double s, Transaction t) => s + t.amount.abs());
      final double denom = type == 'income' ? totalIncome : totalExpenses;
      final double pct = denom > 0 ? (amount / denom) * 100 : 0;
      b.writeln(_row(<String>[name, type.toUpperCase(), '${CurrencyUtils.getCurrencySymbol(baseCurrency)}${amount.toStringAsFixed(2)}', '${e.value.length}', '${pct.toStringAsFixed(1)}%']));
    }
    b.writeln();
    b.writeln(_q('=== MONTHLY BREAKDOWN ==='));
    b.writeln(<String>['Month','Income','Expenses','Net'].map(_q).join(','));
    final Map<String, List<Transaction>> monthly = <String, List<Transaction>>{};
    for (final Transaction t in transactions) {
      final String key = '${t.transactionDate.year}-${t.transactionDate.month.toString().padLeft(2, '0')}';
      monthly.putIfAbsent(key, () => <Transaction>[]).add(t);
    }
    final List<String> months = monthly.keys.toList()..sort();
    for (final String m in months) {
      final List<Transaction> ts = monthly[m]!;
      final double inc = ts.where((Transaction t) => t.type == TransactionType.credit).fold(0.0, (double s, Transaction t) => s + t.amount);
      final double exp = ts.where((Transaction t) => t.type == TransactionType.debit).fold(0.0, (double s, Transaction t) => s + t.amount.abs());
      final double net = inc - exp;
      final List<String> parts = m.split('-');
      final DateTime date = DateTime(int.parse(parts[0]), int.parse(parts[1]));
      final String label = '${_monthName(date.month)} ${date.year}';
      b.writeln(_row(<String>[
        label,
        '${CurrencyUtils.getCurrencySymbol(baseCurrency)}${inc.toStringAsFixed(2)}',
        '${CurrencyUtils.getCurrencySymbol(baseCurrency)}${exp.toStringAsFixed(2)}',
        '${CurrencyUtils.getCurrencySymbol(baseCurrency)}${net.toStringAsFixed(2)}',
      ]));
    }
    b.writeln();
    b.writeln(_q('=== DETAILED TRANSACTIONS ==='));
    b.writeln(<String>['Date','Description','Category','Account','Amount','Type','Reference'].map(_q).join(','));
    final List<Transaction> sorted = List<Transaction>.from(transactions)..sort((Transaction a, Transaction b) => b.transactionDate.compareTo(a.transactionDate));
    for (final Transaction t in sorted) {
      final Account? acc = accounts.cast<Account?>().firstWhere((Account? a) => a?.id == t.accountId, orElse: () => null);
      final String categoryName = t.categoryId != null ? CategoryUtils.getCategoryName(t.categoryId!) : 'Uncategorized';
      final String amt = t.type == TransactionType.debit
          ? '-${CurrencyUtils.getCurrencySymbol(baseCurrency)}${t.amount.abs().toStringAsFixed(2)}'
          : '+${CurrencyUtils.getCurrencySymbol(baseCurrency)}${t.amount.toStringAsFixed(2)}';
      b.writeln(_row(<String>[
        date_utils.DateUtils.formatDate(t.transactionDate),
        t.description,
        categoryName,
        acc?.name ?? 'Unknown Account',
        amt,
        t.type.name.toUpperCase(),
        t.reference ?? '',
      ]));
    }
    return b.toString();
  }

  Future<Uint8List> _buildAnalyticsPdf(List<Transaction> transactions, List<Account> accounts, String period, String baseCurrency) async {
    final pw.Document pdf = pw.Document();
    final double totalIncome = transactions.where((Transaction t) => t.type == TransactionType.credit).fold(0.0, (double s, Transaction t) => s + t.amount);
    final double totalExpenses = transactions.where((Transaction t) => t.type == TransactionType.debit).fold(0.0, (double s, Transaction t) => s + t.amount.abs());
    final double netIncome = totalIncome - totalExpenses;
    final String sym = CurrencyUtils.getCurrencySymbol(baseCurrency);
    pdf.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context c) => <pw.Widget>[
        pw.Text('TrackFi Analytics ($period)', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 6),
        pw.Text('Export Date: ${DateTime.now().toIso8601String()}'),
        pw.SizedBox(height: 12),
        pw.Text('Summary', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
        pw.Bullet(text: 'Total Income: $sym${totalIncome.toStringAsFixed(2)}'),
        pw.Bullet(text: 'Total Expenses: $sym${totalExpenses.toStringAsFixed(2)}'),
        pw.Bullet(text: 'Net Income: $sym${netIncome.toStringAsFixed(2)}'),
        pw.SizedBox(height: 12),
        pw.Text('Transactions (latest first)', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
        pw.Table.fromTextArray(
          headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          headers: <String>['Date','Desc','Account','Type','Amount'],
          data: transactions.take(500).map((Transaction t) {
            final Account? acc = accounts.cast<Account?>().firstWhere((Account? a) => a?.id == t.accountId, orElse: () => null);
            return <String>[
              date_utils.DateUtils.formatDate(t.transactionDate),
              t.description,
              acc?.name ?? 'Unknown',
              t.type.name.toUpperCase(),
              (t.type == TransactionType.debit ? '-' : '+') + sym + t.amount.abs().toStringAsFixed(2)
            ];
          }).toList(),
        ),
      ],
    ));
    return pdf.save();
  }

  String _q(String s) {
    final String e = s.replaceAll('"', '""');
    return '"$e"';
  }

  String _row(List<String> fields) {
    return fields.map((String f) {
      final String e = f.replaceAll('"', '""');
      if (e.contains(',') || e.contains('"') || e.contains('\n')) {
        return '"$e"';
      }
      return e.isEmpty ? '""' : e;
    }).join(',');
  }

  String _monthName(int m) {
    const List<String> months = <String>['','Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return months[m];
  }

  String _ext(ExportFormat f) {
    switch (f) {
      case ExportFormat.csv: return 'csv';
      case ExportFormat.pdf: return 'pdf';
    }
  }

  String _mimeString(ExportFormat f) {
    switch (f) {
      case ExportFormat.csv: return 'text/csv';
      case ExportFormat.pdf: return 'application/pdf';
    }
  }
}

import 'dart:convert';
import 'dart:typed_data';
import 'package:file_saver/file_saver.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import '../../../shared/models/export_format_enum.dart';
import '../../../shared/models/save_result.dart';
import '../../../shared/utils/category_utils.dart';
import '../../../shared/utils/currency_utils.dart';
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
      final List<Transaction> tx = await transactionStorage.getAllByAccount(account.id);
      allTransactions.addAll(tx);
    }

    allTransactions.sort(
      (Transaction a, Transaction b) => b.transactionDate.compareTo(a.transactionDate),
    );

    switch (format) {
      case ExportFormat.csv:
        return _buildImprovedCsv(accounts, allTransactions);
      case ExportFormat.pdf:
        return _buildImprovedPdf(accounts, allTransactions);
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
        return _buildAnalyticsCsv(transactions, accounts, period, baseCurrency);
      case ExportFormat.pdf:
        return _buildAnalyticsPdf(transactions, accounts, period, baseCurrency);
    }
  }

  @override
  Future<SaveResult> saveExportedData({
    required Uint8List bytes,
    required String fileNameWithoutExt,
    required ExportFormat format,
  }) async {
    try {
      final String ext = _getExtension(format);
      final MimeType mimeType = _getMimeType(format);
      final String cleanBase = _cleanFileName(fileNameWithoutExt);

      final String path = await FileSaver.instance.saveFile(
        name: cleanBase,
        bytes: bytes,
        fileExtension: ext,
        mimeType: mimeType,
      );

      return SaveResult(
        success: path.isNotEmpty,
        path: path.isNotEmpty ? path : null,
        displayName: '$cleanBase.$ext',
      );
    } catch (e, st) {
      await log(message: 'Failed to save exported file', error: e, stackTrace: st);
      return const SaveResult(success: false);
    }
  }

  @override
  Future<void> shareExportedData({
    required Uint8List bytes,
    required String fileNameWithoutExt,
    required ExportFormat format,
  }) async {
    try {
      final String extension = _getExtension(format);
      final String mimeString = _getMimeString(format);
      final String cleanFileName = _cleanFileName(fileNameWithoutExt);
      final String fullFileName = '$cleanFileName.$extension';

      final XFile xFile = XFile.fromData(
        bytes,
        name: fullFileName,
        mimeType: mimeString,
      );

      await Share.shareXFiles(
        <XFile>[xFile],
        subject: 'TrackFi Data Export',
        text: 'Your financial data export from TrackFi',
      );
    } catch (e, st) {
      await log(message: 'Failed to share exported file', error: e, stackTrace: st);
      rethrow;
    }
  }

  Uint8List _buildImprovedCsv(List<Account> accounts, List<Transaction> transactions) {
    final StringBuffer buffer = StringBuffer();

    _addCsvSection(buffer, 'EXPORT INFORMATION', <List<String>>[
      <String>['Export Date', DateTime.now().toIso8601String()],
      <String>['Export Type', 'Complete Data Export'],
      <String>['Total Accounts', accounts.length.toString()],
      <String>['Active Accounts', accounts.where((Account a) => a.isActive).length.toString()],
      <String>['Total Transactions', transactions.length.toString()],
    ]);

    _addCsvSection(buffer, 'ACCOUNTS SUMMARY', <List<String>>[
      <String>['Name', 'Type', 'Currency', 'Balance', 'Status', 'Source', 'Bank', 'Created Date'],
      ...accounts.map(
        (Account a) => <String>[
          a.name,
          _formatAccountType(a.type),
          a.currency,
          a.balance.toStringAsFixed(2),
          if (a.isActive) 'Active' else 'Inactive',
          a.source,
          a.bankName ?? 'N/A',
          _formatDate(a.createdAt),
        ],
      ),
    ]);

    if (transactions.isNotEmpty) {
      final Map<String, _MonthlyStats> monthlyStats = _calculateMonthlyStats(transactions);

      _addCsvSection(buffer, 'MONTHLY SUMMARY', <List<String>>[
        <String>['Month', 'Income', 'Expenses', 'Net Amount', 'Transaction Count'],
        ...monthlyStats.entries.map(
          (MapEntry<String, _MonthlyStats> e) => <String>[
            e.key,
            e.value.income.toStringAsFixed(2),
            e.value.expenses.toStringAsFixed(2),
            e.value.net.toStringAsFixed(2),
            e.value.count.toString(),
          ],
        ),
      ]);
    }

    _addCsvSection(buffer, 'DETAILED TRANSACTIONS', <List<String>>[
      <String>['Date', 'Time', 'Account', 'Description', 'Category', 'Amount', 'Currency', 'Type', 'Reference', 'Status'],
      ...transactions.map((Transaction t) {
        final Account? account = accounts.cast<Account?>().firstWhere(
          (Account? a) => a?.id == t.accountId,
          orElse: () => null,
        );

        return <String>[
          _formatDate(t.transactionDate),
          _formatTime(t.transactionDate),
          account?.name ?? 'Unknown Account',
          t.description,
          if (t.categoryId != null) CategoryUtils.getCategoryName(t.categoryId!) else 'Uncategorized',
          t.amount.toStringAsFixed(2),
          account?.currency ?? 'RON',
          t.type.name.toUpperCase(),
          t.reference ?? '',
          _formatStatus(t.status),
        ];
      }),
    ]);

    return _encodeCsv(buffer.toString());
  }

  Future<Uint8List> _buildImprovedPdf(List<Account> accounts, List<Transaction> transactions) async {
    final pw.Document pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context _) => _buildCoverPage(accounts, transactions),
      ),
    );

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        header: (pw.Context _) => _buildPdfHeader('Account Summary'),
        build: (pw.Context _) => _buildAccountsSummary(accounts),
      ),
    );

    if (transactions.isNotEmpty) {
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(40),
          header: (pw.Context _) => _buildPdfHeader('Recent Transactions'),
          build: (pw.Context _) => _buildTransactionsSummary(
            transactions.take(200).toList(),
            accounts,
          ),
        ),
      );
    }

    return pdf.save();
  }

  Uint8List _buildAnalyticsCsv(
    List<Transaction> transactions,
    List<Account> accounts,
    String period,
    String baseCurrency,
  ) {
    final StringBuffer buffer = StringBuffer();
    final String currencySymbol = CurrencyUtils.getCurrencySymbol(baseCurrency);

    final double totalIncome = transactions
        .where((Transaction t) => t.type == TransactionType.credit)
        .fold(0.0, (double sum, Transaction t) => sum + t.amount);

    final double totalExpenses = transactions
        .where((Transaction t) => t.type == TransactionType.debit)
        .fold(0.0, (double sum, Transaction t) => sum + t.amount.abs());

    _addCsvSection(buffer, 'ANALYTICS SUMMARY', <List<String>>[
      <String>['Period', period],
      <String>['Base Currency', baseCurrency],
      <String>['Export Date', DateTime.now().toIso8601String()],
      <String>['Total Transactions', transactions.length.toString()],
      <String>['Total Income', '$currencySymbol${totalIncome.toStringAsFixed(2)}'],
      <String>['Total Expenses', '$currencySymbol${totalExpenses.toStringAsFixed(2)}'],
      <String>['Net Amount', '$currencySymbol${(totalIncome - totalExpenses).toStringAsFixed(2)}'],
      <String>['Savings Rate', if (totalIncome > 0) '${((totalIncome - totalExpenses) / totalIncome * 100).toStringAsFixed(1)}%' else '0%'],
    ]);

    final Map<String, _CategoryStats> catStats = _calculateCategoryStats(transactions);

    _addCsvSection(buffer, 'CATEGORY BREAKDOWN', <List<String>>[
      <String>['Category', 'Type', 'Amount', 'Transaction Count', 'Percentage'],
      ...catStats.entries.map(
        (MapEntry<String, _CategoryStats> e) => <String>[
          CategoryUtils.getCategoryName(e.key),
          CategoryUtils.getCategoryType(e.key).toUpperCase(),
          '$currencySymbol${e.value.amount.toStringAsFixed(2)}',
          e.value.count.toString(),
          '${e.value.percentage.toStringAsFixed(1)}%',
        ],
      ),
    ]);

    _addCsvSection(buffer, 'TRANSACTION DETAILS', <List<String>>[
      <String>['Date', 'Description', 'Category', 'Account', 'Amount', 'Type'],
      ...transactions.map((Transaction t) {
        final Account? account = accounts.cast<Account?>().firstWhere(
          (Account? a) => a?.id == t.accountId,
          orElse: () => null,
        );

        final String amount = t.type == TransactionType.debit
            ? '-$currencySymbol${t.amount.abs().toStringAsFixed(2)}'
            : '+$currencySymbol${t.amount.toStringAsFixed(2)}';

        return <String>[
          _formatDate(t.transactionDate),
          t.description,
          if (t.categoryId != null) CategoryUtils.getCategoryName(t.categoryId!) else 'Uncategorized',
          account?.name ?? 'Unknown',
          amount,
          t.type.name.toUpperCase(),
        ];
      }),
    ]);

    return _encodeCsv(buffer.toString());
  }

  Future<Uint8List> _buildAnalyticsPdf(
    List<Transaction> transactions,
    List<Account> accounts,
    String period,
    String baseCurrency,
  ) async {
    final pw.Document pdf = pw.Document();

    final double totalIncome = transactions
        .where((Transaction t) => t.type == TransactionType.credit)
        .fold(0.0, (double sum, Transaction t) => sum + t.amount);

    final double totalExpenses = transactions
        .where((Transaction t) => t.type == TransactionType.debit)
        .fold(0.0, (double sum, Transaction t) => sum + t.amount.abs());

    final String currencySymbol = CurrencyUtils.getCurrencySymbol(baseCurrency);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        header: (pw.Context _) => _buildPdfHeader('Financial Analytics Report'),
        build: (pw.Context _) => <pw.Widget>[
          pw.Container(
            padding: const pw.EdgeInsets.all(20),
            decoration: pw.BoxDecoration(
              color: PdfColors.blue50,
              borderRadius: pw.BorderRadius.circular(8),
              border: pw.Border.all(color: PdfColors.blue200),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: <pw.Widget>[
                pw.Text(
                  'Summary for $period',
                  style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 15),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: <pw.Widget>[
                    _buildSummaryItem('Total Income', '$currencySymbol${totalIncome.toStringAsFixed(2)}', PdfColors.green),
                    _buildSummaryItem('Total Expenses', '$currencySymbol${totalExpenses.toStringAsFixed(2)}', PdfColors.red),
                    _buildSummaryItem('Net Amount', '$currencySymbol${(totalIncome - totalExpenses).toStringAsFixed(2)}', PdfColors.black),
                  ],
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 30),
          pw.Text('Recent Transactions', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 15),
          pw.Table.fromTextArray(
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white, fontSize: 12),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.blue),
            cellPadding: const pw.EdgeInsets.all(10),
            cellStyle: const pw.TextStyle(fontSize: 10),
            headers: <dynamic>['Date', 'Description', 'Amount', 'Type'],
            data: transactions.take(100).map((Transaction t) {
              final String amount = t.type == TransactionType.debit
                  ? '-$currencySymbol${t.amount.abs().toStringAsFixed(2)}'
                  : '+$currencySymbol${t.amount.toStringAsFixed(2)}';

              return <String>[
                _formatDate(t.transactionDate),
                if (t.description.length > 40) '${t.description.substring(0, 40)}...' else t.description,
                amount,
                t.type.name.toUpperCase(),
              ];
            }).toList(),
          ),
        ],
      ),
    );

    return pdf.save();
  }

  pw.Widget _buildCoverPage(List<Account> accounts, List<Transaction> transactions) {
    return pw.Column(
      children: <pw.Widget>[
        pw.Spacer(flex: 2),
        pw.Text('TrackFi', style: pw.TextStyle(fontSize: 54, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 20),
        pw.Text('Financial Data Export', style: const pw.TextStyle(fontSize: 28, color: PdfColors.grey700)),
        pw.SizedBox(height: 60),
        pw.Container(
          padding: const pw.EdgeInsets.all(30),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey400, width: 2),
            borderRadius: pw.BorderRadius.circular(12),
          ),
          child: pw.Column(
            children: <pw.Widget>[
              pw.Text('Export Summary', style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 20),
              pw.Text('Generated: ${DateTime.now().toString().split('.')[0]}', style: const pw.TextStyle(fontSize: 14)),
              pw.SizedBox(height: 10),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                children: <pw.Widget>[
                  _buildCoverStat('Accounts', accounts.length.toString()),
                  _buildCoverStat('Active', accounts.where((Account a) => a.isActive).length.toString()),
                  _buildCoverStat('Transactions', transactions.length.toString()),
                ],
              ),
            ],
          ),
        ),
        pw.Spacer(flex: 3),
      ],
    );
  }

  pw.Widget _buildCoverStat(String label, String value) {
    return pw.Column(
      children: <pw.Widget>[
        pw.Text(value, style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.blue)),
        pw.SizedBox(height: 5),
        pw.Text(label, style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey600)),
      ],
    );
  }

  pw.Widget _buildPdfHeader(String title) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 20),
      decoration: const pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey300)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: <pw.Widget>[
          pw.Text(title, style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.Text('TrackFi Export', style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey600)),
        ],
      ),
    );
  }

  pw.Widget _buildSummaryItem(String label, String value, PdfColor color) {
    return pw.Column(
      children: <pw.Widget>[
        pw.Text(label, style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 5),
        pw.Text(value, style: pw.TextStyle(fontSize: 16, color: color, fontWeight: pw.FontWeight.bold)),
      ],
    );
  }

  List<pw.Widget> _buildAccountsSummary(List<Account> accounts) {
    return <pw.Widget>[
      pw.Text('Account Overview', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
      pw.SizedBox(height: 15),
      pw.Table.fromTextArray(
        headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white, fontSize: 12),
        headerDecoration: const pw.BoxDecoration(color: PdfColors.blue),
        cellPadding: const pw.EdgeInsets.all(10),
        cellStyle: const pw.TextStyle(fontSize: 11),
        headers: <dynamic>['Account Name', 'Type', 'Balance', 'Currency', 'Status'],
        data: accounts
            .map(
              (Account a) => <String>[
                a.name,
                _formatAccountType(a.type),
                a.balance.toStringAsFixed(2),
                a.currency,
                if (a.isActive) 'Active' else 'Inactive',
              ],
            )
            .toList(),
      ),
    ];
  }

  List<pw.Widget> _buildTransactionsSummary(List<Transaction> transactions, List<Account> accounts) {
    return <pw.Widget>[
      pw.Text('Recent Transactions', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
      pw.SizedBox(height: 15),
      pw.Table.fromTextArray(
        headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white, fontSize: 11),
        headerDecoration: const pw.BoxDecoration(color: PdfColors.blue),
        cellPadding: const pw.EdgeInsets.all(8),
        cellStyle: const pw.TextStyle(fontSize: 9),
        headers: <dynamic>['Date', 'Account', 'Description', 'Amount', 'Type'],
        data: transactions.map((Transaction t) {
          final Account? account = accounts.cast<Account?>().firstWhere(
            (Account? a) => a?.id == t.accountId,
            orElse: () => null,
          );

          final String currencySymbol = CurrencyUtils.getCurrencySymbol(account?.currency ?? 'RON');

          final String amount = t.type == TransactionType.debit
              ? '-$currencySymbol${t.amount.abs().toStringAsFixed(2)}'
              : '+$currencySymbol${t.amount.toStringAsFixed(2)}';

          return <String>[
            _formatDate(t.transactionDate),
            account?.name ?? 'Unknown',
            if (t.description.length > 35) '${t.description.substring(0, 35)}...' else t.description,
            amount,
            t.type.name.toUpperCase(),
          ];
        }).toList(),
      ),
    ];
  }

  void _addCsvSection(StringBuffer buffer, String sectionTitle, List<List<String>> data) {
    buffer.writeln();
    buffer.writeln(_csvQuote('=== $sectionTitle ==='));
    buffer.writeln();

    for (final List<String> row in data) {
      buffer.writeln(row.map(_csvQuote).join(','));
    }

    buffer.writeln();
  }

  Map<String, _MonthlyStats> _calculateMonthlyStats(List<Transaction> transactions) {
    final Map<String, _MonthlyStats> stats = <String, _MonthlyStats>{};

    for (final Transaction t in transactions) {
      final String key = '${t.transactionDate.year}-${t.transactionDate.month.toString().padLeft(2, '0')}';

      stats.putIfAbsent(key, () => _MonthlyStats());

      final _MonthlyStats s = stats[key]!;

      s.count++;

      if (t.type == TransactionType.credit) {
        s.income += t.amount;
      } else {
        s.expenses += t.amount.abs();
      }
    }

    final Map<String, _MonthlyStats> formatted = <String, _MonthlyStats>{};

    for (final MapEntry<String, _MonthlyStats> e in stats.entries) {
      e.value.net = e.value.income - e.value.expenses;

      final List<String> parts = e.key.split('-');
      final DateTime date = DateTime(int.parse(parts[0]), int.parse(parts[1]));
      final String label = '${_getMonthName(date.month)} ${date.year}';

      formatted[label] = e.value;
    }

    return Map<String, _MonthlyStats>.fromEntries(
      formatted.entries.toList()
        ..sort(
          (MapEntry<String, _MonthlyStats> a, MapEntry<String, _MonthlyStats> b) => a.key.compareTo(b.key),
        ),
    );
  }

  Map<String, _CategoryStats> _calculateCategoryStats(List<Transaction> transactions) {
    final Map<String, _CategoryStats> stats = <String, _CategoryStats>{};

    final double totalExpenses = transactions
        .where((Transaction t) => t.type == TransactionType.debit)
        .fold(0.0, (double sum, Transaction t) => sum + t.amount.abs());

    for (final Transaction t in transactions) {
      if (t.type != TransactionType.debit) {
        continue;
      }

      final String catId = t.categoryId ?? 'uncategorized';

      stats.putIfAbsent(catId, () => _CategoryStats());

      stats[catId]!.amount += t.amount.abs();
      stats[catId]!.count++;
    }

    for (final _CategoryStats s in stats.values) {
      s.percentage = totalExpenses > 0 ? (s.amount / totalExpenses) * 100 : 0;
    }

    final List<MapEntry<String, _CategoryStats>> sorted = stats.entries.toList()
      ..sort((MapEntry<String, _CategoryStats> a, MapEntry<String, _CategoryStats> b) => b.value.amount.compareTo(a.value.amount));

    return Map<String, _CategoryStats>.fromEntries(sorted);
  }

  String _csvQuote(String text) {
    if (text.contains(',') || text.contains('"') || text.contains('\n')) {
      return '"${text.replaceAll('"', '""')}"';
    }
    return text;
  }

  Uint8List _encodeCsv(String csvContent) {
    const List<int> bom = <int>[0xEF, 0xBB, 0xBF];
    final List<int> content = utf8.encode(csvContent);
    return Uint8List.fromList(<int>[...bom, ...content]);
  }

  String _formatDate(DateTime d) {
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }

  String _formatTime(DateTime d) {
    return '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }

  String _formatAccountType(String type) {
    return type.split('_').map((String w) => w[0].toUpperCase() + w.substring(1).toLowerCase()).join(' ');
  }

  String _formatStatus(String status) {
    return status.split('_').map((String w) => w[0].toUpperCase() + w.substring(1).toLowerCase()).join(' ');
  }

  String _getMonthName(int m) {
    const List<String> months = <String>[
      '',
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return months[m];
  }

  String _cleanFileName(String fileName) {
    return fileName.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_').replaceAll(RegExp(r'\s+'), '_').trim();
  }

  String _getExtension(ExportFormat format) {
    switch (format) {
      case ExportFormat.csv:
        return 'csv';
      case ExportFormat.pdf:
        return 'pdf';
    }
  }

  MimeType _getMimeType(ExportFormat format) {
    switch (format) {
      case ExportFormat.csv:
        return MimeType.text;
      case ExportFormat.pdf:
        return MimeType.pdf;
    }
  }

  String _getMimeString(ExportFormat format) {
    switch (format) {
      case ExportFormat.csv:
        return 'text/csv';
      case ExportFormat.pdf:
        return 'application/pdf';
    }
  }
}

class _MonthlyStats {
  double income = 0.0;
  double expenses = 0.0;
  double net = 0.0;
  int count = 0;
}

class _CategoryStats {
  double amount = 0.0;
  int count = 0;
  double percentage = 0.0;
}

class Account {
  const Account({
    required this.id,
    required this.name,
    required this.type,
    required this.balance,
    this.currency = 'GBP',
    this.bankName,
    this.accountNumber,
    this.sortCode,
    this.source = 'manual', // Add source field
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
    this.lastSyncedAt,
  });

  factory Account.fromMap(Map<String, dynamic> map) {
    return Account(
      id: map['id'] as String,
      name: map['name'] as String,
      type: map['type'] as String,
      balance: (map['balance'] as num).toDouble(),
      currency: map['currency'] as String? ?? 'GBP',
      bankName: map['bank_name'] as String?,
      accountNumber: map['account_number'] as String?,
      sortCode: map['sort_code'] as String?,
      source: map['source'] as String? ?? 'manual',
      isActive: (map['is_active'] as int) == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
      lastSyncedAt: map['last_synced_at'] != null
        ? DateTime.parse(map['last_synced_at'] as String)
        : null,
    );
  }

  final String id;
  final String name;
  final String type;
  final double balance;
  final String currency;
  final String? bankName;
  final String? accountNumber;
  final String? sortCode;
  final String source;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastSyncedAt;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'type': type,
      'balance': balance,
      'currency': currency,
      'bank_name': bankName,
      'account_number': accountNumber,
      'sort_code': sortCode,
      'source': source,
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'last_synced_at': lastSyncedAt?.toIso8601String(),
    };
  }

  Account copyWith({
    String? id,
    String? name,
    String? type,
    double? balance,
    String? currency,
    String? bankName,
    String? accountNumber,
    String? sortCode,
    String? source,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastSyncedAt,
  }) {
    return Account(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      balance: balance ?? this.balance,
      currency: currency ?? this.currency,
      bankName: bankName ?? this.bankName,
      accountNumber: accountNumber ?? this.accountNumber,
      sortCode: sortCode ?? this.sortCode,
      source: source ?? this.source,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
    );
  }

  bool get isManual => source == 'manual';
  bool get isSynced => source != 'manual';
}

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../contracts/services/database/i_database_service.dart';
import '../../contracts/services/secure_storage/i_encryption_storage_service.dart';
import '../../services/database/database_service.dart';
import '../secure_storage/encryption_storage_provider.dart';

final Provider<IDatabaseService> databaseServiceProvider = Provider<IDatabaseService>((ProviderRef<IDatabaseService> ref) {
  final IEncryptionStorageService encryption = ref.read(encryptionStorageProvider);
  return DatabaseService(encryption);
});

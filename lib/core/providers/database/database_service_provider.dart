import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../contracts/services/database/i_database_service.dart';
import '../../services/database/database_service.dart';

final Provider<IDatabaseService> databaseServiceProvider = Provider<IDatabaseService>((ProviderRef<IDatabaseService> ref) {
  return DatabaseService();
});

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:verby_flutter/data/dao/record_dao.dart';
import 'package:verby_flutter/data/repositories/auth_repository_impl.dart';
import 'package:verby_flutter/data/repositories/record_local_repository_impl.dart';
import 'package:verby_flutter/domain/repositories/auth_repository.dart';
import 'package:verby_flutter/domain/repositories/record_local_repository.dart';
import 'package:verby_flutter/presentation/providers/api_service_provider.dart';

import '../../../data/data_source/local/database_helper.dart';

final recordLocalRepositoryProvider = Provider<RecordLocalRepository>((ref) {
  return RecordLocalRepositoryImpl(RecordDao(DatabaseHelper()));
});

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:verby_flutter/presentation/providers/shared_pref_provider.dart';
import '../../data/data_source/remote/api_client.dart';

final apiServiceProvider = Provider<ApiClient>((ref) {
   return ApiClient();
});

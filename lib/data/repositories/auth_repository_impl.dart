import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:intl/intl.dart';
import 'package:verby_flutter/data/data_source/remote/api_client.dart';
import 'package:verby_flutter/data/models/remote/login_response_model.dart';
import 'package:verby_flutter/domain/core/failure.dart';
import 'package:verby_flutter/domain/repositories/auth_repository.dart';

import '../../core/api_constant.dart';

class AuthRepositoryImpl extends AuthRepository {
  final ApiClient apiService;

  AuthRepositoryImpl(this.apiService);

  @override
  Future<Either<Failure, LoginResponseModel>> login(
    String email,
    String password,
  ) async {
    {
      return await apiService.get(
        ApiConstant.login,
        queryParameters: {'email': email, 'password': password},
        fromJson: (data) => LoginResponseModel.fromJson(data),
      );
    }
  }

  @override
  Future<Either<Failure, bool>> checkPassword(
    String deviceID,
    String password,
  ) async {
    {
      return await apiService.get(
        ApiConstant.checkPassword(deviceID),
        queryParameters: {'password': password},
        fromJson: (data) => data,
      );
    }
  }

  @override
  void logout() {
    // apiService.clearAuthToken();
  }


}

import 'package:verby_flutter/data/models/local/depa_restant_model.dart';

class DepaRestantScreenState {
  final bool isLoading;
  final String? error;
  final List<DepaRestantModel?>? depa;
  final List<DepaRestantModel?>? restant;

  DepaRestantScreenState({
    this.isLoading = false,
    this.error = "",
    this.depa,
    this.restant,
  });

  DepaRestantScreenState copyWith({
    bool? isLoading,
    String? error,
    List<DepaRestantModel?>? depa,
    List<DepaRestantModel?>? restant,
  }) {
    return DepaRestantScreenState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      depa: depa ?? this.depa,
      restant: restant ?? this.restant,
    );
  }
}

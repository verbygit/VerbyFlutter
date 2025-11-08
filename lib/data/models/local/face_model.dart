import 'package:flutter/foundation.dart';

class FaceModel {
  final String employeeId;  // Primary key - employee ID
  final String employeeName;
  final List<double> faceEmbedding;
  final DateTime registeredAt;
  final DateTime lastUsedAt;
  final double confidenceThreshold;
  final bool isActive;
  final String? faceOrientation;
  final Map<String, dynamic> metadata;

  FaceModel({
    required this.employeeId,
    required this.employeeName,
    required this.faceEmbedding,
    required this.registeredAt,
    required this.lastUsedAt,
    this.confidenceThreshold = 0.6,
    this.isActive = true,
    this.faceOrientation,
    this.metadata = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'employee_id': employeeId,
      'employee_name': employeeName,
      'face_embedding': _embeddingToString(faceEmbedding),
      'registered_at': registeredAt.toIso8601String(),
      'last_used_at': lastUsedAt.toIso8601String(),
      'confidence_threshold': confidenceThreshold,
      'is_active': isActive ? 1 : 0,
      'face_orientation': faceOrientation,
      'metadata': _mapToJsonString(metadata),
    };
  }

  factory FaceModel.fromJson(Map<String, dynamic> json) {
    return FaceModel(
      employeeId: json['employee_id'],
      employeeName: json['employee_name'],
      faceEmbedding: _stringToEmbedding(json['face_embedding']),
      registeredAt: DateTime.parse(json['registered_at']),
      lastUsedAt: DateTime.parse(json['last_used_at']),
      confidenceThreshold: json['confidence_threshold']?.toDouble() ?? 0.6,
      isActive: json['is_active'] == 1,
      faceOrientation: json['face_orientation'],
      metadata: _jsonStringToMap(json['metadata']),
    );
  }

  // Convert embedding list to string for storage (better precision)
  static String _embeddingToString(List<double> embedding) {
    return embedding.map((e) => e.toString()).join(',');
  }

  // Convert string back to embedding list
  static List<double> _stringToEmbedding(String embeddingString) {
    if (embeddingString.isEmpty) return [];
    return embeddingString.split(',').map((s) => double.parse(s)).toList();
  }

  // Convert map to JSON string
  static String _mapToJsonString(Map<String, dynamic> map) {
    if (map.isEmpty) return '{}';
    return map.entries
        .map((e) => '"${e.key}":"${e.value}"')
        .join(',');
  }

  // Convert JSON string back to map
  static Map<String, dynamic> _jsonStringToMap(String jsonString) {
    if (jsonString.isEmpty || jsonString == '{}') return {};
    try {
      // Simple parsing for basic key-value pairs
      Map<String, dynamic> result = {};
      String clean = jsonString.replaceAll('{', '').replaceAll('}', '');
      if (clean.isNotEmpty) {
        List<String> pairs = clean.split(',');
        for (String pair in pairs) {
          List<String> keyValue = pair.split(':');
          if (keyValue.length == 2) {
            String key = keyValue[0].replaceAll('"', '').trim();
            String value = keyValue[1].replaceAll('"', '').trim();
            result[key] = value;
          }
        }
      }
      return result;
    } catch (e) {
      if (kDebugMode) {
        print('Error parsing metadata: $e');
      }
      return {};
    }
  }

  FaceModel copyWith({
    String? employeeId,
    String? employeeName,
    List<double>? faceEmbedding,
    DateTime? registeredAt,
    DateTime? lastUsedAt,
    double? confidenceThreshold,
    bool? isActive,
    String? faceOrientation,
    Map<String, dynamic>? metadata,
  }) {
    return FaceModel(
      employeeId: employeeId ?? this.employeeId,
      employeeName: employeeName ?? this.employeeName,
      faceEmbedding: faceEmbedding ?? this.faceEmbedding,
      registeredAt: registeredAt ?? this.registeredAt,
      lastUsedAt: lastUsedAt ?? this.lastUsedAt,
      confidenceThreshold: confidenceThreshold ?? this.confidenceThreshold,
      isActive: isActive ?? this.isActive,
      faceOrientation: faceOrientation ?? this.faceOrientation,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  String toString() {
    return 'FaceModel(employeeId: $employeeId, employeeName: $employeeName, isActive: $isActive)';
  }
}

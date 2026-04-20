import 'dart:convert';

import 'package:electiva_2026/config/api_endpoints.dart';
import 'package:electiva_2026/models/department.dart';
import 'package:electiva_2026/models/president.dart';
import 'package:electiva_2026/models/region.dart';
import 'package:electiva_2026/models/touristic_attraction.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ApiColombiaService {
  ApiColombiaService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  String get _baseUrl {
    final envUrl = dotenv.env['API_BASE_URL']?.trim() ?? '';
    if (envUrl.isNotEmpty) {
      return envUrl;
    }
    return 'https://api-colombia.com/api/v1';
  }

  Future<List<Department>> getDepartments() async {
    final data = await _fetchList(endpointPath: 'Department');
    return data.map(Department.fromJson).toList();
  }

  Future<List<President>> getPresidents() async {
    final data = await _fetchList(endpointPath: 'President');
    return data.map(President.fromJson).toList();
  }

  Future<List<Region>> getRegions() async {
    final data = await _fetchList(endpointPath: 'Region');
    return data.map(Region.fromJson).toList();
  }

  Future<List<TouristicAttraction>> getTouristicAttractions() async {
    final data = await _fetchList(endpointPath: 'TouristicAttraction');
    return data.map(TouristicAttraction.fromJson).toList();
  }

  Future<List<Map<String, dynamic>>> getEndpointItems(
    String endpointKey,
  ) async {
    switch (endpointKey) {
      case 'departments':
        final list = await getDepartments();
        return list
            .map(
              (item) => {
                'id': item.id.toString(),
                'title': item.name,
                'subtitle': item.cityCapital,
                'description': item.description,
                'image': '',
                'raw': item.toJson(),
              },
            )
            .toList();
      case 'presidents':
        final list = await getPresidents();
        return list
            .map(
              (item) => {
                'id': item.id.toString(),
                'title': '${item.name} ${item.lastName}'.trim(),
                'subtitle': item.startPeriodDate,
                'description': item.description,
                'image': _normalizeImageUrl(item.image),
                'raw': item.toJson(),
              },
            )
            .toList();
      case 'regions':
        final list = await getRegions();
        return list
            .map(
              (item) => {
                'id': item.id.toString(),
                'title': item.name,
                'subtitle': 'Region natural',
                'description': item.description,
                'image': '',
                'raw': item.toJson(),
              },
            )
            .toList();
      case 'touristic-attractions':
        final list = await getTouristicAttractions();
        return list
            .map(
              (item) => {
                'id': item.id.toString(),
                'title': item.name,
                'subtitle': item.city,
                'description': item.description,
                'image': _pickFirstValidImage(item.images),
                'raw': item.toJson(),
              },
            )
            .toList();
      default:
        throw const ApiException('Endpoint no soportado para este parcial.');
    }
  }

  Future<Map<String, dynamic>> getEndpointItemById({
    required String endpointKey,
    required String id,
  }) async {
    final endpoint = getEndpointByKey(endpointKey);
    try {
      final detail = await _fetchMap(endpointPath: '${endpoint.path}/$id');
      if (endpointKey == 'departments') {
        return _enrichDepartmentDetail(detail);
      }
      if (endpointKey == 'regions') {
        return _enrichRegionDetail(detail, id);
      }
      return detail;
    } catch (_) {
      final list = await getEndpointItems(endpointKey);
      final selected = list.firstWhere(
        (item) => item['id'].toString() == id,
        orElse: () => <String, dynamic>{},
      );

      if (endpointKey == 'departments') {
        if (selected['raw'] is Map<String, dynamic>) {
          return _enrichDepartmentDetail(
            selected['raw'] as Map<String, dynamic>,
          );
        }
        return _enrichDepartmentDetail(selected);
      }

      if (endpointKey == 'regions') {
        if (selected['raw'] is Map<String, dynamic>) {
          return _enrichRegionDetail(
            selected['raw'] as Map<String, dynamic>,
            id,
          );
        }
        return _enrichRegionDetail(selected, id);
      }

      return selected;
    }
  }

  Future<List<Map<String, dynamic>>> _fetchList({
    required String endpointPath,
  }) async {
    final uri = Uri.parse('$_baseUrl/$endpointPath');
    final response = await _client.get(
      uri,
      headers: {'accept': 'application/json'},
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException('Error HTTP ${response.statusCode} en $endpointPath');
    }

    final dynamic decoded = jsonDecode(response.body);
    if (decoded is! List) {
      throw const ApiException('La respuesta no tiene formato de lista.');
    }

    return decoded
        .whereType<Map>()
        .map((item) => item.map((key, value) => MapEntry('$key', value)))
        .toList();
  }

  Future<Map<String, dynamic>> _fetchMap({required String endpointPath}) async {
    final uri = Uri.parse('$_baseUrl/$endpointPath');
    final response = await _client.get(
      uri,
      headers: {'accept': 'application/json'},
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException('Error HTTP ${response.statusCode} en $endpointPath');
    }

    final dynamic decoded = jsonDecode(response.body);
    if (decoded is! Map) {
      throw const ApiException('La respuesta no tiene formato de detalle.');
    }

    return decoded.map((key, value) => MapEntry('$key', value));
  }

  Future<Map<String, dynamic>> _enrichDepartmentDetail(
    Map<String, dynamic> input,
  ) async {
    final detail = Map<String, dynamic>.from(input);
    final departmentId = _toInt(detail['id']);
    final originalRegion = detail['region'];

    final regionName = _extractRegionName(detail['region']);
    if (regionName.isNotEmpty) {
      if ((detail['regionId'] == null || '${detail['regionId']}'.isEmpty) &&
          originalRegion is Map) {
        detail['regionId'] = _toInt(originalRegion['id']);
      }
      detail['region'] = regionName;
      if (departmentId > 0) {
        await _completeDepartmentRelatedCounts(detail, departmentId);
      }
      return detail;
    }

    final regionId = _toInt(detail['regionId']);
    if (regionId <= 0) {
      return detail;
    }

    try {
      final region = await _fetchMap(endpointPath: 'Region/$regionId');
      final resolvedName = _extractRegionName(region);
      if (resolvedName.isNotEmpty) {
        detail['region'] = resolvedName;
      }
    } catch (_) {
      // Keep original detail if region lookup fails.
    }

    if (departmentId > 0) {
      await _completeDepartmentRelatedCounts(detail, departmentId);
    }

    return detail;
  }

  Future<void> _completeDepartmentRelatedCounts(
    Map<String, dynamic> detail,
    int departmentId,
  ) async {
    await _fillDepartmentCountIfEmpty(
      detail,
      key: 'cities',
      endpointCandidates: ['Department/$departmentId/cities'],
    );

    await _fillDepartmentCountIfEmpty(
      detail,
      key: 'airports',
      endpointCandidates: ['Department/$departmentId/airports'],
    );

    await _fillDepartmentCountIfEmpty(
      detail,
      key: 'naturalAreas',
      endpointCandidates: [
        'Department/$departmentId/naturalareas',
        'Department/$departmentId/naturalAreas',
      ],
    );

    await _fillDepartmentCountIfEmpty(
      detail,
      key: 'indigenousReservations',
      endpointCandidates: [
        'Department/$departmentId/indigenousreservations',
        'Department/$departmentId/indigenousReservations',
      ],
    );

    await _fillDepartmentCountIfEmpty(
      detail,
      key: 'maps',
      endpointCandidates: ['Department/$departmentId/maps'],
    );
  }

  Future<void> _fillDepartmentCountIfEmpty(
    Map<String, dynamic> detail, {
    required String key,
    required List<String> endpointCandidates,
  }) async {
    final current = detail[key];
    if (!_isEmptyValue(current)) {
      if (current is List) {
        detail[key] = current.length;
      }
      return;
    }

    for (final endpointPath in endpointCandidates) {
      try {
        final list = await _fetchList(endpointPath: endpointPath);
        detail[key] = list.length;
        return;
      } catch (_) {
        // Try next candidate path.
      }
    }
  }

  Future<Map<String, dynamic>> _enrichRegionDetail(
    Map<String, dynamic> input,
    String regionId,
  ) async {
    final detail = Map<String, dynamic>.from(input);

    // Normalize lists to counts when API already returns embedded arrays.
    if (detail['departments'] is List) {
      detail['departments'] = (detail['departments'] as List).length;
    }
    if (detail['cities'] is List) {
      detail['cities'] = (detail['cities'] as List).length;
    }

    await _fillRegionDepartmentsCountIfEmpty(detail, regionId);
    await _fillRegionCitiesCountIfEmpty(detail, regionId);

    return detail;
  }

  Future<void> _fillRegionDepartmentsCountIfEmpty(
    Map<String, dynamic> detail,
    String regionId,
  ) async {
    if (!_isEmptyValue(detail['departments'])) {
      return;
    }

    // First try direct nested endpoint for region departments.
    try {
      final list = await _fetchList(
        endpointPath: 'Region/$regionId/departments',
      );
      detail['departments'] = list.length;
      return;
    } catch (_) {
      // Fallback below.
    }

    // Fallback: derive count from all departments filtering by region id.
    try {
      final departments = await getDepartments();
      final count = departments
          .where((d) => d.regionId.toString() == regionId)
          .length;
      detail['departments'] = count;
    } catch (_) {
      // Keep original if fallback fails.
    }
  }

  Future<void> _fillRegionCitiesCountIfEmpty(
    Map<String, dynamic> detail,
    String regionId,
  ) async {
    if (!_isEmptyValue(detail['cities'])) {
      return;
    }

    // First try direct nested endpoint for region cities.
    for (final path in <String>[
      'Region/$regionId/cities',
      'Region/$regionId/municipalities',
    ]) {
      try {
        final list = await _fetchList(endpointPath: path);
        detail['cities'] = list.length;
        return;
      } catch (_) {
        // Try next candidate.
      }
    }

    // Fallback: sum cities per department in the region.
    try {
      final departments = await getDepartments();
      final regionDepartments = departments
          .where((d) => d.regionId.toString() == regionId)
          .toList();

      var totalCities = 0;
      var resolvedAtLeastOneDepartment = false;

      for (final department in regionDepartments) {
        try {
          final cities = await _fetchList(
            endpointPath: 'Department/${department.id}/cities',
          );
          totalCities += cities.length;
          resolvedAtLeastOneDepartment = true;
        } catch (_) {
          // Continue with next department.
        }
      }

      if (resolvedAtLeastOneDepartment) {
        detail['cities'] = totalCities;
      }
    } catch (_) {
      // Keep original if fallback fails.
    }
  }
}

class ApiException implements Exception {
  const ApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

String _normalizeImageUrl(String? value) {
  final url = (value ?? '').trim();
  if (url.isEmpty) return '';

  final uri = Uri.tryParse(url);
  if (uri == null) return '';

  final isHttp = uri.scheme == 'http' || uri.scheme == 'https';
  return isHttp ? url : '';
}

String _pickFirstValidImage(List<String> images) {
  for (final image in images) {
    final normalized = _normalizeImageUrl(image);
    if (normalized.isNotEmpty) {
      return normalized;
    }
  }
  return '';
}

String _extractRegionName(dynamic regionValue) {
  if (regionValue == null) return '';

  if (regionValue is Map<String, dynamic>) {
    return (regionValue['name']?.toString() ?? '').trim();
  }

  if (regionValue is Map) {
    return (regionValue['name']?.toString() ?? '').trim();
  }

  return regionValue.toString().trim();
}

int _toInt(dynamic value) {
  if (value is int) return value;
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

bool _isEmptyValue(dynamic value) {
  if (value == null) return true;
  if (value is String) return value.trim().isEmpty;
  if (value is List) return value.isEmpty;
  if (value is Map) return value.isEmpty;
  return false;
}

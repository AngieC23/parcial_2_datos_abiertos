class Department {
  const Department({
    required this.id,
    required this.name,
    required this.description,
    required this.cityCapital,
    required this.surface,
    required this.region,
    required this.regionId,
  });

  final int id;
  final String name;
  final String description;
  final String cityCapital;
  final String surface;
  final String region;
  final int regionId;

  factory Department.fromJson(Map<String, dynamic> json) {
    return Department(
      id: _toInt(json['id']),
      name: _toStringValue(json['name']),
      description: _toStringValue(json['description']),
      cityCapital: _toStringValue(json['cityCapital']),
      surface: _toStringValue(json['surface']),
      region: _extractRegionName(json),
      regionId: _extractRegionId(json),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'cityCapital': cityCapital,
      'surface': surface,
      'region': region,
      'regionId': regionId,
    };
  }
}

int _toInt(dynamic value) {
  if (value is int) return value;
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

String _toStringValue(dynamic value) {
  return value?.toString() ?? '';
}

String _extractRegionName(Map<String, dynamic> json) {
  final region = json['region'];
  if (region is Map<String, dynamic>) {
    return _toStringValue(region['name']);
  }

  if (region is Map) {
    return _toStringValue(region['name']);
  }

  if (region != null) {
    return _toStringValue(region);
  }

  return _toStringValue(json['regionName']);
}

int _extractRegionId(Map<String, dynamic> json) {
  final region = json['region'];
  if (region is Map<String, dynamic>) {
    return _toInt(region['id']);
  }

  if (region is Map) {
    return _toInt(region['id']);
  }

  return _toInt(json['regionId']);
}

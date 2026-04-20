class Region {
  const Region({
    required this.id,
    required this.name,
    required this.description,
  });

  final int id;
  final String name;
  final String description;

  factory Region.fromJson(Map<String, dynamic> json) {
    return Region(
      id: _toInt(json['id']),
      name: _toStringValue(json['name']),
      description: _toStringValue(json['description']),
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'description': description};
  }
}

int _toInt(dynamic value) {
  if (value is int) return value;
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

String _toStringValue(dynamic value) {
  return value?.toString() ?? '';
}

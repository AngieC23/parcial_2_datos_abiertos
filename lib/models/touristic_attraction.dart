class TouristicAttraction {
  const TouristicAttraction({
    required this.id,
    required this.name,
    required this.description,
    required this.images,
    required this.city,
  });

  final int id;
  final String name;
  final String description;
  final List<String> images;
  final String city;

  factory TouristicAttraction.fromJson(Map<String, dynamic> json) {
    return TouristicAttraction(
      id: _toInt(json['id']),
      name: _toStringValue(json['name']),
      description: _toStringValue(json['description']),
      images: _toStringList(json['images']),
      city: _toStringValue(json['city']?['name'] ?? json['city']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'images': images,
      'city': city,
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

List<String> _toStringList(dynamic value) {
  if (value is List) {
    return value.map((item) => item.toString()).toList();
  }
  return const [];
}

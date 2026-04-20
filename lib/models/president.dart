class President {
  const President({
    required this.id,
    required this.name,
    required this.lastName,
    required this.startPeriodDate,
    required this.endPeriodDate,
    required this.politicalParty,
    required this.description,
    required this.image,
  });

  final int id;
  final String name;
  final String lastName;
  final String startPeriodDate;
  final String endPeriodDate;
  final String politicalParty;
  final String description;
  final String image;

  factory President.fromJson(Map<String, dynamic> json) {
    return President(
      id: _toInt(json['id']),
      name: _toStringValue(json['name']),
      lastName: _toStringValue(json['lastName']),
      startPeriodDate: _toStringValue(json['startPeriodDate']),
      endPeriodDate: _toStringValue(json['endPeriodDate']),
      politicalParty: _toStringValue(json['politicalParty']),
      description: _toStringValue(json['description']),
      image: _toStringValue(json['image']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'lastName': lastName,
      'startPeriodDate': startPeriodDate,
      'endPeriodDate': endPeriodDate,
      'politicalParty': politicalParty,
      'description': description,
      'image': image,
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

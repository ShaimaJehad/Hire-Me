class MainFieldModel {
  final String id;
  final String name;
  final String iconUrl;

  MainFieldModel({required this.id, required this.name, required this.iconUrl});

  factory MainFieldModel.fromMap(String id, Map<String, dynamic> data) {
    return MainFieldModel(
      id: id,
      name: data['name'] ?? '',
      iconUrl: data['iconUrl'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {'name': name, 'iconUrl': iconUrl};
  }
}

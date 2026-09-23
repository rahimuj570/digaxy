class UserModel {
  final String id;
  final String name;
  final String role; // mover | driver | helper

  UserModel({required this.id, required this.name, required this.role});

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json['id']?.toString() ?? '',
    name: json['name'] ?? '',
    role: json['role'] ?? '',
  );

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'role': role};
}

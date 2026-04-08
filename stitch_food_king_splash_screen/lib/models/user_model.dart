class UserModel {
  final String id;
  final String name;
  final String phoneNumber;
  final String? email;

  UserModel({
    required this.id,
    required this.name,
    required this.phoneNumber,
    this.email,
  });

  factory UserModel.fromMap(Map<String, dynamic> data, String documentId) {
    return UserModel(
      id: documentId,
      name: data['name'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      email: data['email'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phoneNumber': phoneNumber,
      'email': email,
    };
  }
}

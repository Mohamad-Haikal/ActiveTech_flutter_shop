class User {
  final String uid;
  final String name;
  final String phoneNumber;
  final String email;
  final String displayPicture;

  User({
    required this.email,
    required this.displayPicture,
    required this.uid,
    required this.name,
    required this.phoneNumber,
  });

  factory User.fromMap(Map<String, dynamic> data, String documentId) {
    return User(
      uid: documentId,
      name: data['name'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      email: data['email'] ?? '',
      displayPicture: data['display_picture'] ?? '',
    );
  }

  Map<String, dynamic> toMap(
      {required String uid, required String name, required String phoneNumbe, required String email, required String displayPicture}) {
    return {
      'uid': uid,
      'name': name,
      'phoneNumber': phoneNumbe,
      'email': email,
      'display_picture': displayPicture,
    };
  }
}

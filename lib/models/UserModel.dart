import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  String id;
  String name;
  String email;

  UserModel({required this.id, required this.name, required this.email});

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      name: data['username'] ?? 'No Name',
      email: data['email'] ?? 'No Email',
    );
  }
}

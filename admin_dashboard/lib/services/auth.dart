import 'package:firebase_auth/firebase_auth.dart';

class Authentication {
  static Future<UserCredential?> signIn({required String email, required String password}) async {
    final auth = FirebaseAuth.instance;
    return await auth.signInWithEmailAndPassword(email: email, password: password);
  }

 
}

import 'package:avery_cab_app/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthController{

  static User? getAuthUser() {
    return FirebaseAuth.instance.currentUser;
  }

  static Future<List<dynamic>> getAuthUsers() async {
    final users = await FirebaseFirestore.instance.collection('users').get().
    then((value) => value.docs.map((e) => {
      'id': e['uid'],
      'email': e['email'],
    }).toList());

    return users;
  }


  static Future<User?> register(String email, String password) async{
    try {
     final UserCredential userCredential =  await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
    final UserModel user = UserModel(
          email: userCredential.user!.email,
          fullName: userCredential.user!.displayName,
          phone: userCredential.user!.phoneNumber);
      await FirebaseFirestore.instance.collection('users').add(user.toMap());
     return userCredential.user;
    } 
    on FirebaseAuthException catch (e){
      switch (e.code) {
        case 'user-not-found':
          throw 'No account found';

        case 'wrong-password':
          throw 'Incorrect password';

        case 'invalid-email':
          throw 'Invalid email';

        default:
          throw e.message ?? 'Authentication failed';
      }
    } 
    catch (e) {
      throw "Something went wrong";
    }
  }

  static Future<User?> login(String email, String password)async {
    try {
      final UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(email: email.trim(), password: password);
      
      // final UserModel user = UserModel(email: userCredential.user!.email, fullName: userCredential.user!.displayName, phone: userCredential.user!.phoneNumber);
      // await FirebaseFirestore.instance.collection('users').add(user.toMap());
      return userCredential.user;
    } 
    on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          throw 'No account found';

        case 'wrong-password':
          throw 'Incorrect password';

        case 'invalid-email':
          throw 'Invalid email';

        default:
          throw e.message ?? 'Authentication failed';
      }
    }
    catch (e) {
      throw "Something went wrong";
    }
  }

  static void logout(){
    try {
      FirebaseAuth.instance.signOut();
    } on FirebaseAuthException catch (e) {
      throw Exception(e);
    }
  }
}
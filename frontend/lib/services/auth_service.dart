import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
  import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/api_constants.dart';




class AuthService {
  static String? jwtToken;
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn();



  static Future<void> fetchJwtToken() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception("User not logged in");
    }

    final response = await http.post(
      Uri.parse("${ApiConstants.baseUrl}/token"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": user.email,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      final token = data["access_token"];

      // ✅ SAVE JWT
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("jwt", token);

      // ✅ SET IN MEMORY
      ApiConstants.jwtToken = token;

    } else {
      throw Exception("Failed to fetch JWT token");
    }
  }



  // Email login
  static Future<void> login(String email, String password) async {
    await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Email signup
  static Future<void> signup(String email, String password) async {
    await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Google sign-in
  static Future<void> signInWithGoogle() async {
    // 🔑 IMPORTANT: clear previous Google session
    await _googleSignIn.signOut();

    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return;

    final googleAuth = await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    await _auth.signInWithCredential(credential);
  }

  // Full logout (Firebase + Google)
  static Future<void> logout() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
  }
}

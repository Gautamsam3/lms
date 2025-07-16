import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static const String supabaseUrl = 'https://rwepuasjrprfdhhrlpxj.supabase.co'; // Replace with your URL
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJ3ZXB1YXNqcnByZmRoaHJscHhqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTI2NzM4MzUsImV4cCI6MjA2ODI0OTgzNX0.dzeYgL-ODjld7BtZJ1m39wj4m2VggPgj4jbK8V3KVv4'; // Replace with your anon key
  
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }
  
  static SupabaseClient get client => Supabase.instance.client;
  
  // Sign up method
  static Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
    required String year,
    required String branch,
  }) async {
    try {
      final AuthResponse response = await client.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName,
          'year': year,
          'branch': branch,
        },
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }
  
  // Sign in method
  static Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final AuthResponse response = await client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }
  
  // Sign out method
  static Future<void> signOut() async {
    try {
      await client.auth.signOut();
    } catch (e) {
      rethrow;
    }
  }
  
  // Get current user
  static User? getCurrentUser() {
    return client.auth.currentUser;
  }
  
  // Check if user is signed in
  static bool isSignedIn() {
    return client.auth.currentUser != null;
  }
}
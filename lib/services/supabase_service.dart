import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static Future<void> initialize({
    required String url,
    required String anonKey,
  }) async {
    await Supabase.initialize(
      url: url,
      anonKey: anonKey,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;

  static User? get currentUser => client.auth.currentUser;

  static Stream<AuthState> get authStateChanges =>
      client.auth.onAuthStateChange;

  static Future<AuthResponse> signUp({
    required String email,
    required String password,
    Map<String, dynamic>? data,
  }) async {
    return await client.auth.signUp(
      email: email,
      password: password,
      data: data,
    );
  }

  static Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  static Future<void> signOut() async {
    await client.auth.signOut();
  }

  /// Save a completed rep to the database
  /// Returns the inserted record ID, or null if insertion failed
  static Future<String?> saveRepCompletion({
    required String userId,
    required String exerciseName,
    required int repNumber,
    required int score,
    DateTime? date,
  }) async {
    try {
      final response = await client.from('workout_sessions').insert({
        'user_id': userId,
        'exercise_name': exerciseName,
        'rep_number': repNumber,
        'score': score,
        'date': (date ?? DateTime.now()).toIso8601String(),
        'created_at': DateTime.now().toIso8601String(),
      }).select('id');

      if (response.isNotEmpty && response.first is Map) {
        return response.first['id'] as String?;
      }
      return null;
    } catch (e) {
      // Log error but don't throw - we don't want to break the workout flow
      print('Error saving rep completion: $e');
      return null;
    }
  }
}

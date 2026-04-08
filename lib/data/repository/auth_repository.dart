import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(Supabase.instance.client);
});

class AuthRepository {
  final SupabaseClient _supabaseClient;

  AuthRepository(this._supabaseClient);

  /// Generates a URL-safe username from [displayName] with a cryptographically
  /// random 5-character suffix to minimise collision probability.
  String _generateUsername(String displayName) {
    // Sanitise: lowercase, collapse whitespace to underscores, strip
    // non-alphanumeric characters, then cap at 15 characters.
    final sanitised = displayName
        .toLowerCase()
        .trim()
        .replaceAll(RegExp(r'\s+'), '_')
        .replaceAll(RegExp(r'[^a-z0-9_]'), '');

    final base = sanitised.length > 15
        ? sanitised.substring(0, 15)
        : sanitised.isNotEmpty
        ? sanitised
        : 'user';

    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random.secure(); // Use cryptographic RNG, not Random().
    final suffix =
    List.generate(5, (_) => chars[random.nextInt(chars.length)]).join();

    return '${base}_$suffix';
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final response = await _supabaseClient.auth.signUp(
      email: email,
      password: password,
    );

    final user = response.user;
    if (user == null) {
      // Supabase may return a null user if email confirmation is required.
      throw const AuthException(
        'Registration requires email confirmation. Please check your inbox.',
      );
    }

    // Insert the public profile row. Retries once on username collision.
    await _insertUserProfile(userId: user.id, displayName: displayName);
  }

  /// Inserts a row into the public `users` table. Retries up to [maxAttempts]
  /// times on a PostgreSQL unique-violation (code 23505) before re-throwing.
  Future<void> _insertUserProfile({
    required String userId,
    required String displayName,
    int attempt = 0,
    int maxAttempts = 3,
  }) async {
    try {
      await _supabaseClient.from('users').insert({
        'id': userId,
        'username': _generateUsername(displayName),
        'display_name': displayName,
        'age': 18,            // Satisfies the CHECK (age >= 13) constraint.
        'gender': 'prefer_not_to_say',
      });
    } on PostgrestException catch (error) {
      // 23505 = unique_violation. Retry with a freshly generated username.
      if (error.code == '23505' && attempt < maxAttempts - 1) {
        return _insertUserProfile(
          userId: userId,
          displayName: displayName,
          attempt: attempt + 1,
          maxAttempts: maxAttempts,
        );
      }
      // All retries exhausted or a different DB error — surface it.
      rethrow;
    }
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    await _supabaseClient.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }
}
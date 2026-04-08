import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../ui/home_screen.dart';
import '../viewmodel/auth_notifier.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _displayNameController = TextEditingController();

  bool _isPasswordObscured = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _displayNameController.dispose();
    super.dispose();
  }

  Future<void> _submitAuth() async {
    if (!_formKey.currentState!.validate()) return;

    final isSignUpMode =
        ref.read(authNotifierProvider).valueOrNull?.isSignUpMode ?? false;

    await ref.read(authNotifierProvider.notifier).submitAuth(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      displayName:
      isSignUpMode ? _displayNameController.text.trim() : null,
    );
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _emailController.clear();
    _passwordController.clear();
    _displayNameController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final authAsync = ref.watch(authNotifierProvider);
    final colorScheme = Theme.of(context).colorScheme;

    final isSignUpMode = authAsync.valueOrNull?.isSignUpMode ?? false;
    final errorMessage = authAsync.valueOrNull?.errorMessage;
    final isLoading = authAsync is AsyncLoading;

    // Inferred type — AsyncNotifierProviderImpl is not directly assignable
    // to ProviderListenable<AsyncValue<T>> when written explicitly in Riverpod 2.x.
    ref.listen(authNotifierProvider, (previous, next) {
      if (previous is AsyncLoading &&
          next is AsyncData &&
          next.value?.errorMessage == null) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    });

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 48),

                // App icon / branding
                Icon(Icons.auto_awesome, size: 56, color: colorScheme.primary),
                const SizedBox(height: 16),

                Text(
                  isSignUpMode ? 'Create Account' : 'Welcome Back',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  isSignUpMode
                      ? 'Sign up to start chatting with AI characters'
                      : 'Sign in to continue',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // Error banner
                if (errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.error_outline_rounded,
                          color: colorScheme.onErrorContainer,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            errorMessage,
                            style: TextStyle(
                                color: colorScheme.onErrorContainer),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // Display name field — shown for Sign Up only
                if (isSignUpMode) ...[
                  TextFormField(
                    controller: _displayNameController,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Display Name',
                      prefixIcon: Icon(Icons.person_outline),
                      border: OutlineInputBorder(),
                      hintText: 'e.g. John Doe',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Display name is required';
                      }
                      if (value.trim().length < 2) {
                        return 'Must be at least 2 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                ],

                // Email field
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.mail_outline),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Email is required';
                    }
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                        .hasMatch(value.trim())) {
                      return 'Enter a valid email address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Password field with visibility toggle
                TextFormField(
                  controller: _passwordController,
                  obscureText: _isPasswordObscured,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: isLoading ? null : (_) => _submitAuth(),
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordObscured
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      tooltip: _isPasswordObscured
                          ? 'Show password'
                          : 'Hide password',
                      onPressed: () => setState(
                            () => _isPasswordObscured = !_isPasswordObscured,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Password is required';
                    }
                    if (value.trim().length < 6) {
                      return 'Must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),

                // Primary action button
                FilledButton(
                  onPressed: isLoading ? null : _submitAuth,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: isLoading
                      ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: colorScheme.onPrimary,
                    ),
                  )
                      : Text(
                    isSignUpMode ? 'Sign Up' : 'Sign In',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(height: 16),

                // Mode toggle
                TextButton(
                  onPressed: isLoading
                      ? null
                      : () {
                    ref
                        .read(authNotifierProvider.notifier)
                        .toggleAuthMode();
                    _resetForm();
                  },
                  child: RichText(
                    text: TextSpan(
                      text: isSignUpMode
                          ? 'Already have an account? '
                          : "Don't have an account? ",
                      style: TextStyle(color: colorScheme.onSurfaceVariant),
                      children: [
                        TextSpan(
                          text: isSignUpMode ? 'Sign In' : 'Sign Up',
                          style: TextStyle(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
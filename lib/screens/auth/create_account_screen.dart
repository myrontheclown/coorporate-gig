import 'package:flutter/material.dart';
import '../../navigation/nav.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';

class CreateAccountScreen extends StatefulWidget {
  final String role;

  const CreateAccountScreen({
    super.key,
    required this.role,
  });

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _extraController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _extraController.dispose();
    super.dispose();
  }

  String get _roleTitle {
    switch (widget.role) {
      case 'worker':
        return 'Worker';
      case 'cooperative_admin':
        return 'Cooperative Admin';
      default:
        return 'Client';
    }
  }

  String get _extraLabel {
    switch (widget.role) {
      case 'worker':
        return 'Profession';
      case 'cooperative_admin':
        return 'Cooperative / Federation';
      default:
        return '';
    }
  }

  String get _extraHint {
    switch (widget.role) {
      case 'worker':
        return 'e.g. Plumber, Electrician, Carpenter';
      case 'cooperative_admin':
        return 'e.g. Mumbai Workers Cooperative';
      default:
        return '';
    }
  }

  IconData get _roleIcon {
    switch (widget.role) {
      case 'worker':
        return Icons.engineering_outlined;
      case 'cooperative_admin':
        return Icons.account_balance_outlined;
      default:
        return Icons.person_outline;
    }
  }

  Color get _roleColor {
    switch (widget.role) {
      case 'worker':
        return AppColors.cooperative;
      case 'cooperative_admin':
        return AppColors.warning;
      default:
        return AppColors.primary;
    }
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your name';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your email';
    }
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Enter a valid email address';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  String? _validateConfirm(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  String? _validateExtra(String? value) {
    if (_extraLabel.isEmpty) return null;
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your $_extraLabel';
    }
    return null;
  }

  Future<void> _handleCreateAccount() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await AuthService.createAccount(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        fullName: _nameController.text.trim(),
        role: widget.role,
        extra: _extraController.text.trim(),
      );

      if (!mounted) return;

      if (result.success) {
        Nav.navigateAfterAuth(context, widget.role);
      } else {
        setState(() {
          _errorMessage = result.error ?? 'Account creation failed.';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'An error occurred. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          children: [
            _buildBackButton(),
            const SizedBox(height: 24),
            _buildHeader(),
            const SizedBox(height: 28),
            _buildForm(),
            if (_errorMessage != null) ...[
              const SizedBox(height: 12),
              _buildErrorBanner(),
            ],
            const SizedBox(height: 20),
            _buildCreateButton(),
            const SizedBox(height: 24),
            _buildSignInLink(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildBackButton() {
    return Align(
      alignment: Alignment.centerLeft,
      child: GestureDetector(
        onTap: () => Nav.pop(context),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.divider),
          ),
          child: const Icon(
            Icons.arrow_back_ios_new,
            size: 18,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _roleColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(_roleIcon, color: _roleColor, size: 28),
        ),
        const SizedBox(height: 16),
        Text(
          'Create $_roleTitle Account',
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Join Coorporate Gig as a $_roleTitle',
          style: const TextStyle(
            fontSize: 15,
            color: AppColors.textSecondary,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _nameController,
            textInputAction: TextInputAction.next,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            decoration: const InputDecoration(
              hintText: 'Full name',
              prefixIcon: Icon(Icons.person_outline, color: AppColors.textMuted),
            ),
            validator: _validateName,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            decoration: const InputDecoration(
              hintText: 'Email address',
              prefixIcon: Icon(Icons.email_outlined, color: AppColors.textMuted),
            ),
            validator: _validateEmail,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.next,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            decoration: InputDecoration(
              hintText: 'Password',
              prefixIcon: const Icon(Icons.lock_outline, color: AppColors.textMuted),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: AppColors.textMuted,
                  size: 20,
                ),
                onPressed: () {
                  setState(() => _obscurePassword = !_obscurePassword);
                },
              ),
            ),
            validator: _validatePassword,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _confirmPasswordController,
            obscureText: _obscureConfirm,
            textInputAction: TextInputAction.next,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            decoration: InputDecoration(
              hintText: 'Confirm password',
              prefixIcon: const Icon(Icons.lock_outline, color: AppColors.textMuted),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: AppColors.textMuted,
                  size: 20,
                ),
                onPressed: () {
                  setState(() => _obscureConfirm = !_obscureConfirm);
                },
              ),
            ),
            validator: _validateConfirm,
          ),
          if (_extraLabel.isNotEmpty) ...[
            const SizedBox(height: 14),
            TextFormField(
              controller: _extraController,
              textInputAction: TextInputAction.done,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              onFieldSubmitted: (_) => _handleCreateAccount(),
              decoration: InputDecoration(
                hintText: _extraHint,
                prefixIcon: Icon(
                  widget.role == 'worker'
                      ? Icons.work_outline
                      : Icons.account_balance_outlined,
                  color: AppColors.textMuted,
                ),
              ),
              validator: _validateExtra,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildErrorBanner() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.errorBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.error, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _errorMessage!,
              style: const TextStyle(
                color: AppColors.error,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreateButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleCreateAccount,
        child: _isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : const Text('Create Account'),
      ),
    );
  }

  Widget _buildSignInLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Already have an account? ',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
        ),
        GestureDetector(
          onTap: () {
            Nav.pop(context);
          },
          child: Text(
            'Sign in',
            style: TextStyle(
              color: _roleColor,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

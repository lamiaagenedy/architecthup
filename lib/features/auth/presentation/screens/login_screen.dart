import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../shared/presentation/widgets/common/app_logo.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_notice_banner.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(text: 'manager@aces.com');
  final _passwordController = TextEditingController(text: 'manager123');
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  bool _rememberMe = true;
  bool _obscurePassword = true;
  bool _showValidation = false;

  bool get _isFormValid =>
      _validateEmail(_emailController.text) == null &&
      _validatePassword(_passwordController.text) == null;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_handleFieldChanged);
    _passwordController.addListener(_handleFieldChanged);
  }

  @override
  void dispose() {
    _emailController.removeListener(_handleFieldChanged);
    _passwordController.removeListener(_handleFieldChanged);
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: AppDimensions.screenPadding,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: AppCard(
                padding: AppDimensions.cardPadding,
                child: Form(
                  key: _formKey,
                  autovalidateMode: _showValidation
                      ? AutovalidateMode.onUserInteraction
                      : AutovalidateMode.disabled,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _AuthBrandHeader(),
                      const SizedBox(height: AppDimensions.spacingSection),
                      Text(
                        AppStrings.loginTitle,
                        style: AppTextStyles.pageTitle,
                      ),
                      const SizedBox(height: AppDimensions.sm),
                      Text(
                        AppStrings.loginSubtitle,
                        style: AppTextStyles.secondary,
                      ),
                      const SizedBox(height: AppDimensions.spacingCard),
                      AuthNoticeBanner(
                        message: 'Manager: manager@aces.com / manager123',
                        icon: Icons.info_outline,
                        backgroundColor: AppColors.primary.withValues(
                          alpha: 0.12,
                        ),
                        foregroundColor: AppColors.textPrimary,
                      ),
                      const SizedBox(height: AppDimensions.spacingCard),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 280),
                        child: authState.errorMessage == null
                            ? const SizedBox.shrink()
                            : Padding(
                                key: ValueKey(authState.errorMessage),
                                padding: const EdgeInsets.only(
                                  bottom: AppDimensions.md,
                                ),
                                child: AuthNoticeBanner(
                                  message: authState.errorMessage!,
                                  icon: Icons.error_outline,
                                  backgroundColor: AppColors.danger.withValues(
                                    alpha: 0.12,
                                  ),
                                  foregroundColor: AppColors.danger,
                                ),
                              ),
                      ),
                      TextFormField(
                        controller: _emailController,
                        focusNode: _emailFocusNode,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.username],
                        decoration: const InputDecoration(
                          labelText: AppStrings.loginEmailLabel,
                          hintText: 'name@company.com',
                          prefixIcon: Icon(Icons.alternate_email_outlined),
                        ),
                        validator: _validateEmail,
                        onChanged: (_) => _clearAuthError(),
                        onFieldSubmitted: (_) {
                          _passwordFocusNode.requestFocus();
                        },
                      ),
                      const SizedBox(height: AppDimensions.md),
                      TextFormField(
                        controller: _passwordController,
                        focusNode: _passwordFocusNode,
                        obscureText: _obscurePassword,
                        textInputAction: TextInputAction.done,
                        autofillHints: const [AutofillHints.password],
                        decoration: InputDecoration(
                          labelText: AppStrings.loginPasswordLabel,
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            onPressed: authState.isSubmitting
                                ? null
                                : () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                            tooltip: _obscurePassword
                                ? 'Show password'
                                : 'Hide password',
                          ),
                        ),
                        validator: _validatePassword,
                        onChanged: (_) => _clearAuthError(),
                        onFieldSubmitted: (_) => _submit(),
                      ),
                      const SizedBox(height: AppDimensions.md),
                      InkWell(
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusButton,
                        ),
                        onTap: authState.isSubmitting
                            ? null
                            : () {
                                setState(() {
                                  _rememberMe = !_rememberMe;
                                });
                              },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: AppDimensions.sm,
                          ),
                          child: Row(
                            children: [
                              Checkbox(
                                value: _rememberMe,
                                onChanged: authState.isSubmitting
                                    ? null
                                    : (value) {
                                        setState(() {
                                          _rememberMe = value ?? false;
                                        });
                                      },
                              ),
                              const SizedBox(width: AppDimensions.xs),
                              Expanded(
                                child: Text(
                                  AppStrings.loginRememberMe,
                                  style: AppTextStyles.body.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: AppDimensions.spacingSection),
                      SizedBox(
                        width: double.infinity,
                        height: AppDimensions.buttonHeight,
                        child: FilledButton(
                          onPressed: authState.isSubmitting || !_isFormValid
                              ? null
                              : _submit,
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 180),
                            child: authState.isSubmitting
                                ? const _SubmittingContent()
                                : const Text(
                                    AppStrings.loginPrimaryAction,
                                    key: ValueKey('idle'),
                                  ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppDimensions.md),
                      Text(
                        AppStrings.loginHelperBody,
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String? _validateEmail(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return 'Enter your work email.';
    }

    final emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailPattern.hasMatch(trimmed)) {
      return 'Use a valid email address.';
    }

    return null;
  }

  String? _validatePassword(String? value) {
    final password = value ?? '';
    if (password.isEmpty) {
      return 'Enter your password.';
    }

    if (password.length < 6) {
      return 'Password must be at least 6 characters.';
    }

    return null;
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _showValidation = true;
    });

    if (!_formKey.currentState!.validate()) {
      return;
    }

    await ref
        .read(authControllerProvider.notifier)
        .login(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          rememberMe: _rememberMe,
        );
  }

  void _handleFieldChanged() {
    if (!mounted) {
      return;
    }

    if (_showValidation) {
      setState(() {});
    }
    _clearAuthError();
  }

  void _clearAuthError() {
    ref.read(authControllerProvider.notifier).clearError();
  }
}

class _AuthBrandHeader extends StatelessWidget {
  const _AuthBrandHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppLogo(size: 48, borderRadius: 16),
        const SizedBox(height: AppDimensions.sm),
        Text(
          AppStrings.appName,
          style: AppTextStyles.pageTitle.copyWith(color: AppColors.primary),
        ),
      ],
    );
  }
}

class _SubmittingContent extends StatelessWidget {
  const _SubmittingContent();

  @override
  Widget build(BuildContext context) {
    return Row(
      key: const ValueKey('submitting'),
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        SizedBox(width: AppDimensions.sm),
        Text(AppStrings.loginSubmitting),
      ],
    );
  }
}

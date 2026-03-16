import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/design_tokens.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_notice_banner.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(text: 'user@example.com');
  final _passwordController = TextEditingController(text: 'securePassword123');
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
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colorScheme.primary.withValues(alpha: 0.16),
              AppColors.surface,
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  Positioned(
                    top: -60,
                    right: -20,
                    child: _BackgroundAccent(
                      size: 180,
                      color: colorScheme.primary.withValues(alpha: 0.08),
                    ),
                  ),
                  Positioned(
                    top: 120,
                    left: -36,
                    child: _BackgroundAccent(
                      size: 120,
                      color: colorScheme.secondary.withValues(alpha: 0.08),
                    ),
                  ),
                  SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.lg,
                      vertical: AppDimensions.xl,
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight:
                            constraints.maxHeight - (AppDimensions.xl * 2),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _AuthBrandHeader(),
                          const SizedBox(height: AppDimensions.xl),
                          Container(
                            width: double.infinity,
                            padding: DesignTokens.cardPadding,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.96),
                              borderRadius: BorderRadius.circular(
                                DesignTokens.screenRadius,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: colorScheme.shadow.withValues(
                                    alpha: 0.08,
                                  ),
                                  blurRadius: 36,
                                  offset: const Offset(0, 18),
                                ),
                              ],
                            ),
                            child: Form(
                              key: _formKey,
                              autovalidateMode: _showValidation
                                  ? AutovalidateMode.onUserInteraction
                                  : AutovalidateMode.disabled,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    AppStrings.loginEyebrow,
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelLarge
                                        ?.copyWith(
                                          color: colorScheme.primary,
                                          fontWeight: FontWeight.w700,
                                        ),
                                  ),
                                  const SizedBox(height: AppDimensions.sm),
                                  Text(
                                    AppStrings.loginTitle,
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall
                                        ?.copyWith(letterSpacing: -0.4),
                                  ),
                                  const SizedBox(height: AppDimensions.sm),
                                  Text(
                                    AppStrings.loginSubtitle,
                                    style: Theme.of(context).textTheme.bodyLarge
                                        ?.copyWith(
                                          color: colorScheme.onSurfaceVariant,
                                        ),
                                  ),
                                  const SizedBox(height: AppDimensions.lg),
                                  AuthNoticeBanner(
                                    message:
                                        '${AppStrings.loginHelperTitle}: ${AppStrings.loginMockCredentials}',
                                    icon: Icons.info_outline_rounded,
                                    backgroundColor: colorScheme
                                        .primaryContainer
                                        .withValues(alpha: 0.45),
                                    foregroundColor:
                                        colorScheme.onPrimaryContainer,
                                  ),
                                  const SizedBox(height: AppDimensions.lg),
                                  AnimatedSwitcher(
                                    duration: DesignTokens.mediumAnimation,
                                    child: authState.errorMessage == null
                                        ? const SizedBox.shrink()
                                        : Padding(
                                            key: ValueKey(
                                              authState.errorMessage,
                                            ),
                                            padding: const EdgeInsets.only(
                                              bottom: AppDimensions.md,
                                            ),
                                            child: AuthNoticeBanner(
                                              message: authState.errorMessage!,
                                              icon: Icons.error_outline_rounded,
                                              backgroundColor: colorScheme
                                                  .errorContainer
                                                  .withValues(alpha: 0.7),
                                              foregroundColor:
                                                  colorScheme.onErrorContainer,
                                            ),
                                          ),
                                  ),
                                  TextFormField(
                                    controller: _emailController,
                                    focusNode: _emailFocusNode,
                                    keyboardType: TextInputType.emailAddress,
                                    textInputAction: TextInputAction.next,
                                    autofillHints: const [
                                      AutofillHints.username,
                                    ],
                                    decoration: const InputDecoration(
                                      labelText: AppStrings.loginEmailLabel,
                                      hintText: 'name@company.com',
                                      prefixIcon: Icon(
                                        Icons.alternate_email_rounded,
                                      ),
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
                                    autofillHints: const [
                                      AutofillHints.password,
                                    ],
                                    decoration: InputDecoration(
                                      labelText: AppStrings.loginPasswordLabel,
                                      prefixIcon: const Icon(
                                        Icons.lock_outline_rounded,
                                      ),
                                      suffixIcon: IconButton(
                                        onPressed: authState.isSubmitting
                                            ? null
                                            : () {
                                                setState(() {
                                                  _obscurePassword =
                                                      !_obscurePassword;
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
                                      DesignTokens.buttonRadius,
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
                                                      _rememberMe =
                                                          value ?? false;
                                                    });
                                                  },
                                          ),
                                          const SizedBox(
                                            width: AppDimensions.xs,
                                          ),
                                          Expanded(
                                            child: Text(
                                              AppStrings.loginRememberMe,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: AppDimensions.lg),
                                  SizedBox(
                                    width: double.infinity,
                                    child: FilledButton(
                                      onPressed:
                                          authState.isSubmitting ||
                                              !_isFormValid
                                          ? null
                                          : _submit,
                                      child: AnimatedSwitcher(
                                        duration: DesignTokens.shortAnimation,
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
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(
                                          color: colorScheme.onSurfaceVariant,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
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
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: colorScheme.primary,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(
            Icons.domain_verification_rounded,
            color: Colors.white,
            size: 28,
          ),
        ),
        const SizedBox(width: AppDimensions.md),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.appName,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: AppDimensions.xs),
            Text(
              'Field-first construction operations',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
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

class _BackgroundAccent extends StatelessWidget {
  const _BackgroundAccent({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
    );
  }
}

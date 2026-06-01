import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../app/navigation/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          color: AppColors.primary,
          onPressed: () => context.go(RouteNames.dashboard),
        ),
        title: const Text('Profile'),
      ),
      body: ListView(
        padding: AppDimensions.screenPadding,
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.profileAccountSection,
                  style: AppTextStyles.sectionTitle,
                ),
                const SizedBox(height: AppDimensions.md),
                _ProfileInfoRow(
                  label: AppStrings.profileNameLabel,
                  value: user?.name ?? '-',
                ),
                const SizedBox(height: AppDimensions.sm),
                _ProfileInfoRow(
                  label: AppStrings.profileRoleLabel,
                  value: user?.role ?? AppStrings.defaultUserRole,
                ),
                const SizedBox(height: AppDimensions.sm),
                _ProfileInfoRow(
                  label: AppStrings.profileEmailLabel,
                  value: user?.email ?? '-',
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.spacingCard),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.profileWorkspaceSection,
                  style: AppTextStyles.sectionTitle,
                ),
                const SizedBox(height: AppDimensions.md),
                _ProfileInfoRow(
                  label: AppStrings.profileSiteAccessLabel,
                  value: AppStrings.tabDashboard,
                ),
                const SizedBox(height: AppDimensions.sm),
                _ProfileInfoRow(
                  label: AppStrings.profileNotificationsLabel,
                  value: AppStrings.profileNotificationsValue,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.spacingSection),
          FilledButton.icon(
            onPressed: authState.isSubmitting
                ? null
                : () => _confirmLogout(context, ref),
            icon: const Icon(Icons.logout_rounded),
            label: const Text(AppStrings.profileLogoutLabel),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.danger,
              minimumSize: const Size.fromHeight(AppDimensions.buttonHeight),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            AppStrings.profileLogoutConfirmTitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          content: const Text(
            AppStrings.profileLogoutConfirmBody,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(
                AppStrings.profileCancelAction,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text(
                AppStrings.profileLogoutLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    await ref.read(authControllerProvider.notifier).logout();
  }
}

class _ProfileInfoRow extends StatelessWidget {
  const _ProfileInfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.caption,
          ),
        ),
        const SizedBox(width: AppDimensions.md),
        Expanded(
          child: Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.right,
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}

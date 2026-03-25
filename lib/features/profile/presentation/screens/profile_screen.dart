import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/design_tokens.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final authState = ref.watch(authControllerProvider);
    final user = ref.watch(currentUserProvider);

    return SafeArea(
      top: false,
      child: ListView(
        padding: DesignTokens.pagePadding,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.profileAccountSection,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
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
          ),
          const SizedBox(height: AppDimensions.md),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.profileWorkspaceSection,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
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
          ),
          const SizedBox(height: AppDimensions.xl),
          Divider(color: colorScheme.outlineVariant),
          const SizedBox(height: AppDimensions.sm),
          TextButton.icon(
            onPressed: authState.isSubmitting
                ? null
                : () => _confirmLogout(context, ref),
            icon: Icon(Icons.logout_rounded, color: colorScheme.error),
            label: Text(
              AppStrings.profileLogoutLabel,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textTheme.titleMedium?.copyWith(
                color: colorScheme.error,
                fontWeight: FontWeight.w700,
              ),
            ),
            style: TextButton.styleFrom(
              alignment: Alignment.centerLeft,
              minimumSize: const Size.fromHeight(48),
              padding: const EdgeInsets.symmetric(horizontal: AppDimensions.xs),
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
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(width: AppDimensions.md),
        Expanded(
          child: Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.right,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}

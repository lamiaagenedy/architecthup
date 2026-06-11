import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/di/app_providers.dart';
import '../../../../app/navigation/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/manager_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Safe helpers (no direct casts – avoids 'String is not a subtype of num')
// ─────────────────────────────────────────────────────────────────────────────
int _safeInt(dynamic v, {int fallback = 0}) =>
    int.tryParse(v?.toString() ?? '') ?? fallback;

double _safeDouble(dynamic v, {double fallback = 0.0}) =>
    double.tryParse(v?.toString() ?? '') ?? fallback;

String _safeStr(dynamic v, {String fallback = ''}) =>
    v?.toString().trim().isNotEmpty == true ? v.toString().trim() : fallback;

// ─────────────────────────────────────────────────────────────────────────────
// Grade helpers
// ─────────────────────────────────────────────────────────────────────────────
String _gradeLabel(double scorePercent) {
  if (scorePercent >= 90) return 'Excellent';
  if (scorePercent >= 80) return 'Good';
  if (scorePercent >= 75) return 'Acceptable';
  return 'Needs Improvement';
}

Color _gradeColor(double scorePercent) {
  if (scorePercent >= 90) return AppColors.success;
  if (scorePercent >= 80) return const Color(0xFF007AFF); // blue
  if (scorePercent >= 75) return AppColors.warning;
  return AppColors.danger;
}

Color _scoreColor(int score) {
  if (score < 75) return AppColors.danger;
  if (score < 80) return AppColors.warning;
  return AppColors.success;
}

// ─────────────────────────────────────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────────────────────────────────────
class ManagerReportScreen extends ConsumerWidget {
  const ManagerReportScreen({required this.projectId, super.key});

  final String projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportAsync = ref.watch(managerReportProvider(projectId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.cardBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          color: AppColors.primary,
          onPressed: () => context.go(RouteNames.managerProjects),
        ),
        title: const Text('Project Report'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_outlined),
            color: AppColors.primary,
            tooltip: 'Download PDF',
            onPressed: () => _downloadPdf(context, ref),
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            onPressed: () => _confirmLogout(context, ref),
          ),
        ],
      ),
      body: reportAsync.when(
        data: (report) => _ReportBody(report: report, projectId: projectId),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: AppDimensions.screenPadding,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, color: AppColors.danger, size: 48),
                const SizedBox(height: AppDimensions.sm),
                Text(
                  error.toString(),
                  textAlign: TextAlign.center,
                  style: AppTextStyles.secondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm != true) return;
    await ref.read(authControllerProvider.notifier).logout();
    await ref.read(authLocalDatasourceProvider).clearSession();
    if (!context.mounted) return;
    context.go(RouteNames.login);
  }

  Future<void> _downloadPdf(BuildContext context, WidgetRef ref) async {
    try {
      final bytes = await ref
          .read(managerRemoteDatasourceProvider)
          .downloadReportPdf(projectId);

      if (!context.mounted || bytes.isEmpty) return;

      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/aces-report-$projectId.pdf');
      await file.writeAsBytes(bytes);

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PDF saved to ${file.path}')),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PDF download failed: $e')),
      );
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Report body
// ─────────────────────────────────────────────────────────────────────────────
class _ReportBody extends StatelessWidget {
  const _ReportBody({required this.report, required this.projectId});

  final Map<String, dynamic> report;
  final String projectId;

  @override
  Widget build(BuildContext context) {
    final progress = _safeInt(report['progress']);
    final overallScore = _safeDouble(report['overall_score']);
    // overall_score is 0.0–1.0 fraction; multiply × 100 for display
    final scorePercent = overallScore * 100;

    // Collect all items from all services
    final services =
        ((report['services'] as List?) ?? []).cast<Map<String, dynamic>>();
    final allItems = <Map<String, dynamic>>[];
    for (final service in services) {
      final items =
          ((service['items'] as List?) ?? []).cast<Map<String, dynamic>>();
      for (final item in items) {
        allItems.add({...item, '_service_name': service['name'] ?? ''});
      }
    }

    // Empty state: no inspection started yet
    if (progress == 0 || allItems.isEmpty) {
      return _EmptyStateView();
    }

    // Attention items: score != null && score < 80
    final attentionItems = allItems.where((item) {
      final scoreRaw = item['score'];
      if (scoreRaw == null) return false;
      final score = _safeInt(scoreRaw);
      return score < 80;
    }).toList();

    // Comment items: items with non-empty comment
    final commentItems = allItems.where((item) {
      final comment = item['comment']?.toString().trim() ?? '';
      return comment.isNotEmpty;
    }).toList();

    return ListView(
      padding: AppDimensions.screenPadding,
      children: [
        // ── Project header card ──────────────────────────────────────────────
        _ProjectHeaderCard(
          report: report,
          scorePercent: scorePercent,
          progress: progress,
        ),
        const SizedBox(height: AppDimensions.spacingSection),

        // ── Attention section ────────────────────────────────────────────────
        _SectionHeader(
          icon: Icons.warning_amber_rounded,
          iconColor: AppColors.warning,
          title: 'Items Needing Attention',
          subtitle: attentionItems.isEmpty
              ? null
              : '${attentionItems.length} item(s) below threshold',
        ),
        const SizedBox(height: AppDimensions.md),

        if (attentionItems.isEmpty)
          _AllGoodCard()
        else
          ...attentionItems.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: AppDimensions.sm),
              child: _AttentionItemCard(item: item),
            ),
          ),

        const SizedBox(height: AppDimensions.spacingSection),

        // ── Comments section ─────────────────────────────────────────────────
        if (commentItems.isNotEmpty) ...[
          _SectionHeader(
            icon: Icons.chat_bubble_outline_rounded,
            iconColor: AppColors.primary,
            title: 'Inspector Comments',
            subtitle: '${commentItems.length} comment(s)',
          ),
          const SizedBox(height: AppDimensions.md),
          ...commentItems.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: AppDimensions.sm),
              child: _CommentCard(item: item),
            ),
          ),
          const SizedBox(height: AppDimensions.spacingSection),
        ],
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Empty state
// ─────────────────────────────────────────────────────────────────────────────
class _EmptyStateView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppDimensions.screenPadding,
        child: AppCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: AppDimensions.md),
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.schedule_outlined,
                  size: 36,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: AppDimensions.md),
              Text(
                'Inspection Not Started',
                style: AppTextStyles.sectionTitle,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppDimensions.xs),
              Text(
                'No checklist items have been scored yet.',
                style: AppTextStyles.secondary,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppDimensions.md),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Project header card
// ─────────────────────────────────────────────────────────────────────────────
class _ProjectHeaderCard extends StatelessWidget {
  const _ProjectHeaderCard({
    required this.report,
    required this.scorePercent,
    required this.progress,
  });

  final Map<String, dynamic> report;
  final double scorePercent;
  final int progress;

  @override
  Widget build(BuildContext context) {
    final gradeLabel = _gradeLabel(scorePercent);
    final gradeColor = _gradeColor(scorePercent);
    final projectName = _safeStr(report['project_name'], fallback: 'Untitled');
    final company = _safeStr(report['company_name'], fallback: '—');
    final location = _safeStr(report['location'], fallback: '—');
    final supervisor = _safeStr(report['inspector_name'], fallback: '—');

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name + grade badge
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(projectName, style: AppTextStyles.sectionTitle),
              ),
              const SizedBox(width: AppDimensions.sm),
              _GradeBadge(label: gradeLabel, color: gradeColor),
            ],
          ),
          const SizedBox(height: AppDimensions.sm),

          // Company
          _MetaRow(icon: Icons.business_outlined, text: company),
          const SizedBox(height: AppDimensions.xs),

          // Location
          _MetaRow(icon: Icons.place_outlined, text: location),
          const SizedBox(height: AppDimensions.xs),

          // Supervisor
          _MetaRow(icon: Icons.person_outline, text: supervisor),
          const SizedBox(height: AppDimensions.md),

          // Progress bar + score
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Progress $progress%',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.xs),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        value: (progress / 100).clamp(0.0, 1.0),
                        minHeight: 8,
                        backgroundColor: AppColors.divider,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(gradeColor),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppDimensions.md),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${scorePercent.toStringAsFixed(1)}%',
                    style: AppTextStyles.sectionTitle.copyWith(
                      color: gradeColor,
                      fontSize: 20,
                    ),
                  ),
                  Text(
                    'Overall Score',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section header
// ─────────────────────────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 18),
        ),
        const SizedBox(width: AppDimensions.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTextStyles.sectionTitle),
              if (subtitle != null)
                Text(subtitle!, style: AppTextStyles.caption),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Attention item card
// ─────────────────────────────────────────────────────────────────────────────
class _AttentionItemCard extends StatelessWidget {
  const _AttentionItemCard({required this.item});

  final Map<String, dynamic> item;

  @override
  Widget build(BuildContext context) {
    final itemNumber = _safeInt(item['item_number']);
    final textEn = _safeStr(item['text_en'], fallback: '—');
    final textAr = _safeStr(item['text_ar']);
    final score = _safeInt(item['score']);
    final comment = item['comment']?.toString().trim() ?? '';
    final hasComment = comment.isNotEmpty;
    final scoreColor = _scoreColor(score);

    return AppCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Number circle
          _ItemNumberCircle(number: itemNumber, color: scoreColor),
          const SizedBox(width: AppDimensions.md),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // English text
                Text(
                  textEn,
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),

                // Arabic text
                if (textAr.isNotEmpty) ...[
                  const SizedBox(height: AppDimensions.xs),
                  Directionality(
                    textDirection: TextDirection.rtl,
                    child: SizedBox(
                      width: double.infinity,
                      child: Text(
                        textAr,
                        style: AppTextStyles.secondary,
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: AppDimensions.sm),

                // Score pill
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: scoreColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        'Score: $score',
                        style: AppTextStyles.caption.copyWith(
                          color: scoreColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),

                // Comment
                const SizedBox(height: AppDimensions.xs),
                Text(
                  hasComment ? comment : 'No comment',
                  style: AppTextStyles.secondary.copyWith(
                    fontStyle: hasComment ? null : FontStyle.italic,
                    color: hasComment
                        ? AppColors.textSecondary
                        : AppColors.textSecondary.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// All-good card
// ─────────────────────────────────────────────────────────────────────────────
class _AllGoodCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppDimensions.cardPadding,
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.30)),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline, color: AppColors.success),
          const SizedBox(width: AppDimensions.sm),
          Text(
            'All items performing well ✓',
            style: AppTextStyles.body.copyWith(
              color: AppColors.success,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Comment card
// ─────────────────────────────────────────────────────────────────────────────
class _CommentCard extends StatelessWidget {
  const _CommentCard({required this.item});

  final Map<String, dynamic> item;

  @override
  Widget build(BuildContext context) {
    final itemNumber = _safeInt(item['item_number']);
    final textEn = _safeStr(item['text_en'], fallback: '—');
    final comment = item['comment']?.toString().trim() ?? '';

    return AppCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ItemNumberCircle(number: itemNumber, color: AppColors.primary),
          const SizedBox(width: AppDimensions.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  textEn,
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppDimensions.sm),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.md,
                    vertical: AppDimensions.sm,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(10),
                    border: Border(
                      left: BorderSide(
                        color: AppColors.primary,
                        width: 3,
                      ),
                    ),
                  ),
                  child: Text(
                    '" $comment "',
                    style: AppTextStyles.secondary.copyWith(
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared small widgets
// ─────────────────────────────────────────────────────────────────────────────
class _ItemNumberCircle extends StatelessWidget {
  const _ItemNumberCircle({required this.number, required this.color});

  final int number;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        '$number',
        style: AppTextStyles.caption.copyWith(
          color: color,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _GradeBadge extends StatelessWidget {
  const _GradeBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: AppDimensions.xs),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.secondary,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

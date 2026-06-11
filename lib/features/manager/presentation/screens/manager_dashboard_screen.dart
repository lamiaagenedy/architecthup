import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/navigation/route_names.dart';
import '../../../../app/di/app_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_grade_badge.dart';
import '../../../../core/widgets/app_icon_container.dart';
import '../providers/manager_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class ManagerDashboardScreen extends ConsumerWidget {
  const ManagerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(managerDashboardProvider);
    final currentUser = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.verified_outlined,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'ACES Manager',
              style: AppTextStyles.sectionTitle.copyWith(
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.people_outline, color: AppColors.primary),
            tooltip: 'Supervisors',
            onPressed: () => context.go(RouteNames.managerUsers),
          ),
          IconButton(
            icon: Icon(Icons.apartment_outlined, color: AppColors.primary),
            tooltip: 'Projects',
            onPressed: () => context.go(RouteNames.managerProjects),
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            tooltip: 'Logout',
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  title: const Text('Logout'),
                  content: const Text('Are you sure you want to logout?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text(
                        'Logout',
                        style: TextStyle(color: Colors.redAccent),
                      ),
                    ),
                  ],
                ),
              );
              if (confirm != true) return;
              await ref.read(authControllerProvider.notifier).logout();
              await ref.read(authLocalDatasourceProvider).clearSession();
              context.go(RouteNames.login);
            },
          ),
        ],
      ),
      body: dashboardAsync.when(
        data: (data) {
          final topProjects = (data['top_projects'] as List? ?? [])
              .cast<Map<String, dynamic>>();
          final bottomProjects = (data['bottom_projects'] as List? ?? [])
              .cast<Map<String, dynamic>>();
          final incomplete = (data['incomplete_projects'] as List? ?? [])
              .cast<Map<String, dynamic>>();
          final serviceAvgs = (data['per_service_average'] as List? ?? [])
              .cast<Map<String, dynamic>>();
          final totalProjects = num.tryParse(data['total_projects']?.toString() ?? '0') ?? 0;
          final totalSupervisors = num.tryParse(data['total_supervisors']?.toString() ?? '0') ?? 0;
          final averageScore =
              (double.tryParse(data['average_score']?.toString() ?? '0') ?? 0.0) * 100;
          final completionRate = totalProjects == 0
              ? 0.0
              : ((totalProjects - incomplete.length) / totalProjects.toInt()) *
                    100;

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(managerDashboardProvider);
              await ref.read(managerDashboardProvider.future);
            },
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
              children: [
                Text(
                  'Welcome back,',
                  style: AppTextStyles.body.copyWith(
                    color: const Color(0xFF8E8E93),
                  ),
                ),
                Text(
                  currentUser?.name ?? 'Manager',
                  style: AppTextStyles.pageTitle,
                ),
                const SizedBox(height: 28),

                _HeroPerformanceCard(
                  score: averageScore,
                  totalProjects: totalProjects.toInt(),
                  totalSupervisors: totalSupervisors.toInt(),
                  onTap: () => context.go(RouteNames.managerProjects),
                ),
                const SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(
                      child: _MiniStatCard(
                        label: 'Active Projects',
                        value: '$totalProjects',
                        icon: Icons.apartment_outlined,
                        iconColor: AppColors.primary,
                        onTap: () => context.go(RouteNames.managerProjects),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _MiniStatCard(
                        label: 'Field Supervisors',
                        value: '$totalSupervisors',
                        icon: Icons.people_outline,
                        iconColor: const Color(0xFF34C759),
                        onTap: () => context.go(RouteNames.managerUsers),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _MiniStatCard(
                        label: 'Avg Inspection Score',
                        value: '${averageScore.toStringAsFixed(1)}%',
                        icon: Icons.assessment_outlined,
                        iconColor: const Color(0xFFFF9500),
                        onTap: () => context.go(RouteNames.managerProjects),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _MiniStatCard(
                        label: 'Fully Inspected',
                        value: '${completionRate.toStringAsFixed(0)}%',
                        icon: Icons.check_circle_outline,
                        iconColor: const Color(0xFF34C759),
                        onTap: () => context.go(RouteNames.managerProjects),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                _SectionHeader(
                  title: 'Performance by Service Category',
                  icon: Icons.bar_chart_outlined,
                ),
                const SizedBox(height: 12),
                _ServicePerformanceCard(serviceAvgs: serviceAvgs),
                const SizedBox(height: 28),

                _SectionHeader(
                  title: 'Top Performing Sites',
                  icon: Icons.trending_up_outlined,
                  iconColor: const Color(0xFF34C759),
                ),
                const SizedBox(height: 12),
                if (topProjects.isEmpty)
                  const _EmptyState(message: 'No project data yet')
                else
                  ...topProjects.asMap().entries.map(
                    (e) => _ProjectListTile(
                      rank: e.key + 1,
                      project: e.value,
                      isTop: true,
                      onTap: () => context.push(
                        RouteNames.managerReport('${e.value['p_id']}'),
                      ),
                    ),
                  ),
                const SizedBox(height: 28),

                _SectionHeader(
                  title: 'Sites Needing Attention',
                  icon: Icons.warning_amber_outlined,
                  iconColor: const Color(0xFFFF3B30),
                ),
                const SizedBox(height: 12),
                if (bottomProjects.isEmpty)
                  const _EmptyState(message: 'All sites performing well')
                else
                  ...bottomProjects.asMap().entries.map(
                    (e) => _ProjectListTile(
                      rank: e.key + 1,
                      project: e.value,
                      isTop: false,
                      onTap: () => context.push(
                        RouteNames.managerReport('${e.value['p_id']}'),
                      ),
                    ),
                  ),
                const SizedBox(height: 28),

                if (incomplete.isNotEmpty) ...[
                  _SectionHeader(
                    title: 'Pending Inspections',
                    icon: Icons.pending_outlined,
                    iconColor: const Color(0xFFFF9500),
                  ),
                  const SizedBox(height: 12),
                  ...incomplete.map(
                    (p) => _IncompleteProjectTile(
                      project: p,
                      onTap: () => context.push(
                        RouteNames.managerReport('${p['p_id']}'),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: Colors.redAccent.withOpacity(0.6),
              ),
              const SizedBox(height: 12),
              Text(
                'Failed to load dashboard',
                style: AppTextStyles.sectionTitle,
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: AppTextStyles.secondary,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Hero Performance Card ────────────────────────────────────────────────────

class _HeroPerformanceCard extends StatelessWidget {
  const _HeroPerformanceCard({
    required this.score,
    required this.totalProjects,
    required this.totalSupervisors,
    this.onTap,
  });

  final double score;
  final int totalProjects;
  final int totalSupervisors;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final grade = _getGrade(score);
    final gradeColor = _getGradeColor(score);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF2C5F9E), Color(0xFF4A90D9)],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4A90D9).withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.verified_outlined,
                  color: Colors.white70,
                  size: 18,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Overall Inspection Performance',
                    style: AppTextStyles.secondary.copyWith(
                      color: Colors.white70,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: gradeColor.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: gradeColor.withOpacity(0.6),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    grade,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              '${score.toStringAsFixed(1)}%',
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: -1,
              ),
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: score / 100,
                minHeight: 6,
                backgroundColor: Colors.white.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation<Color>(gradeColor),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _HeroStat(label: 'Projects', value: '$totalProjects'),
                const SizedBox(width: 24),
                _HeroStat(label: 'Supervisors', value: '$totalSupervisors'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  const _HeroStat({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(color: Colors.white60),
        ),
      ],
    );
  }
}

// ─── Mini Stat Card ───────────────────────────────────────────────────────────

class _MiniStatCard extends StatelessWidget {
  const _MiniStatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
    this.onTap,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: AppTextStyles.caption,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Service Performance Card ─────────────────────────────────────────────────

class _ServicePerformanceCard extends StatelessWidget {
  const _ServicePerformanceCard({required this.serviceAvgs});
  final List<Map<String, dynamic>> serviceAvgs;

  @override
  Widget build(BuildContext context) {
    final serviceIcons = {
      'House Keeping': Icons.cleaning_services_outlined,
      'Pest Control': Icons.bug_report_outlined,
      'MEP': Icons.electrical_services_outlined,
    };

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: serviceAvgs.asMap().entries.map((e) {
          final service = e.value;
          final isLast = e.key == serviceAvgs.length - 1;
          final name = service['service_name'] as String? ?? 'Service';
          final rawScore = double.tryParse(service['average_score']?.toString() ?? '0') ?? 0.0;
          final score = rawScore.toDouble() * (rawScore <= 1 ? 100 : 1);
          final grade = _getGrade(score);
          final gradeColor = _getGradeColor(score);
          final icon =
              serviceIcons[name] ?? Icons.miscellaneous_services_outlined;

          return Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: gradeColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: gradeColor, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              name,
                              style: AppTextStyles.body.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '${score.toStringAsFixed(1)}%',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: gradeColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: score / 100,
                            minHeight: 6,
                            backgroundColor: const Color(0xFFF0F0F0),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              gradeColor,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          grade,
                          style: AppTextStyles.caption.copyWith(
                            color: gradeColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (!isLast) ...[
                const SizedBox(height: 16),
                const Divider(height: 1, color: Color(0xFFF0F0F0)),
                const SizedBox(height: 16),
              ],
            ],
          );
        }).toList(),
      ),
    );
  }
}

// ─── Project List Tile ────────────────────────────────────────────────────────

class _ProjectListTile extends StatelessWidget {
  const _ProjectListTile({
    required this.rank,
    required this.project,
    required this.isTop,
    this.onTap,
  });

  final int rank;
  final Map<String, dynamic> project;
  final bool isTop;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final name = project['name'] as String? ?? 'Project';
    final rawProgress =
        project['progress'] ??
        project['Progresss'] ??
        project['progresss'] ??
        0;
    final progress = double.tryParse(rawProgress.toString()) ?? 0.0;
    final rawScore = project['average_score'];
    final score = rawScore != null
        ? (double.tryParse(rawScore.toString()) ?? 0.0) *
              ((double.tryParse(rawScore.toString()) ?? 0.0) <= 1 ? 100 : 1)
        : progress;
    final grade = _getGrade(score);
    final gradeColor = _getGradeColor(score);
    final rankColor = isTop ? const Color(0xFF34C759) : const Color(0xFFFF3B30);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: rankColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  '$rank',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: rankColor,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress / 100,
                      minHeight: 4,
                      backgroundColor: const Color(0xFFF0F0F0),
                      valueColor: AlwaysStoppedAnimation<Color>(gradeColor),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${progress.toStringAsFixed(0)}% complete',
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: gradeColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                grade,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: gradeColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Incomplete Project Tile ──────────────────────────────────────────────────

class _IncompleteProjectTile extends StatelessWidget {
  const _IncompleteProjectTile({required this.project, this.onTap});
  final Map<String, dynamic> project;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final name = project['name'] as String? ?? 'Project';
    final rawProgress =
        project['progress'] ??
        project['Progresss'] ??
        project['progresss'] ??
        0;
    final progress = double.tryParse(rawProgress.toString()) ?? 0.0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFFF9500).withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFFF9500).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.pending_outlined,
                color: Color(0xFFFF9500),
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${progress.toStringAsFixed(0)}% completed',
                    style: AppTextStyles.caption.copyWith(
                      color: const Color(0xFFFF9500),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: Color(0xFF8E8E93),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Section Header ───────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.icon,
    this.iconColor,
  });
  final String title;
  final IconData icon;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final color = iconColor ?? AppColors.primary;
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 8),
        Text(title, style: AppTextStyles.sectionTitle),
      ],
    );
  }
}

// ─── Empty State ──────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(child: Text(message, style: AppTextStyles.secondary)),
    );
  }
}

// ─── Grade Helpers ────────────────────────────────────────────────────────────

String _getGrade(double score) {
  if (score >= 90) return 'Excellent';
  if (score >= 80) return 'Good';
  if (score >= 75) return 'Acceptable';
  return 'Needs Improvement';
}

Color _getGradeColor(double score) {
  if (score >= 90) return const Color(0xFF34C759);
  if (score >= 80) return const Color(0xFF4A90D9);
  if (score >= 75) return const Color(0xFFFF9500);
  return const Color(0xFFFF3B30);
}

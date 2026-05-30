class InspectionService {
  const InspectionService({
    required this.id,
    required this.name,
    required this.rating,
    required this.progress,
    required this.projectId,
  });

  final String id;
  final String name;
  final double rating;
  final int progress;
  final String projectId;
}

class ChecklistItem {
  const ChecklistItem({
    required this.id,
    required this.itemNumber,
    required this.textAr,
    required this.textEn,
    this.score,
    this.comment,
  });

  final String id;
  final int itemNumber;
  final String textAr;
  final String textEn;
  final int? score;
  final String? comment;

  ChecklistItem copyWith({
    int? score,
    bool clearScore = false,
    String? comment,
  }) {
    return ChecklistItem(
      id: id,
      itemNumber: itemNumber,
      textAr: textAr,
      textEn: textEn,
      score: clearScore ? null : (score ?? this.score),
      comment: comment ?? this.comment,
    );
  }
}

class ProjectStats {
  const ProjectStats({
    required this.projectId,
    required this.projectName,
    required this.overallProgress,
    required this.overallScore,
    required this.grade,
    required this.services,
  });

  final String projectId;
  final String projectName;
  final int overallProgress;
  final double overallScore;
  final String grade;
  final List<ServiceStats> services;
}

class ServiceStats {
  const ServiceStats({
    required this.id,
    required this.name,
    required this.rating,
    required this.progress,
    required this.grade,
  });

  final String id;
  final String name;
  final double rating;
  final int progress;
  final String grade;
}

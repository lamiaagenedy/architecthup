import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/quality_checklist_items.dart';

@immutable
class InspectionItemState {
  const InspectionItemState({
    this.rating,
    this.comment = '',
    this.isCommentExpanded = false,
  });

  final int? rating;
  final String comment;
  final bool isCommentExpanded;

  InspectionItemState copyWith({
    int? rating,
    bool clearRating = false,
    String? comment,
    bool? isCommentExpanded,
  }) {
    return InspectionItemState(
      rating: clearRating ? null : (rating ?? this.rating),
      comment: comment ?? this.comment,
      isCommentExpanded: isCommentExpanded ?? this.isCommentExpanded,
    );
  }
}

@immutable
class InspectionChecklistState {
  const InspectionChecklistState({required this.entries});

  final Map<InspectionCategoryKey, List<InspectionItemState>> entries;

  factory InspectionChecklistState.initial() {
    return InspectionChecklistState(
      entries: {
        InspectionCategoryKey.housekeepingIndoor: List.generate(
          QualityChecklistItems.housekeepingIndoor.length,
          (_) => const InspectionItemState(),
        ),
        InspectionCategoryKey.housekeepingOutdoor: List.generate(
          QualityChecklistItems.housekeepingOutdoor.length,
          (_) => const InspectionItemState(),
        ),
        InspectionCategoryKey.maintenance: List.generate(
          QualityChecklistItems.maintenance.length,
          (_) => const InspectionItemState(),
        ),
        InspectionCategoryKey.security: List.generate(
          QualityChecklistItems.security.length,
          (_) => const InspectionItemState(),
        ),
        InspectionCategoryKey.landscape: List.generate(
          QualityChecklistItems.landscape.length,
          (_) => const InspectionItemState(),
        ),
      },
    );
  }

  InspectionChecklistState copyWith({
    Map<InspectionCategoryKey, List<InspectionItemState>>? entries,
  }) {
    return InspectionChecklistState(entries: entries ?? this.entries);
  }
}

class InspectionChecklistNotifier
    extends StateNotifier<InspectionChecklistState> {
  InspectionChecklistNotifier() : super(InspectionChecklistState.initial());

  void toggleRating(InspectionCategoryKey category, int itemIndex, int rating) {
    final current = _item(category, itemIndex);
    final next = current.rating == rating
        ? current.copyWith(clearRating: true)
        : current.copyWith(rating: rating);

    _updateItem(category, itemIndex, next);
  }

  void toggleCommentExpanded(InspectionCategoryKey category, int itemIndex) {
    final current = _item(category, itemIndex);
    _updateItem(
      category,
      itemIndex,
      current.copyWith(isCommentExpanded: !current.isCommentExpanded),
    );
  }

  void updateComment(
    InspectionCategoryKey category,
    int itemIndex,
    String value,
  ) {
    final current = _item(category, itemIndex);
    _updateItem(category, itemIndex, current.copyWith(comment: value));
  }

  double categoryAverage(InspectionCategoryKey category) {
    return _averageFromEntries(
      state.entries[category] ?? const <InspectionItemState>[],
    );
  }

  double overallAverage() {
    final combined = state.entries.values.expand((items) => items).toList();
    return _averageFromEntries(combined);
  }

  InspectionItemState _item(InspectionCategoryKey category, int index) {
    final items = state.entries[category] ?? const <InspectionItemState>[];
    return items[index];
  }

  void _updateItem(
    InspectionCategoryKey category,
    int index,
    InspectionItemState next,
  ) {
    final currentEntries = state.entries;
    final List<InspectionItemState> items = [
      ...(currentEntries[category] ?? const <InspectionItemState>[]),
    ];
    items[index] = next;

    state = state.copyWith(entries: {...currentEntries, category: items});
  }

  double _averageFromEntries(List<InspectionItemState> entries) {
    final rated = entries.map((item) => item.rating).whereType<int>().toList();
    if (rated.isEmpty) {
      return 0;
    }

    final total = rated.reduce((sum, score) => sum + score);
    return total / rated.length;
  }
}

final inspectionChecklistProvider = StateNotifierProvider.autoDispose
    .family<InspectionChecklistNotifier, InspectionChecklistState, String>(
      (ref, projectId) => InspectionChecklistNotifier(),
    );

/// Empty category means all services, including legacy uncategorized entries.
const uncategorizedCompetitionId = '__uncategorized__';

List<Map<String, String>> competitionServicesForCategory(
  Iterable<Map<String, String>> services,
  String categoryId,
) => services
    .where((service) {
      if (service['type'] != 'complink') return false;
      if (categoryId.isEmpty) return true;
      final assigned = service['competitionCategoryId'] ?? '';
      return categoryId == uncategorizedCompetitionId
          ? assigned.isEmpty
          : assigned == categoryId;
    })
    .toList(growable: false);

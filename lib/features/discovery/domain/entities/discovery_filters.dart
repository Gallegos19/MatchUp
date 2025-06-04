class DiscoveryFilters {
  final int? minAge;
  final int? maxAge;
  final String? gender;
  final String? careers;
  final String? semesters;
  final String? campuses;
  final double? maxDistance;
  final List<String>? interests;

  DiscoveryFilters(
      {this.minAge,
      this.maxAge,
      this.gender,
      this.careers,
      this.semesters,
      this.campuses,
      this.maxDistance,
      this.interests});
}

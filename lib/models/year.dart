class Year {
  final int year;
  final int total;

  const Year({
    required this.year,
    required this.total,
  });

  factory Year.fromJson(Map<String, dynamic> json) {
    return Year(
      year: int.parse(json['year']),
      total: json['total'],
    );
  }
}

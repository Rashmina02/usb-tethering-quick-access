class Category {
  final String name;
  final double budget;
  final String color;

  Category({
    required this.name,
    this.budget = 0,
    this.color = '#4285F4',
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'budget': budget,
      'color': color,
    };
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      name: map['name'],
      budget: map['budget']?.toDouble() ?? 0,
      color: map['color'] ?? '#4285F4',
    );
  }
}
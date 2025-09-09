class Expense {
  final String id;
  final double amount;
  final String category;
  final String description;
  final DateTime date;
  final String type; // 'expense' or 'income'

  Expense({
    required this.id,
    required this.amount,
    required this.category,
    required this.description,
    required this.date,
    required this.type,
  });

  // Convert to Map for JSON storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'category': category,
      'description': description,
      'date': date.toIso8601String(),
      'type': type,
    };
  }

  // Create Expense from Map
  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'],
      amount: map['amount'].toDouble(),
      category: map['category'],
      description: map['description'],
      date: DateTime.parse(map['date']),
      type: map['type'],
    );
  }

  // Helper method to generate ID
  static String generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }
}

class DebtModel {
  final String id;
  final String title;
  final DateTime date;
  final double amount;
  final String currency;
  final int delayDays;
  final bool isOverdue;

  const DebtModel({
    required this.id,
    required this.title,
    required this.date,
    required this.amount,
    required this.currency,
    required this.delayDays,
    this.isOverdue = false,
  });
}

class TransactionModel {
  final String id;
  final String title;
  final DateTime date;
  final double amount;
  final double balanceAfter;
  final bool isIncome;
  final String currency;

  const TransactionModel({
    required this.id,
    required this.title,
    required this.date,
    required this.amount,
    required this.balanceAfter,
    required this.isIncome,
    required this.currency,
  });

  TransactionModel copyWith({
    String? id,
    String? title,
    DateTime? date,
    double? amount,
    double? balanceAfter,
    bool? isIncome,
    String? currency,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      title: title ?? this.title,
      date: date ?? this.date,
      amount: amount ?? this.amount,
      balanceAfter: balanceAfter ?? this.balanceAfter,
      isIncome: isIncome ?? this.isIncome,
      currency: currency ?? this.currency,
    );
  }
}

class MonthlyStat {
  final String month;
  final double income;
  final double expense;

  const MonthlyStat({
    required this.month,
    required this.income,
    required this.expense,
  });
}

import 'package:equatable/equatable.dart';

class PaymentPartnerModel extends Equatable {
  final String id;
  final String name;
  final String? phone;

  const PaymentPartnerModel({
    required this.id,
    required this.name,
    this.phone,
  });

  factory PaymentPartnerModel.fromJson(Map<String, dynamic> json) {
    return PaymentPartnerModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      phone: json['phone']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
    };
  }

  PaymentPartnerModel copyWith({
    String? id,
    String? name,
    String? phone,
  }) {
    return PaymentPartnerModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
    );
  }

  static List<PaymentPartnerModel> get mockList => [
        const PaymentPartnerModel(
          id: '1',
          name: 'Aziz Toshmatov',
          phone: '+998 90 123 45 67',
        ),
        const PaymentPartnerModel(
          id: '2',
          name: 'Nodira Karimova',
          phone: '+998 91 234 56 78',
        ),
        const PaymentPartnerModel(
          id: '3',
          name: 'Sardor Alimov',
          phone: '+998 93 345 67 89',
        ),
        const PaymentPartnerModel(
          id: '4',
          name: 'Malika Rashidova',
          phone: '+998 94 456 78 90',
        ),
        const PaymentPartnerModel(
          id: '5',
          name: 'Javohir Nurmatov',
          phone: '+998 95 567 89 01',
        ),
      ];

  @override
  List<Object?> get props => [id, name, phone];
}

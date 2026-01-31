class SMSPricingResponse {
  final bool status;
  final List<SMSPricingModel> result;

  SMSPricingResponse({
    required this.status,
    required this.result,
  });

  factory SMSPricingResponse.fromJson(Map<String, dynamic> json) {
    return SMSPricingResponse(
      status: json['status'] ?? false,
      result: (json['result'] as List? ?? [])
          .map((e) => SMSPricingModel.fromJson(e))
          .toList(),
    );
  }
}

class SMSPricingModel {
  final int id;
  final String name;
  final String displayName;
  final String description;
  final String price;
  final String formattedPrice;
  final int smsCount;

  SMSPricingModel({
    required this.id,
    required this.name,
    required this.displayName,
    required this.description,
    required this.price,
    required this.formattedPrice,
    required this.smsCount,
  });

  factory SMSPricingModel.fromJson(Map<String, dynamic> json) {
    return SMSPricingModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      displayName: json['display_name'] ?? '',
      description: json['description'] ?? '',
      price: json['price']?.toString() ?? '0',
      formattedPrice: json['formatted_price'] ?? '',
      smsCount: json['sms_count'] ?? 0,
    );
  }
}

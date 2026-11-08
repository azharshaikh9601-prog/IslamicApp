class PaymentConfigModel {
  final String id;
  final String payeeName;
  final String upiId;
  final String qrImageUrl;
  final String gatewayProvider;
  final String gatewayKeyId;
  final String currency;
  final bool isActive;

  const PaymentConfigModel({
    this.id = 'default_payment',
    this.payeeName = 'MOHAMMED HASNAIN',
    this.upiId = '9373756095@ybl',
    this.qrImageUrl = 'assets/images/phonepe-qr.jpg',
    this.gatewayProvider = 'UPI_DIRECT',
    this.gatewayKeyId = '',
    this.currency = 'INR',
    this.isActive = true,
  });

  PaymentConfigModel copyWith({
    String? id,
    String? payeeName,
    String? upiId,
    String? qrImageUrl,
    String? gatewayProvider,
    String? gatewayKeyId,
    String? currency,
    bool? isActive,
  }) {
    return PaymentConfigModel(
      id: id ?? this.id,
      payeeName: payeeName ?? this.payeeName,
      upiId: upiId ?? this.upiId,
      qrImageUrl: qrImageUrl ?? this.qrImageUrl,
      gatewayProvider: gatewayProvider ?? this.gatewayProvider,
      gatewayKeyId: gatewayKeyId ?? this.gatewayKeyId,
      currency: currency ?? this.currency,
      isActive: isActive ?? this.isActive,
    );
  }

  factory PaymentConfigModel.fromJson(Map<String, dynamic> json) {
    return PaymentConfigModel(
      id: json['id'] as String? ?? 'default_payment',
      payeeName: json['payeeName'] as String? ?? 'MOHAMMED HASNAIN',
      upiId: json['upiId'] as String? ?? '9373756095@ybl',
      qrImageUrl: json['qrImageUrl'] as String? ?? 'assets/images/phonepe-qr.jpg',
      gatewayProvider: json['gatewayProvider'] as String? ?? 'UPI_DIRECT',
      gatewayKeyId: json['gatewayKeyId'] as String? ?? '',
      currency: json['currency'] as String? ?? 'INR',
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'payeeName': payeeName,
    'upiId': upiId,
    'qrImageUrl': qrImageUrl,
    'gatewayProvider': gatewayProvider,
    'gatewayKeyId': gatewayKeyId,
    'currency': currency,
    'isActive': isActive,
  };
}


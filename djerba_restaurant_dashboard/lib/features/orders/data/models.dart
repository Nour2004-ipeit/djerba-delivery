class OrderModel {
  final String id;
  final String orderNumber;
  final String status;
  final double totalAmount;
  final String deliveryAddress;
  final DateTime createdAt;
  final String clientName;
  final String itemsSummary;

  OrderModel({
    required this.id,
    required this.orderNumber,
    required this.status,
    required this.totalAmount,
    required this.deliveryAddress,
    required this.createdAt,
    required this.clientName,
    required this.itemsSummary,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    String clientName = 'Client inconnu';
    if (json['client'] != null && json['client']['name'] != null) {
      clientName = json['client']['name'];
    }

    String itemsSummary = 'Produits...';
    if (json['items'] != null && json['items'] is List) {
      itemsSummary = (json['items'] as List)
          .map((item) => "${item['quantity']}x ${item['productNameSnapshot']}")
          .join(', ');
    }

    return OrderModel(
      id: json['id'] as String,
      orderNumber: json['orderNumber'] as String? ?? json['order_number'] as String? ?? 'CMD-???',
      status: json['status'] as String,
      totalAmount: (json['subtotal'] != null ? json['subtotal'] as num : json['totalAmount'] as num).toDouble(),
      deliveryAddress: json['deliveryAddress'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      clientName: clientName,
      itemsSummary: itemsSummary,
    );
  }
}

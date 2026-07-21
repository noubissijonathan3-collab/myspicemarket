class CartItem {
  final String? id;
  final String productId;
  final String name;
  final String image;
  final double price;
  final String unit;
  final String type;
  int quantity;

  CartItem({
    this.id,
    required this.productId,
    required this.name,
    this.image = '',
    required this.price,
    this.unit = 'piece',
    this.type = 'grocery',
    this.quantity = 1,
  });

  double get totalPrice => price * quantity;

  factory CartItem.fromJson(Map<String, dynamic> json) {
    final product = json['product'] is Map ? json['product'] : null;
    return CartItem(
      id: json['_id'] ?? json['id'] ?? '',
      productId: product?['_id'] ?? json['productId'] ?? json['product'] ?? '',
      name: json['name'] ?? product?['name'] ?? '',
      image: json['image'] ?? product?['image'] ?? '',
      price: (json['price'] ?? product?['price'] ?? 0).toDouble(),
      unit: json['unit'] ?? product?['unit'] ?? 'piece',
      type: json['type'] ?? product?['type'] ?? 'grocery',
      quantity: json['quantity'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() => {
    'productId': productId,
    'name': name,
    'image': image,
    'price': price,
    'unit': unit,
    'type': type,
    'quantity': quantity,
  };
}

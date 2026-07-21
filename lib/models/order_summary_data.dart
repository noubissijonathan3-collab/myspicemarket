import 'product.dart';
import 'meal_ingredient.dart';
import 'grocery_product.dart';

class OrderItem {
  final String id;
  final String name;
  final String image;
  final int price;
  final int quantity;
  final String unit;
  final String type;

  OrderItem({
    required this.id,
    required this.name,
    this.image = '',
    required this.price,
    required this.quantity,
    this.unit = 'piece',
    this.type = 'ingredient',
  });
}

class OrderSummaryData {
  final Product meal;
  final List<OrderItem> items;
  final int deliveryFee;
  final int subtotal;
  final int total;

  OrderSummaryData({
    required this.meal,
    required this.items,
    required this.deliveryFee,
    required this.subtotal,
    required this.total,
  });

  static OrderSummaryData fromMealDetails({
    required Product meal,
    required List<MealIngredient> ingredients,
    required Map<String, int> ingredientQtys,
    required Set<String> removedIds,
    required List<GroceryProduct> extraItems,
    required Map<String, int> extraQtys,
    required int deliveryFee,
  }) {
    final items = <OrderItem>[];

    for (final ing in ingredients) {
      if (removedIds.contains(ing.foodstuffId)) continue;
      final qty = ingredientQtys[ing.foodstuffId] ?? ing.quantity.ceil();
      items.add(OrderItem(
        id: ing.foodstuffId,
        name: ing.foodstuffName,
        image: ing.foodstuffImage,
        price: ing.foodstuffPrice,
        quantity: qty,
        unit: ing.foodstuffUnit,
        type: 'ingredient',
      ));
    }

    for (final item in extraItems) {
      final qty = extraQtys[item.id] ?? 1;
      items.add(OrderItem(
        id: item.id,
        name: item.name,
        image: item.image,
        price: item.price,
        quantity: qty,
        unit: item.unit,
        type: 'extra',
      ));
    }

    final subtotal = items.fold(0, (sum, i) => sum + i.price * i.quantity);
    final total = subtotal + deliveryFee;

    return OrderSummaryData(
      meal: meal,
      items: items,
      deliveryFee: deliveryFee,
      subtotal: subtotal,
      total: total,
    );
  }
}

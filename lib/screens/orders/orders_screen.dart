import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/order_service.dart';
import '../../utils/colors.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/empty_widget.dart';
import '../../widgets/common/error_widget.dart';
import '../auth/login_screen.dart';
import 'order_tracking_screen.dart';
import 'live_tracking_screen.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  late Future<List<Map<String, dynamic>>> _ordersFuture;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final loggedIn = await AuthService.isLoggedIn();
    if (!mounted) return;
    if (!loggedIn) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
      return;
    }
    setState(() {
      _ordersFuture = OrderService.fetchOrders();
    });
  }

  void _refresh() {
    setState(() {
      _ordersFuture = OrderService.fetchOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('My Orders')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _ordersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingWidget();
          }
          if (snapshot.hasError) {
            return ErrorWidgetCustom(
              message: snapshot.error.toString(),
              onRetry: _refresh,
            );
          }
          final orders = snapshot.data ?? [];
          if (orders.isEmpty) {
            return const EmptyWidget(title: 'No orders yet', subtitle: 'Your orders will appear here');
          }
          return RefreshIndicator(
            onRefresh: () async => _refresh,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: orders.length,
              itemBuilder: (_, i) {
                final order = orders[i];
                final status = order['status'] ?? 'Pending';
                final isActive = status == 'Out for Delivery' || status == 'On Route';
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => OrderTrackingScreen(orderId: order['_id'] ?? ''))),
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _statusColor(status).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.receipt_long, color: _statusColor(status)),
                    ),
                    title: Text('Order #${order['_id'].toString().substring(0, 8)}'),
                    subtitle: Text('$status — ${order['total'] ?? 0} FCFA'),
                    trailing: isActive
                        ? TextButton.icon(
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => LiveTrackingScreen(orderId: order['_id'] ?? ''),
                              ),
                            ),
                            icon: const Icon(Icons.location_on, size: 16, color: Colors.teal),
                            label: const Text('Track', style: TextStyle(color: Colors.teal, fontWeight: FontWeight.w600)),
                          )
                        : Text(_formatDate(order['createdAt']), style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant)),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Delivered': return Colors.green;
      case 'Cancelled': return Colors.red;
      case 'Pending': return Colors.orange;
      case 'Confirmed': return Colors.blue;
      case 'Preparing': return Colors.deepPurple;
      case 'Out for Delivery': return Colors.teal;
      default: return Colors.grey;
    }
  }

  String _formatDate(dynamic date) {
    if (date == null) return '';
    try {
      final dt = DateTime.parse(date.toString());
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return '';
    }
  }
}

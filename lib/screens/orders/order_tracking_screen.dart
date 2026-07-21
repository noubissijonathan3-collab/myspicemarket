import 'package:flutter/material.dart';
import '../../services/chat_service.dart';
import '../../services/order_service.dart';
import '../../utils/colors.dart';
import '../chat/chat_screen.dart';
import 'live_tracking_screen.dart';

class OrderTrackingScreen extends StatefulWidget {
  final String orderId;

  const OrderTrackingScreen({super.key, required this.orderId});

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  Map<String, dynamic>? _order;
  bool _isLoading = true;
  ChatRoomData? _chatRoom;

  static const _steps = [
    'Order Received',
    'Order Confirmed',
    'Ingredients Being Prepared',
    'Packaging Ingredients',
    'Quality Check',
    'Ready for Dispatch',
    'Rider Assigned',
    'Out for Delivery',
    'Delivered',
  ];

  @override
  void initState() {
    super.initState();
    _loadOrder();
  }

  Future<void> _loadOrder() async {
    try {
      final data = await OrderService.fetchOrderById(widget.orderId);
      final order = data['order'] as Map<String, dynamic>? ?? data;
      if (!mounted) return;
      setState(() {
        _order = order;
        _isLoading = false;
      });
      _loadChatRoom();
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadChatRoom() async {
    try {
      final room = await ChatService.getChatRoom(widget.orderId);
      if (!mounted) return;
      setState(() => _chatRoom = room);
    } catch (_) {}
  }

  int _currentStepIndex() {
    final status = _order?['status'] ?? 'Pending';
    switch (status) {
      case 'Pending': return 0;
      case 'Confirmed': return 1;
      case 'Preparing': return 2;
      case 'Out for Delivery': return 7;
      case 'Delivered': return 8;
      case 'Cancelled': return -1;
      default: return 0;
    }
  }

  bool _canChat() {
    final status = _order?['status'] ?? '';
    return status != 'Delivered' && status != 'Cancelled';
  }

  Future<void> _openChat() async {
    await ChatService.connect();
    if (_chatRoom == null) {
      try {
        final room = await ChatService.createChatRoom(widget.orderId);
        if (!mounted) return;
        setState(() => _chatRoom = room);
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e')),
        );
        return;
      }
    }
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatScreen(
          chatRoomId: _chatRoom!.id,
          orderId: widget.orderId,
          agentName: _chatRoom!.agentName.isNotEmpty ? _chatRoom!.agentName : 'Preparation Agent',
          agentAvatar: _chatRoom!.agentAvatar,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Order #${widget.orderId.substring(0, 8)}'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _order == null
              ? const Center(child: Text('Order not found'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildOrderInfo(),
                      const SizedBox(height: 20),
                      _buildProgressTimeline(),
                      if (_isTrackable()) ...[
                        const SizedBox(height: 16),
                        _buildTrackLiveButton(),
                      ],
                      const SizedBox(height: 20),
                      _buildAgentCard(),
                    ],
                  ),
                ),
    );
  }

  Widget _buildOrderInfo() {
    final delivery = _order!['delivery'] as Map<String, dynamic>? ?? {};
    final total = _order!['total'] ?? 0;
    final date = _order!['createdAt'] ?? '';

    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Order Status', style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
                Chip(
                  label: Text(_order!['status'] ?? 'Pending', style: const TextStyle(fontSize: 12, color: Colors.white)),
                  backgroundColor: _statusColor(_order!['status'] ?? 'Pending'),
                  padding: EdgeInsets.zero,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ],
            ),
            const SizedBox(height: 12),
            _infoRow(Icons.receipt_long, 'Order Number', '#${widget.orderId.substring(0, 8)}'),
            _infoRow(Icons.calendar_today, 'Order Date', _formatDate(date)),
            _infoRow(Icons.location_on, 'Delivery Address', delivery['address'] ?? 'Not set'),
            _infoRow(Icons.phone, 'Phone', delivery['phone'] ?? 'Not set'),
            _infoRow(Icons.payments, 'Total', '$total FCFA'),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 8),
          Text('$label: ', style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }

  Widget _buildProgressTimeline() {
    final current = _currentStepIndex();
    final isCancelled = current == -1;

    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Order Progress', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.onSurface)),
            const SizedBox(height: 16),
            if (isCancelled)
              const Center(child: Text('Order Cancelled', style: TextStyle(color: Colors.red, fontSize: 16)))
            else
              ...List.generate(_steps.length, (i) {
                final completed = i <= current;
                final isLast = i == _steps.length - 1;
                return _buildStep(i, _steps[i], completed, isLast, current == i);
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(int index, String label, bool completed, bool isLast, bool isCurrent) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 24,
            child: Column(
              children: [
                Container(
                  width: 20, height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: completed ? AppColors.primary : Colors.grey.shade300,
                  ),
                  child: completed
                      ? const Icon(Icons.check, size: 12, color: Colors.white)
                      : Center(child: Container(width: 8, height: 8, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.grey.shade400))),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(width: 2, color: completed ? AppColors.primary : Colors.grey.shade300),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 24),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isCurrent ? FontWeight.w600 : FontWeight.normal,
                color: completed ? AppColors.onSurface : Colors.grey.shade500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _isTrackable() {
    final status = _order?['status'] ?? '';
    return status == 'Out for Delivery' || status == 'On Route';
  }

  Widget _buildTrackLiveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => LiveTrackingScreen(orderId: widget.orderId),
            ),
          );
        },
        icon: const Icon(Icons.map, size: 18),
        label: const Text('Track Delivery Live'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _buildAgentCard() {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Your Preparation Agent', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.onSurface)),
            const SizedBox(height: 12),
            Row(
              children: [
                CircleAvatar(radius: 24, backgroundColor: AppColors.primaryContainer,
                  child: const Icon(Icons.person, color: Colors.white)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Preparation Agent', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Container(width: 8, height: 8, decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.green)),
                          const SizedBox(width: 4),
                          const Text('Online', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.star, color: Colors.amber.shade600, size: 18),
                const Text('4.9', style: TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _canChat() ? _openChat : null,
                icon: const Icon(Icons.chat_bubble_outline, size: 18),
                label: Text(_canChat() ? 'Chat Now' : 'Chat Unavailable'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _canChat() ? AppColors.primary : Colors.grey,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Delivered': return Colors.green;
      case 'Cancelled': return Colors.red;
      case 'Pending': return Colors.orange;
      case 'Confirmed': return Colors.blue;
      case 'Preparing': return AppColors.primary;
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

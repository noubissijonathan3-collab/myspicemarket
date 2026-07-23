import 'package:flutter/material.dart';
import '../../services/chat_service.dart';
import '../../services/order_service.dart';
import '../../utils/colors.dart';
import '../call_screen.dart';
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
  ChatRoomData? _prepChatRoom;
  ChatRoomData? _deliveryChatRoom;

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
      _loadChatRooms();
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadChatRooms() async {
    try {
      final prepRoom = await ChatService.getChatRoom(widget.orderId, agentType: 'preparation');
      final deliveryRoom = await ChatService.getChatRoom(widget.orderId, agentType: 'delivery');
      if (!mounted) return;
      setState(() {
        _prepChatRoom = prepRoom;
        _deliveryChatRoom = deliveryRoom;
      });
    } catch (_) {}
  }

  String get _orderStatus => _order?['status'] ?? 'Pending';
  String? get _preparationAgentId => _order?['preparationAgent'] is Map
      ? _order!['preparationAgent']['_id'] ?? _order!['preparationAgent']['id']
      : _order?['preparationAgent'];
  String? get _deliveryAgentId => _order?['deliveryAgent'] is Map
      ? _order!['deliveryAgent']['_id'] ?? _order!['deliveryAgent']['id']
      : _order?['deliveryAgent'];
  String get _preparationAgentName {
    if (_order?['preparationAgent'] is Map) {
      return _order!['preparationAgent']['fullName'] ?? 'Preparation Agent';
    }
    return 'Preparation Agent';
  }
  String get _deliveryAgentName {
    if (_order?['deliveryAgent'] is Map) {
      return _order!['deliveryAgent']['fullName'] ?? 'Delivery Agent';
    }
    return 'Delivery Agent';
  }

  int _currentStepIndex() {
    switch (_orderStatus) {
      case 'Pending': return 0;
      case 'Confirmed': return 1;
      case 'Preparing': return 2;
      case 'Out for Delivery': return 7;
      case 'Delivered': return 8;
      case 'Cancelled': return -1;
      default: return 0;
    }
  }

  bool get _isPrepChatActive {
    return _preparationAgentId != null &&
        (_orderStatus == 'Preparing' || _orderStatus == 'Ready' ||
         _orderStatus == 'Out for Delivery' || _orderStatus == 'On Route');
  }

  bool get _isDeliveryChatActive {
    return _deliveryAgentId != null &&
        (_orderStatus == 'Out for Delivery' || _orderStatus == 'On Route');
  }

  bool get _isPrepChatFrozen {
    return _preparationAgentId != null && (_orderStatus == 'Delivered' || _orderStatus == 'Cancelled');
  }

  bool get _isDeliveryChatFrozen {
    return _deliveryAgentId != null && (_orderStatus == 'Delivered' || _orderStatus == 'Cancelled');
  }

  bool _isTrackable() {
    return _orderStatus == 'Out for Delivery' || _orderStatus == 'On Route';
  }

  Future<void> _openPrepChat() async {
    await ChatService.connect();
    if (_prepChatRoom == null) {
      try {
        final room = await ChatService.createChatRoom(widget.orderId, agentType: 'preparation');
        if (!mounted) return;
        setState(() => _prepChatRoom = room);
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
        return;
      }
    }
    if (!mounted) return;
    final isFrozen = _isPrepChatFrozen;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatScreen(
          chatRoomId: _prepChatRoom!.id,
          orderId: widget.orderId,
          agentName: _prepChatRoom!.agentName.isNotEmpty ? _prepChatRoom!.agentName : _preparationAgentName,
          agentAvatar: _prepChatRoom!.agentAvatar,
          agentId: _preparationAgentId ?? '',
          isReadOnly: isFrozen,
        ),
      ),
    );
  }

  Future<void> _openDeliveryChat() async {
    await ChatService.connect();
    if (_deliveryChatRoom == null) {
      try {
        final room = await ChatService.createChatRoom(widget.orderId, agentType: 'delivery');
        if (!mounted) return;
        setState(() => _deliveryChatRoom = room);
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
        return;
      }
    }
    if (!mounted) return;
    final isFrozen = _isDeliveryChatFrozen;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatScreen(
          chatRoomId: _deliveryChatRoom!.id,
          orderId: widget.orderId,
          agentName: _deliveryChatRoom!.agentName.isNotEmpty ? _deliveryChatRoom!.agentName : _deliveryAgentName,
          agentAvatar: _deliveryChatRoom!.agentAvatar,
          agentId: _deliveryAgentId ?? '',
          isReadOnly: isFrozen,
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
                      if (_isPrepChatActive || _isPrepChatFrozen)
                        _buildAgentChatCard(
                          title: 'Preparation Agent',
                          agentName: _preparationAgentName,
                          agentId: _preparationAgentId,
                          isFrozen: _isPrepChatFrozen,
                          isActive: _isPrepChatActive,
                          onChat: _openPrepChat,
                          agentType: 'preparation',
                        ),
                      if (_isPrepChatActive || _isPrepChatFrozen)
                        const SizedBox(height: 12),
                      if (_isDeliveryChatActive || _isDeliveryChatFrozen)
                        _buildAgentChatCard(
                          title: 'Delivery Agent',
                          agentName: _deliveryAgentName,
                          agentId: _deliveryAgentId,
                          isFrozen: _isDeliveryChatFrozen,
                          isActive: _isDeliveryChatActive,
                          onChat: _openDeliveryChat,
                          agentType: 'delivery',
                        ),
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
                  label: Text(_orderStatus, style: const TextStyle(fontSize: 12, color: Colors.white)),
                  backgroundColor: _statusColor(_orderStatus),
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

  Widget _buildTrackLiveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => LiveTrackingScreen(orderId: widget.orderId)),
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

  Widget _buildAgentChatCard({
    required String title,
    required String agentName,
    required String? agentId,
    required bool isFrozen,
    required bool isActive,
    required VoidCallback onChat,
    required String agentType,
  }) {
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
              children: [
                Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.onSurface)),
                if (isFrozen) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(8)),
                    child: const Text('Closed', style: TextStyle(fontSize: 11, color: Colors.grey)),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.primaryContainer,
                  child: Icon(
                    agentType == 'preparation' ? Icons.kitchen : Icons.delivery_dining,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(agentName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isActive ? Colors.green : Colors.grey,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isActive ? 'Online' : (isFrozen ? 'Chat ended' : 'Offline'),
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: (isActive || isFrozen) ? onChat : null,
                    icon: Icon(Icons.chat_bubble_outline, size: 18, color: (isActive || isFrozen) ? Colors.white : Colors.grey),
                    label: Text(
                      isFrozen ? 'View Chat' : (isActive ? 'Chat Now' : 'Chat Unavailable'),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isFrozen
                          ? Colors.grey.shade400
                          : (isActive ? AppColors.primary : Colors.grey),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                if (agentId != null && agentId.isNotEmpty && isActive) ...[
                  const SizedBox(width: 8),
                  SizedBox(
                    height: 44,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CallScreen(
                              targetUserId: agentId,
                              targetName: agentName,
                              orderId: widget.orderId,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF198754),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Icon(Icons.phone, size: 18),
                    ),
                  ),
                ],
              ],
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

import 'package:flutter/material.dart';
import '../../models/order_summary_data.dart';
import '../../services/order_service.dart';
import '../../services/chat_service.dart';
import '../../utils/colors.dart';
import 'order_success_screen.dart';

class CheckoutScreen extends StatefulWidget {
  final OrderSummaryData data;

  const CheckoutScreen({super.key, required this.data});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _landmarkCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  String _paymentMethod = 'Cash on Delivery';
  bool _agreeToTerms = false;
  bool _isPlacing = false;

  final _paymentMethods = [
    'Cash on Delivery',
    'Mobile Money (MTN)',
    'Mobile Money (Orange)',
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _landmarkCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _placeOrder() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please agree to the terms'), behavior: SnackBarBehavior.floating),
      );
      return;
    }

    setState(() => _isPlacing = true);

    try {
      final items = widget.data.items.map((i) => {
        'foodstuffId': i.id,
        'quantity': i.quantity,
      }).toList();

      final result = await OrderService.createOrder(
        items: items,
        delivery: {
          'receiver': _nameCtrl.text.trim(),
          'phone': _phoneCtrl.text.trim(),
          'address': _addressCtrl.text.trim(),
          'landmark': _landmarkCtrl.text.trim(),
          'notes': _notesCtrl.text.trim(),
          'paymentMethod': _paymentMethod,
        },
      );

      final orderId = (result['order'] as Map<String, dynamic>?)?['_id'] as String? ?? '';

      await ChatService.connect();

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => OrderSuccessScreen(orderId: orderId),
        ),
        (route) => route.isFirst,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed: $e'), backgroundColor: Colors.red, behavior: SnackBarBehavior.floating),
      );
    } finally {
      if (mounted) setState(() => _isPlacing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildProgressIndicator(),
                  const SizedBox(height: 20),
                  _buildDeliverySection(),
                  const SizedBox(height: 16),
                  _buildPaymentSection(),
                  const SizedBox(height: 16),
                  _buildReviewSection(),
                  const SizedBox(height: 16),
                  _buildTermsSection(),
                ],
              ),
            ),
          ),
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Row(
      children: [
        _step(1, 'Delivery', true),
        _stepLine(true),
        _step(2, 'Payment', true),
        _stepLine(true),
        _step(3, 'Review', true),
        _stepLine(true),
        _step(4, 'Confirm', true),
      ],
    );
  }

  Widget _step(int number, String label, bool active) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 28, height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: active ? AppColors.primary : Colors.grey.shade300,
            ),
            child: Center(child: Text('$number', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: active ? Colors.white : Colors.grey.shade600))),
          ),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 10, color: active ? AppColors.primary : Colors.grey.shade500)),
        ],
      ),
    );
  }

  Widget _stepLine(bool active) {
    return Container(height: 2, width: 24, color: active ? AppColors.primary : Colors.grey.shade300);
  }

  Widget _buildSectionCard(Widget child) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: child,
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.onSurface)),
      ],
    );
  }

  Widget _buildDeliverySection() {
    return _buildSectionCard(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Delivery Details', Icons.location_on),
          const SizedBox(height: 16),
          TextFormField(
            controller: _nameCtrl,
            decoration: const InputDecoration(labelText: 'Recipient Name', prefixIcon: Icon(Icons.person_outline)),
            validator: (v) => v == null || v.trim().isEmpty ? 'Name is required' : null,
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _phoneCtrl,
            decoration: const InputDecoration(labelText: 'Phone Number', prefixIcon: Icon(Icons.phone)),
            keyboardType: TextInputType.phone,
            validator: (v) => v == null || v.trim().isEmpty ? 'Phone is required' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _addressCtrl,
            decoration: const InputDecoration(labelText: 'Delivery Address', prefixIcon: Icon(Icons.home_outlined)),
            validator: (v) => v == null || v.trim().isEmpty ? 'Address is required' : null,
            textCapitalization: TextCapitalization.sentences,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _landmarkCtrl,
            decoration: const InputDecoration(labelText: 'Landmark (optional)', prefixIcon: Icon(Icons.flag_outlined)),
            textCapitalization: TextCapitalization.sentences,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _notesCtrl,
            decoration: const InputDecoration(labelText: 'Delivery Instructions (optional)', prefixIcon: Icon(Icons.notes)),
            maxLines: 2,
            textCapitalization: TextCapitalization.sentences,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSection() {
    return _buildSectionCard(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Payment Method', Icons.payments_outlined),
          const SizedBox(height: 12),
          RadioGroup<String>(
            groupValue: _paymentMethod,
            onChanged: (v) => setState(() => _paymentMethod = v!),
            child: Column(
              children: _paymentMethods.map((method) => RadioListTile<String>(
                value: method,
                title: Text(method, style: const TextStyle(fontSize: 14)),
                contentPadding: EdgeInsets.zero,
                dense: true,
              )).toList(),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, size: 18, color: AppColors.primary),
                const SizedBox(width: 8),
                Expanded(child: Text('Pay ${widget.data.total} FCFA on delivery', style: const TextStyle(fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.w500))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewSection() {
    return _buildSectionCard(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Order Review', Icons.receipt_long),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.restaurant, size: 16, color: AppColors.onSurfaceVariant),
              const SizedBox(width: 8),
              Text(widget.data.meal.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            ],
          ),
          const SizedBox(height: 8),
          ...widget.data.items.map((item) => Padding(
            padding: const EdgeInsets.only(left: 24, bottom: 4),
            child: Text('${item.name} × ${item.quantity} — ${item.price * item.quantity} FCFA',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade700)),
          )),
          const Divider(height: 20),
          _reviewRow('Subtotal', '${widget.data.subtotal} FCFA'),
          _reviewRow('Delivery Fee', '${widget.data.deliveryFee} FCFA'),
          _reviewRow('Payment', _paymentMethod, color: AppColors.primary),
          const Divider(height: 12),
          _reviewRow('Total', '${widget.data.total} FCFA', bold: true, color: AppColors.primary),
        ],
      ),
    );
  }

  Widget _reviewRow(String label, String value, {bool bold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: bold ? 15 : 13, fontWeight: bold ? FontWeight.w600 : FontWeight.normal, color: Colors.grey.shade700)),
          Text(value, style: TextStyle(fontSize: bold ? 15 : 13, fontWeight: FontWeight.w600, color: color ?? AppColors.onSurface)),
        ],
      ),
    );
  }

  Widget _buildTermsSection() {
    return _buildSectionCard(
      Row(
        children: [
          SizedBox(
            height: 24, width: 24,
            child: Checkbox(
              value: _agreeToTerms,
              onChanged: (v) => setState(() => _agreeToTerms = v ?? false),
              activeColor: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text('I agree to the terms and conditions and privacy policy',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade700)),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 12, 20, 12 + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 12, offset: const Offset(0, -4))],
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: _isPlacing ? null : _placeOrder,
          icon: _isPlacing
              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Icon(Icons.lock_outline, size: 20),
          label: Text(_isPlacing ? 'Placing Order...' : 'Place Order — ${widget.data.total} FCFA'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}

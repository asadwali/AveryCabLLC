import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/order.dart';
import '../providers/order_provider.dart';

class OrderFormScreen extends StatefulWidget {
  /// Pass an existing order to enter edit mode; null = add mode.
  final Order? existingOrder;

  const OrderFormScreen({super.key, this.existingOrder});

  @override
  State<OrderFormScreen> createState() => _OrderFormScreenState();
}

class _OrderFormScreenState extends State<OrderFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _timeCtrl;
  late final TextEditingController _dateCtrl;
  late final TextEditingController _pickCtrl;
  late final TextEditingController _dropCtrl;

  bool get _isEdit => widget.existingOrder != null;

  @override
  void initState() {
    super.initState();
    final o = widget.existingOrder;
    _nameCtrl  = TextEditingController(text: o?.name ?? '');
    _emailCtrl = TextEditingController(text: o?.email ?? '');
    _phoneCtrl = TextEditingController(text: o?.phone ?? '');
    _timeCtrl  = TextEditingController(text: o?.deliveryTime ?? '');
    _dateCtrl  = TextEditingController(text: o?.deliveryDate ?? '');
    _pickCtrl  = TextEditingController(text: o?.pickLocation ?? '');
    _dropCtrl  = TextEditingController(text: o?.dropOffLocation ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _timeCtrl.dispose();
    _dateCtrl.dispose();
    _pickCtrl.dispose();
    _dropCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      _dateCtrl.text =
          '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && mounted) {
      _timeCtrl.text = picked.format(context);
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final provider = context.read<OrderProvider>();

    if (_isEdit) {
      final updated = widget.existingOrder!.copyWith(
        name: _nameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        deliveryTime: _timeCtrl.text.trim(),
        deliveryDate: _dateCtrl.text.trim(),
        pickLocation: _pickCtrl.text.trim(),
        dropOffLocation: _dropCtrl.text.trim(),
      );
      provider.updateOrder(updated);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order updated successfully')),
      );
      Navigator.pop(context);
    } else {
      provider.addOrder(Order(
        name: _nameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        deliveryTime: _timeCtrl.text.trim(),
        deliveryDate: _dateCtrl.text.trim(),
        pickLocation: _pickCtrl.text.trim(),
        dropOffLocation: _dropCtrl.text.trim(),
        status: OrderStatus.pending,
      ));
      // Pop back to home (pops add-order which is pushed from MainScaffold)
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit Order' : 'New Order'),
        leading: const BackButton(),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _SectionHeader(icon: Icons.person_outline, label: 'Customer Info'),
                const SizedBox(height: 12),
                _buildField(
                  controller: _nameCtrl,
                  label: 'Full Name',
                  icon: Icons.person_outline,
                  validator: _required,
                ),
                const SizedBox(height: 14),
                _buildField(
                  controller: _emailCtrl,
                  label: 'Email',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Required';
                    if (!v.contains('@')) return 'Enter valid email';
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                _buildField(
                  controller: _phoneCtrl,
                  label: 'Phone',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  validator: _required,
                ),
                const SizedBox(height: 24),

                _SectionHeader(icon: Icons.schedule_outlined, label: 'Schedule'),
                const SizedBox(height: 12),
                // Time picker
                TextFormField(
                  controller: _timeCtrl,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Delivery Time',
                    prefixIcon: Icon(Icons.access_time_outlined),
                  ),
                  onTap: _pickTime,
                  validator: _required,
                ),
                const SizedBox(height: 14),
                // Date picker
                TextFormField(
                  controller: _dateCtrl,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Delivery Date',
                    prefixIcon: Icon(Icons.calendar_today_outlined),
                  ),
                  onTap: _pickDate,
                  validator: _required,
                ),
                const SizedBox(height: 24),

                _SectionHeader(icon: Icons.route_outlined, label: 'Route'),
                const SizedBox(height: 12),
                _buildField(
                  controller: _pickCtrl,
                  label: 'Pick-up Location',
                  icon: Icons.trip_origin_rounded,
                  iconColor: Colors.green.shade600,
                  validator: _required,
                ),
                const SizedBox(height: 14),
                _buildField(
                  controller: _dropCtrl,
                  label: 'Drop-off Location',
                  icon: Icons.location_on_rounded,
                  iconColor: Colors.red.shade400,
                  validator: _required,
                ),
                const SizedBox(height: 32),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: _submit,
                    icon: Icon(_isEdit ? Icons.save_outlined : Icons.add_rounded),
                    label: Text(_isEdit ? 'Save Changes' : 'Create Order'),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    Color? iconColor,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: iconColor),
      ),
      validator: validator,
    );
  }

  String? _required(String? v) =>
      (v == null || v.trim().isEmpty) ? 'This field is required' : null;
}

// ─────────────────────────────────────────────────────────────────────────────
// Section header widget
// ─────────────────────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String label;

  const _SectionHeader({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Row(
      children: [
        Icon(icon, size: 18, color: primary),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: primary,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(child: Divider(color: primary.withOpacity(0.2))),
      ],
    );
  }
}

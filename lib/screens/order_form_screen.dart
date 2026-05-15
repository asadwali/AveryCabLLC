import 'package:avery_cab_app/providers/auth_provider.dart';
import 'package:avery_cab_app/utils/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/order.dart' as OrderModel;
import '../providers/order_provider.dart';

class OrderFormScreen extends StatefulWidget {
  /// Pass an existing order to enter edit mode; null = add mode.
  final OrderModel.Order? existingOrder;

  const OrderFormScreen({super.key, this.existingOrder});

  @override
  State<OrderFormScreen> createState() => _OrderFormScreenState();
}

class _OrderFormScreenState extends State<OrderFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameCtrl;
  // late final TextEditingController _emailCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _timeCtrlLegA;
  late final TextEditingController _dateCtrlLegA;
  late final TextEditingController _pickCtrlLegA;
  late final TextEditingController _dropCtrlLegA;
  late final TextEditingController _timeCtrlLegB;
  late final TextEditingController _dateCtrlLegB;
  late final TextEditingController _pickCtrlLegB;
  late final TextEditingController _dropCtrlLegB;

  List<Map<String, dynamic>> users = [];
  String? userId;

  bool get _isEdit => widget.existingOrder != null;

  @override
  void initState() {
    super.initState();
    final o = widget.existingOrder;
    _nameCtrl = TextEditingController(text: o?.fullName ?? '');
    // if(context.read<AuthProvider>().isAdmin){
    //   _emailCtrl = TextEditingController(text: o?.email ?? '');
    // }else{
    //   _emailCtrl = TextEditingController(text: o?.email ?? context.read<AuthProvider>().userEmail);
    // }
    _phoneCtrl = TextEditingController(text: o?.phone ?? '');
    _timeCtrlLegA = TextEditingController(text: o?.legA.time ?? '');
    _dateCtrlLegA = TextEditingController(text: o?.legA.date ?? '');
    _pickCtrlLegA = TextEditingController(text: o?.legA.pickup ?? '');
    _dropCtrlLegA = TextEditingController(text: o?.legA.dropoff ?? '');
    _timeCtrlLegB = TextEditingController(text: o?.legB!.time ?? '');
    _dateCtrlLegB = TextEditingController(text: o?.legB!.date ?? '');
    _pickCtrlLegB = TextEditingController(text: o?.legB!.pickup ?? '');
    _dropCtrlLegB = TextEditingController(text: o?.legB!.dropoff ?? '');

    loadUsers();
  }

  Future<void> loadUsers() async {
    final auth = context.read<AuthProvider>();

    if (auth.isAdmin) {
      final fetchedUsers = auth.users;

      final filteredUsers = fetchedUsers?.where((u) {
        return u['id'] != auth.user!.uid;
      }).toList();

      setState(() {
        users = List<Map<String, dynamic>>.from(filteredUsers!);

        if (users.isNotEmpty && widget.existingOrder != null) {
          final user = users
              .where((user) => user['id'] == widget.existingOrder!.userId)
              .first;

          userId = user['id'];
          // _emailCtrl.text = user['email'];
        }
      });
    } else {
      userId = auth.user!.uid;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    // _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _timeCtrlLegA.dispose();
    _dateCtrlLegA.dispose();
    _pickCtrlLegA.dispose();
    _dropCtrlLegA.dispose();
    _timeCtrlLegB.dispose();
    _dateCtrlLegB.dispose();
    _pickCtrlLegB.dispose();
    _dropCtrlLegB.dispose();
    super.dispose();
  }

  Future<void> _pickDate({isLegA = true}) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      final pickedDateText =
          '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';

      if (isLegA) {
        _dateCtrlLegA.text = pickedDateText;
      } else {
        _dateCtrlLegB.text = pickedDateText;
      }
    }
  }

  Future<void> _pickTime({isLegA = true}) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          alwaysUse24HourFormat: false,
        ),
        child: child ?? Container(),
      ),
    );
    if (picked != null && mounted) {
      final now = DateTime.now();

      final pickedDate = DateFormat.jm().format(
        DateTime(
          now.year,
          now.month,
          now.day,
          picked.hour,
          picked.minute,
        ),
      );

      if (isLegA) {
        _timeCtrlLegA.text = pickedDate;
      } else {
        _timeCtrlLegB.text = pickedDate;
      }
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final provider = context.read<OrderProvider>();

    final legA = OrderModel.Leg(
      date: _dateCtrlLegA.text.trim(),
      dropoff: _dropCtrlLegA.text.trim(),
      pickup: _pickCtrlLegA.text.trim(),
      time: _timeCtrlLegA.text.trim(),
    );

    final legB = OrderModel.Leg(
      date: _dateCtrlLegB.text.trim(),
      dropoff: _dropCtrlLegB.text.trim(),
      pickup: _pickCtrlLegB.text.trim(),
      time: _timeCtrlLegB.text.trim(),
    );

    if (_isEdit) {
      final updated = widget.existingOrder!.copyWith(
        id: widget.existingOrder!.id,
        userId: userId,
        fullName: _nameCtrl.text.trim(),
        phone: '+1${_phoneCtrl.text.replaceAll(RegExp(r'\D'), '')}',
        legA: legA,
        legB: legB,
        payRate: "0.0",
        updatedAt: DateTime.now().toIso8601String(),
      );
      provider.updateOrder(updated);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Updated successfully')),
      );
      Navigator.pop(context);
    } else {
      provider.addOrder(OrderModel.Order(
        userId: userId ?? context.read<AuthProvider>().user!.uid,
        fullName: _nameCtrl.text.trim(),
        phone: '+1${_phoneCtrl.text.replaceAll(RegExp(r'\D'), '')}',
        legA: legA,
        legB: legB,
        payRate: "0.0",
        status: "Pending",
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
      ));
      // Pop back to home (pops add-order which is pushed from MainScaffold)
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit Booking' : 'New Booking'),
        leading: const BackButton(),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const _SectionHeader(
                    icon: Icons.person_outline, label: 'Customer Info'),
                const SizedBox(height: 12),

                if (users.isNotEmpty)
                  DropdownMenu<String>(
                    width: double.infinity,
                    initialSelection: userId,
                    label: const Text('Select User'),
                    // controller: _emailCtrl,
                    onSelected: (value) {
                      // final selectedUser = users.firstWhere(
                      //   (u) => u['id'] == value,
                      // );

                      setState(() {
                        userId = value;
                        // _emailCtrl.text = selectedUser['email'];
                      });
                    },
                    dropdownMenuEntries: users.map((user) {
                      return DropdownMenuEntry<String>(
                        value: user['id'] ?? '',
                        label: user['email'] ?? '',
                      );
                    }).toList(),
                  ),

                const SizedBox(height: 12),

                _buildField(
                  controller: _nameCtrl,
                  label: 'Full Name',
                  icon: Icons.person_outline,
                  validator: _required,
                ),
                const SizedBox(height: 14),
                // _buildField(
                //   controller: _emailCtrl,
                //   label: 'Email',
                //   icon: Icons.email_outlined,
                //   keyboardType: TextInputType.emailAddress,
                //   validator: (v) {
                //     if (v == null || v.isEmpty) return 'Required';
                //     if (!v.contains('@')) return 'Enter valid email';
                //     return null;
                //   },
                // ),
                // const SizedBox(height: 14),
                _buildField(
                  controller: _phoneCtrl,
                  label: 'Phone',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  validator: _required,
                ),
                const SizedBox(height: 24),

                // const _SectionHeader(
                //     icon: Icons.schedule_outlined, label: 'Schedule'),

                const _SectionHeader(label: 'Leg A'),
                const SizedBox(height: 12),
                Column(
                  spacing: 14,
                  children: [
                    Row(
                      spacing: 8,
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _timeCtrlLegA,
                            readOnly: true,
                            decoration: const InputDecoration(
                              labelText: 'Time',
                              prefixIcon: Icon(Icons.access_time_outlined),
                            ),
                            onTap: _pickTime,
                            validator: _required,
                          ),
                        ),
                        // const SizedBox(height: 14),
                        // Date picker
                        Expanded(
                          child: TextFormField(
                            controller: _dateCtrlLegA,
                            readOnly: true,
                            decoration: const InputDecoration(
                              labelText: 'Date',
                              prefixIcon: Icon(Icons.calendar_today_outlined),
                            ),
                            onTap: _pickDate,
                            validator: _required,
                          ),
                        ),
                      ],
                    ),
                    _buildField(
                      controller: _pickCtrlLegA,
                      label: 'Pick-up Location',
                      icon: Icons.trip_origin_rounded,
                      iconColor: Colors.green.shade600,
                      validator: _required,
                    ),
                    _buildField(
                      controller: _dropCtrlLegA,
                      label: 'Drop-off Location',
                      icon: Icons.location_on_rounded,
                      iconColor: Colors.red.shade400,
                      validator: _required,
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                const _SectionHeader(label: 'Leg B'),
                const SizedBox(height: 12),
                Column(
                  spacing: 14,
                  children: [
                    Row(
                      spacing: 8,
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _timeCtrlLegB,
                            readOnly: true,
                            decoration: const InputDecoration(
                              labelText: 'Time',
                              prefixIcon: Icon(Icons.access_time_outlined),
                            ),
                            onTap: () => _pickTime(isLegA: false),
                            validator: _required,
                          ),
                        ),
                        // const SizedBox(height: 14),
                        // Date picker
                        Expanded(
                          child: TextFormField(
                            controller: _dateCtrlLegB,
                            readOnly: true,
                            decoration: const InputDecoration(
                              labelText: 'Date',
                              prefixIcon: Icon(Icons.calendar_today_outlined),
                            ),
                            onTap: () => _pickDate(isLegA: false),
                            validator: _required,
                          ),
                        ),
                      ],
                    ),
                    _buildField(
                      controller: _pickCtrlLegB,
                      label: 'Pick-up Location',
                      icon: Icons.trip_origin_rounded,
                      iconColor: Colors.green.shade600,
                      validator: _required,
                    ),
                    _buildField(
                      controller: _dropCtrlLegB,
                      label: 'Drop-off Location',
                      icon: Icons.location_on_rounded,
                      iconColor: Colors.red.shade400,
                      validator: _required,
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                Row(
                  spacing: 16,
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 52,
                        child: ElevatedButton.icon(
                          onPressed: _submit,
                          icon: Icon(_isEdit
                              ? Icons.save_outlined
                              : Icons.add_rounded),
                          label:
                              Text(_isEdit ? 'Save Changes' : 'Create Order'),
                        ),
                      ),
                    ),
                  ],
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
        prefixText: label == "Phone"  ? '+1 ' : '',
      ),
      inputFormatters: [
        if (label == "Phone")
          PhoneInputFormatter(
            defaultCountryCode: 'US',
            allowEndlessPhone: false,
          ),
      ],
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
  final IconData? icon;
  final String label;

  const _SectionHeader({this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Row(
      children: [
        if (icon != null) Icon(icon, size: 18, color: primary),
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

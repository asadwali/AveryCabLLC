import 'package:avery_cab_app/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/order.dart';
import '../providers/order_provider.dart';
import 'order_form_screen.dart';

class OrderDetailScreen extends StatefulWidget {
  final Order order;

  const OrderDetailScreen({super.key, required this.order});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  final _payRateCtrl = TextEditingController(text: '0.00');

  double baseFare = 0.0;
  double taxAmount = 0.0;
  double totalFare = 0.0;

  static const double taxPercent = 6.35;

  @override
  void initState() {
    super.initState();

    if(widget.order.payRate != null && widget.order.payRate != 'N/A'){
      _payRateCtrl.text = widget.order.payRate.toString();
    }

    final storedTotal = widget.order.payRate != null
        ? double.tryParse(widget.order.payRate!) ?? 0.00
        : 0.00;

    if (storedTotal > 0) {
      baseFare = storedTotal / (1 + (taxPercent / 100));

      totalFare = storedTotal;

      taxAmount = totalFare - baseFare;

      _payRateCtrl.text = totalFare.toStringAsFixed(2);

      setState(() {});
    }
  }

  void _calculateTax(String? value) {
    if (value != null && value.isNotEmpty) {
      final double value_ = double.parse(value);
      final base = value_;
      final total = base * (1 + (taxPercent / 100));

      setState(() {
        baseFare = base;
        totalFare = total;
      });
    } else {
      setState(() {
        baseFare = 0;
        totalFare = 0;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();

    _payRateCtrl.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Watch the provider so the screen rebuilds when status changes
    final liveOrder = context
        .watch<OrderProvider>()
        .orders
        .firstWhere((o) => o.id == widget.order.id, orElse: () => widget.order);

    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final isPending = liveOrder.status == OrderStatus.Pending.name;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Details'),
        actions: [
          if (isPending)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Edit',
              onPressed: () => _openEdit(context, liveOrder),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // ── Hero card ─────────────────────────────────────────────
            _HeroCard(order: liveOrder, isPending: isPending, theme: theme),
            const SizedBox(height: 20),

            _DetailSection(
              title: 'Leg A',
              children: [
                _DetailRow(label: 'Time', value: liveOrder.legA.time),
                _DetailRow(label: 'Date', value: liveOrder.legA.date),
                _DetailRow(
                  label: 'Pick-up',
                  value: liveOrder.legA.pickup,
                  valueColor: Colors.green.shade700,
                ),
                _DetailRow(
                  label: 'Drop-off',
                  value: liveOrder.legA.dropoff,
                  valueColor: Colors.red.shade500,
                ),
              ],
            ),
            const SizedBox(height: 14),
            _DetailSection(
              title: 'Leg B',
              children: [
                _DetailRow(label: 'Time', value: liveOrder.legB!.time),
                _DetailRow(label: 'Date', value: liveOrder.legB!.date),
                _DetailRow(
                  label: 'Pick-up',
                  value: liveOrder.legB!.pickup,
                  valueColor: Colors.green.shade700,
                ),
                _DetailRow(
                  label: 'Drop-off',
                  value: liveOrder.legB!.dropoff,
                  valueColor: Colors.red.shade500,
                ),
              ],
            ),
            const SizedBox(height: 14),
            _DetailSection(
              icon: Icons.attach_money_outlined,
              title: 'Pricing',
              children: [
                TextFormField(
                  controller: _payRateCtrl,
                  keyboardType: TextInputType.number,
                  readOnly: !isPending,
                  onChanged: (value) => _calculateTax(value),
                  decoration: InputDecoration(
                    labelText: 'Total Fare',
                    prefixIcon: Icon(Icons.attach_money_rounded,
                        color: Colors.green.shade600),
                    focusedBorder: !isPending ? OutlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(12)) : null,
                  ),
                ),
                const SizedBox(
                  height: 4,
                ),
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      spacing: 8,
                      children: [
                        const Text(
                          'Base Fare',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: Colors.blueGrey),
                          textAlign: TextAlign.start,
                        ),
                        Text(
                          baseFare.toStringAsFixed(2),
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: Colors.black),
                          textAlign: TextAlign.start,
                        ),
                      ],
                    ),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      spacing: 8,
                      children: [
                        Text(
                          'Tax',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: Colors.blueGrey),
                          textAlign: TextAlign.start,
                        ),
                        Text(
                          "$taxPercent%",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: Colors.black),
                          textAlign: TextAlign.start,
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      spacing: 8,
                      children: [
                        const Text(
                          'Total Fare',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: Colors.blueGrey),
                          textAlign: TextAlign.start,
                        ),
                        Text(
                          totalFare.toStringAsFixed(2),
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: Colors.black),
                          textAlign: TextAlign.start,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),

            // ── Mark as Complete button ───────────────────────────────
            if (isPending) ...[
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                  ),
                  onPressed: () => _markComplete(
                      context, liveOrder.id, totalFare.toStringAsFixed(2)),
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Mark as Completed'),
                ),
              ),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _markComplete(BuildContext context, String id, String payRate) {
    context.read<OrderProvider>().markCompleted(id, payRate);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Order marked as completed'),
        backgroundColor: Colors.green.shade600,
      ),
    );
  }

  void _openEdit(BuildContext context, Order order) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OrderFormScreen(existingOrder: order),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Hero summary card
// ─────────────────────────────────────────────────────────────────────────────

class _HeroCard extends StatelessWidget {
  final Order order;
  final bool isPending;
  final ThemeData theme;

  const _HeroCard({
    required this.order,
    required this.isPending,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final primary = theme.colorScheme.primary;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primary, const Color(0xFF3949AB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: primary.withValues(alpha:0.35),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: Colors.white.withValues(alpha: 0.2),
                child: Text(
                  order.fullName.isNotEmpty
                      ? order.fullName[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.fullName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      order.phone,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha:0.8),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              // Status badge
            ],
          ),
          const SizedBox(height: 16),
          Divider(color: Colors.white.withValues(alpha: 0.25), height: 1),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                spacing: 6,
                children: [
                  const Icon(Icons.access_time,
                      color: Colors.white70, size: 15),
                  Text(
                    order.legA.time,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                  ),
                ],
              ),
              Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                  decoration: BoxDecoration(
                    color: isPending
                        ? Colors.orange.withValues(alpha: 0.9)
                        : Colors.green.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isPending ? 'Pending' : 'Completed',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Detail section card
// ─────────────────────────────────────────────────────────────────────────────

class _DetailSection extends StatelessWidget {
  final IconData? icon;
  final String title;
  final List<Widget> children;

  const _DetailSection({
    this.icon,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Row(
              children: [
                if (icon != null) Icon(icon, size: 17, color: primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: primary,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: Colors.grey.shade100),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _DetailRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: valueColor ?? Colors.grey.shade800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

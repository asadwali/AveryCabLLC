import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/order.dart';
import '../providers/order_provider.dart';
import 'order_form_screen.dart';

class OrderDetailScreen extends StatelessWidget {
  final Order order;

  const OrderDetailScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    // Watch the provider so the screen rebuilds when status changes
    final liveOrder = context
        .watch<OrderProvider>()
        .orders
        .firstWhere((o) => o.id == order.id, orElse: () => order);

    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final isPending = liveOrder.status == OrderStatus.pending;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Details'),
        actions: [
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

            // ── Details section ───────────────────────────────────────
            _DetailSection(
              icon: Icons.person_outline,
              title: 'Customer',
              children: [
                _DetailRow(label: 'Name', value: liveOrder.name),
                _DetailRow(label: 'Email', value: liveOrder.email),
                _DetailRow(label: 'Phone', value: liveOrder.phone),
              ],
            ),
            const SizedBox(height: 14),
            _DetailSection(
              icon: Icons.schedule_outlined,
              title: 'Schedule',
              children: [
                _DetailRow(label: 'Time', value: liveOrder.deliveryTime),
                _DetailRow(label: 'Date', value: liveOrder.deliveryDate),
              ],
            ),
            const SizedBox(height: 14),
            _DetailSection(
              icon: Icons.route_outlined,
              title: 'Route',
              children: [
                _DetailRow(
                  label: 'Pick-up',
                  value: liveOrder.pickLocation,
                  valueColor: Colors.green.shade700,
                ),
                _DetailRow(
                  label: 'Drop-off',
                  value: liveOrder.dropOffLocation,
                  valueColor: Colors.red.shade500,
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
                  onPressed: () => _markComplete(context, liveOrder.id),
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

  void _markComplete(BuildContext context, String id) {
    context.read<OrderProvider>().markCompleted(id);
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
            color: primary.withOpacity(0.35),
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
                backgroundColor: Colors.white.withOpacity(0.2),
                child: Text(
                  order.name.isNotEmpty ? order.name[0].toUpperCase() : '?',
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
                      order.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      order.email,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              // Status badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: isPending
                      ? Colors.orange.withOpacity(0.9)
                      : Colors.green.withOpacity(0.9),
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
            ],
          ),
          const SizedBox(height: 16),
          Divider(color: Colors.white.withOpacity(0.25), height: 1),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.access_time, color: Colors.white70, size: 15),
              const SizedBox(width: 6),
              Text(
                '${order.deliveryTime}  ·  ${order.deliveryDate}',
                style: const TextStyle(color: Colors.white, fontSize: 13),
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
  final IconData icon;
  final String title;
  final List<Widget> children;

  const _DetailSection({
    required this.icon,
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
            color: Colors.black.withOpacity(0.05),
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
                Icon(icon, size: 17, color: primary),
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

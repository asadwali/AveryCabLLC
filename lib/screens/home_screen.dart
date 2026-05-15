import 'package:avery_cab_app/widgets/skeleton_order_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../models/order.dart';
import '../providers/order_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/order_card.dart';
import 'order_detail_screen.dart';
import 'order_form_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  OrderStatus? _activeFilter; // null = All

  bool showShimmer = true;

  @override
  void initState() {
    super.initState();

    context.read<OrderProvider>().loadOrders();

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          showShimmer = false;
        });
      }
    });
  }

  Widget buildOrders(List<Order> orders) {
    // Show shimmer first
    if (showShimmer) {
      return Padding(
        padding: const EdgeInsets.only(
          left: 8.0,
          right: 8.0,
        ),
        child: Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: ListView.separated(
            itemCount: 3,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, __) => const OrderCardSkeleton(),
          ),
        ),
      );
    }

    // Show empty state after shimmer ends
    if (orders.isEmpty && showShimmer == false) {
      return _EmptyState(filter: _activeFilter);
    }

    // Show actual list
    return ListView.builder(
      padding: const EdgeInsets.only(
        bottom: 80,
        left: 8.0,
        right: 8.0,
      ),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];

        return OrderCard(
          order: order,
          onView: () => _openView(context, order),
          onEdit: () => _openEdit(context, order),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final orders = context.watch<OrderProvider>().getById(context.read<AuthProvider>().user!.uid).getByStatus(_activeFilter);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          spacing: 8,
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Center(
                  child: Image.asset('assets/images/avery_cab_icon.png',
                      height: 24)),
            ),
            const Text('Bookings'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Logout',
            onPressed: () => _confirmLogout(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Filter capsule strip ─────────────────────────────────────
          _FilterStrip(
            activeFilter: _activeFilter,
            onChanged: (status) => setState(() => _activeFilter = status),
          ),

          // ── Order count ───────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              children: [
                Text(
                  '${orders.length} Booking${orders.length != 1 ? 's' : ''}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: buildOrders(orders),
            ),
          ),
        ],
      ),
    );
  }

  void _openView(BuildContext context, Order order) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OrderDetailScreen(order: order),
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

  Future<void> _confirmLogout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Logout', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm == true && context.mounted) {
      context.read<AuthProvider>().logout();
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Filter strip
// ─────────────────────────────────────────────────────────────────────────────

class _FilterStrip extends StatelessWidget {
  final OrderStatus? activeFilter;
  final ValueChanged<OrderStatus?> onChanged;

  const _FilterStrip({
    required this.activeFilter,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.primary,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      child: Row(
        children: [
          _Capsule(
            label: 'All',
            selected: activeFilter == null,
            onTap: () => onChanged(null),
          ),
          const SizedBox(width: 8),
          _Capsule(
            label: 'Pending',
            selected: activeFilter == OrderStatus.Pending,
            onTap: () => onChanged(OrderStatus.Pending),
            selectedColor: Colors.orange,
          ),
          const SizedBox(width: 8),
          _Capsule(
            label: 'Completed',
            selected: activeFilter == OrderStatus.Completed,
            onTap: () => onChanged(OrderStatus.Completed),
            selectedColor: Colors.green,
          ),
        ],
      ),
    );
  }
}

class _Capsule extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color? selectedColor;

  const _Capsule({
    required this.label,
    required this.selected,
    required this.onTap,
    this.selectedColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = selectedColor ?? Colors.white;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
        decoration: BoxDecoration(
          color: selected ? color : Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: selected ? color : Colors.white38,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected
                ? (selectedColor != null
                    ? Colors.white
                    : Theme.of(context).colorScheme.primary)
                : Colors.white,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Empty state
// ─────────────────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final OrderStatus? filter;
  const _EmptyState({required this.filter});

  @override
  Widget build(BuildContext context) {
    final label = filter == null
        ? 'No orders yet'
        : filter == OrderStatus.Pending
            ? 'No pending orders'
            : 'No completed orders';

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inbox_rounded, size: 72, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            label,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey.shade400,
                ),
          ),
        ],
      ),
    );
  }
}

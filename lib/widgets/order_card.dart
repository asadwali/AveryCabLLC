import 'package:avery_cab_app/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/order.dart';

class OrderCard extends StatefulWidget {
  final Order order;
  final VoidCallback onView;
  final VoidCallback onEdit;

  const OrderCard({
    super.key,
    required this.order,
    required this.onView,
    required this.onEdit,
  });

  @override
  State<OrderCard> createState() => _OrderCardState();
}

class _OrderCardState extends State<OrderCard> {
  bool legA = true;

  Leg? legFields;


  @override
  void initState(){
    super.initState();

    legA = true;
    legFields = widget.order.legA;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPending = widget.order.status == OrderStatus.Pending.name;

    void toggleLegA(){
      setState(() {
        legA = !legA;
        if(legA){
          legFields = widget.order.legA;
        }
        else{
          legFields = widget.order.legB!;
        }
      });
    }

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: widget.onView,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header row ──────────────────────────────────────────
              Row(
                children: [
                  // Avatar
                  CircleAvatar(
                    backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                    child: Text(
                      widget.order.fullName.isNotEmpty
                          ? widget.order.fullName[0].toUpperCase()
                          : '?',
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Name + email
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.order.fullName,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          widget.order.phone,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  // Status chip
                  _StatusBadge(isPending: isPending),
                ],
              ),

              const Divider(height: 20),

              // ── Info rows ────────────────────────────────────────────
              // _InfoRow(
              //   icon: Icons.phone_outlined,
              //   label: 'Phone',
              //   value: order.phone,
              // ),
              // const SizedBox(height: 6),

              Row(
                spacing: 4,
                children: [
                  GestureDetector(
                    onTap: toggleLegA,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 1.5),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(10),
                          color:  legA ? Theme.of(context).colorScheme.primary : Colors.white
                        ),
                    
                        child: Text("Leg A", style: TextStyle(color: legA ? Colors.white : Colors.grey.shade600),),
                    ),
                  ),

                  GestureDetector(
                    onTap: toggleLegA,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 1.5),
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(10),
                          color: !legA
                              ? Theme.of(context).colorScheme.primary
                              : Colors.white),
                      child: Text(
                        "Leg B",
                        style: TextStyle(color: !legA ? Colors.white : Colors.grey.shade600),
                      ),
                    ),
                  ),
                ],
              ), 

              const SizedBox(height: 6), 

              _InfoRow(
                icon: Icons.access_time_outlined,
                label: 'Time',
                value: '${legFields?.time}  •  ${legFields?.date}',
              ),
              const SizedBox(height: 6),
              _InfoRow(
                icon: Icons.trip_origin_rounded,
                label: 'Pick-up',
                value: legFields!.pickup,
                iconColor: Colors.green.shade600,
              ),
              const SizedBox(height: 6),
              _InfoRow(
                icon: Icons.location_on_rounded,
                label: 'Drop-off',
                value: legFields!.dropoff,
                iconColor: Colors.red.shade400,
              ),

              const SizedBox(height: 12),

              // ── Action buttons ───────────────────────────────────────
              Row(
                spacing: 8,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _ActionButton(
                    icon: Icons.visibility_outlined,
                    label: 'View',
                    color: theme.colorScheme.primary,
                    onTap: widget.onView,
                  ),
                  if(widget.order.payRate != null && widget.order.payRate != 'N/A')
                      _ActionButton(
                        icon: Icons.monetization_on,
                        label: widget.order.payRate.toString(),
                        color: Colors.green.shade800,
                        onTap: null,
                      ),
                  if(isPending)
                  _ActionButton(
                    icon: Icons.edit_outlined,
                    label: 'Edit',
                    color: theme.colorScheme.secondary,
                    onTap: widget.onEdit,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final bool isPending;
  const _StatusBadge({required this.isPending});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isPending
            ? Colors.orange.shade50
            : Colors.green.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isPending ? Colors.orange.shade300 : Colors.green.shade300,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isPending ? Colors.orange : Colors.green,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            isPending ? 'Pending' : 'Completed',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isPending ? Colors.orange.shade700 : Colors.green.shade700,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? iconColor;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: iconColor ?? Colors.grey.shade500),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade700,
                ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

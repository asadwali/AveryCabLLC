import 'package:flutter/foundation.dart';
import '../models/order.dart';

class OrderProvider extends ChangeNotifier {
  final List<Order> _orders = [
    Order(
      name: 'John Smith',
      email: 'john@example.com',
      phone: '+1 555-0101',
      deliveryTime: '10:30 AM',
      deliveryDate: '2026-05-08',
      pickLocation: '123 Main St, New York',
      dropOffLocation: '456 Park Ave, New York',
      status: OrderStatus.pending,
    ),
    Order(
      name: 'Sarah Connor',
      email: 'sarah@example.com',
      phone: '+1 555-0202',
      deliveryTime: '02:00 PM',
      deliveryDate: '2026-05-07',
      pickLocation: '789 Broadway, New York',
      dropOffLocation: '321 5th Ave, New York',
      status: OrderStatus.completed,
    ),
  ];

  List<Order> get orders => List.unmodifiable(_orders);

  List<Order> getByStatus(OrderStatus? status) {
    if (status == null) return orders;
    return _orders.where((o) => o.status == status).toList();
  }

  void addOrder(Order order) {
    _orders.add(order);
    notifyListeners();
  }

  void updateOrder(Order updated) {
    final index = _orders.indexWhere((o) => o.id == updated.id);
    if (index != -1) {
      _orders[index] = updated;
      notifyListeners();
    }
  }

  void markCompleted(String id) {
    final index = _orders.indexWhere((o) => o.id == id);
    if (index != -1) {
      _orders[index] = _orders[index].copyWith(status: OrderStatus.completed);
      notifyListeners();
    }
  }

  void deleteOrder(String id) {
    _orders.removeWhere((o) => o.id == id);
    notifyListeners();
  }
}

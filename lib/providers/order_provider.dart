import 'package:avery_cab_app/controllers/order.controller.dart';
import 'package:avery_cab_app/utils/constants.dart';
import 'package:flutter/foundation.dart';
import '../models/order.dart';

class OrderProvider extends ChangeNotifier {
  List<Order> _orders = [];

  List<Order> get orders => List.unmodifiable(_orders);

  OrderProvider(){
    loadOrders();
  }

  Future<void> loadOrders() async {
    _orders = await OrderController.list();
    notifyListeners();
  }


  OrderProvider getById(String id){
    if(id == Constants.admin_id) return this;
    _orders = _orders.where((o) => o.userId == id).toList();
    return this;
  }

  List<Order> getByStatus(OrderStatus? status) {
    if (status == null) return orders;
    return _orders.where((o) => o.status == status.name).toList();
  }

  void addOrder(Order order) {
    _orders.add(order);
    OrderController.addOrder(order);
    notifyListeners();
  }

  void updateOrder(Order updated) {
    final index = _orders.indexWhere((o) => o.id == updated.id);
    if (index != -1) {
      _orders[index] = updated;
      notifyListeners();
    }

    OrderController.updateOrder(updated);
  }

  void markCompleted(String id, String payRate) {
    final index = _orders.indexWhere((o) => o.id == id);
    if (index != -1) {
      _orders[index] = _orders[index].copyWith(status: OrderStatus.Completed.name, payRate: payRate);
      OrderController.updateOrder(_orders[index]);
      notifyListeners();
    }
  }

  void deleteOrder(String id) {
    _orders.removeWhere((o) => o.id == id);
    OrderController.deleteOrder(id);
    notifyListeners();
  }
}

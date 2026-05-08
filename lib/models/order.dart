import 'package:uuid/uuid.dart';

enum OrderStatus { pending, completed }

class Order {
  final String id;
  String name;
  String email;
  String phone;
  String deliveryTime;
  String deliveryDate;
  String pickLocation;
  String dropOffLocation;
  OrderStatus status;

  Order({
    String? id,
    required this.name,
    required this.email,
    required this.phone,
    required this.deliveryTime,
    required this.deliveryDate,
    required this.pickLocation,
    required this.dropOffLocation,
    this.status = OrderStatus.pending,
  }) : id = id ?? const Uuid().v4();

  Order copyWith({
    String? name,
    String? email,
    String? phone,
    String? deliveryTime,
    String? deliveryDate,
    String? pickLocation,
    String? dropOffLocation,
    OrderStatus? status,
  }) {
    return Order(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      deliveryTime: deliveryTime ?? this.deliveryTime,
      deliveryDate: deliveryDate ?? this.deliveryDate,
      pickLocation: pickLocation ?? this.pickLocation,
      dropOffLocation: dropOffLocation ?? this.dropOffLocation,
      status: status ?? this.status,
    );
  }
}

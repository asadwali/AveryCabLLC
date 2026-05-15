import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:avery_cab_app/models/order.dart' as OrderModel;

class OrderController {

  static const String collectionName = 'booking';

  static Future<List<OrderModel.Order>> list() async {
    try {
      final orderSnapshot = await FirebaseFirestore.instance.collection(collectionName).get();

      final orders = orderSnapshot.docs.map((doc) => OrderModel.Order.fromMap(doc.data())).toList();

      return orders;
    } catch (e) {
      throw Exception(e);
    }
  }

  static void addOrder(OrderModel.Order order) async {
    try {
      final docRef = FirebaseFirestore.instance
        .collection(collectionName)
        .doc();

      final updatedOrder = order.copyWith(
        id: docRef.id,
      );

      order.setId(docRef.id);

      await docRef.set(updatedOrder.toMap());
    } on FirebaseException catch (e) {
      throw Exception(e);
    }
  }

  static void updateOrder(OrderModel.Order order) {
    try {
      FirebaseFirestore.instance.collection(collectionName).doc(order.id).update(order.toMap());
    } on FirebaseException catch (e) {
      throw Exception(e);
    }
  }

  static void deleteOrder(String id) {
    try {
      FirebaseFirestore.instance.collection(collectionName).doc(id).delete();
    } on FirebaseException catch (e) {
      throw Exception(e);
    }
  }
}
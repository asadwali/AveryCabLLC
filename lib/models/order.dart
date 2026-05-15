// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

enum OrderStatus { Pending, Completed }

class Order {
  String id;
  String userId;
  String fullName;
  Leg legA;
  Leg? legB;
  String phone;
  String status;
  String? payRate;
  String? createdAt;
  String? updatedAt;


  Order({
    String? id,
    required this.userId,
    required this.fullName,
    required this.legA,
    required this.phone,
    required this.status,
    this.legB,
    this.payRate,
    this.createdAt,
    this.updatedAt,
  }) : id = id ?? const Uuid().v4();

  void setId(id) {
    this.id = id;
  }

  Order copyWith({
    String? id,
    String? userId,
    String? fullName,
    Leg? legA,
    Leg? legB,
    String? phone,
    String? status,
    String? payRate,
    String? createdAt,
    String? updatedAt,
  }) {
    return Order(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      fullName: fullName ?? this.fullName,
      legA: legA ?? this.legA,
      legB: legB ?? this.legB,
      phone: phone ?? this.phone,
      status: status ?? this.status,
      payRate: payRate ?? this.payRate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'userId': userId,
      'fullName': fullName,
      'legA': legA.toMap(),
      'legB': legB?.toMap(),
      'phone': phone,
      'status': status,
      'payRate': payRate,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      id: map['id'] as String,
      userId: map['userId'] as String,
      fullName: map['fullName'] as String,
      legA: Leg.fromMap(map['legA'] as Map<String, dynamic>),
      legB: Leg.fromMap(map['legB'] as Map<String, dynamic>),
      phone: map['phone'] as String,
      status: map['status'] as String,
      payRate: map['payRate'] ?? 0.0,
      createdAt: map['createdAt'] != null ? map['createdAt'] as String : null,
      updatedAt: map['updatedAt'] != null ? map['updatedAt'] as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory Order.fromJson(String source) =>
      Order.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Order(id: $id, userId: $userId, fullName: $fullName, legA: $legA, legB: $legB, phone: $phone, status: $status, payRate: $payRate, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(covariant Order other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.userId == userId &&
        other.fullName == fullName &&
        other.legA == legA &&
        other.legB == legB &&
        other.phone == phone &&
        other.status == status &&
        other.payRate == payRate &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        userId.hashCode ^
        fullName.hashCode ^
        legA.hashCode ^
        legB.hashCode ^
        phone.hashCode ^
        status.hashCode ^
        payRate.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }
}

class Leg {
  String date;
  String dropoff;
  String pickup;
  String time;
  Leg({
    required this.date,
    required this.dropoff,
    required this.pickup,
    required this.time,
  });

  Leg copyWith({
    String? date,
    String? dropoff,
    String? pickup,
    String? time,
  }) {
    return Leg(
      date: date ?? this.date,
      dropoff: dropoff ?? this.dropoff,
      pickup: pickup ?? this.pickup,
      time: time ?? this.time,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'date': date,
      'dropoff': dropoff,
      'pickup': pickup,
      'time': time,
    };
  }

  factory Leg.fromMap(Map<String, dynamic> map) {
    return Leg(
      date: map['date'] as String,
      dropoff: map['dropoff'] as String,
      pickup: map['pickup'] as String,
      time: map['time'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory Leg.fromJson(String source) =>
      Leg.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Leg(date: $date, dropoff: $dropoff, pickup: $pickup, time: $time)';
  }

  @override
  bool operator ==(covariant Leg other) {
    if (identical(this, other)) return true;

    return other.date == date &&
        other.dropoff == dropoff &&
        other.pickup == pickup &&
        other.time == time;
  }

  @override
  int get hashCode {
    return date.hashCode ^ dropoff.hashCode ^ pickup.hashCode ^ time.hashCode;
  }
}

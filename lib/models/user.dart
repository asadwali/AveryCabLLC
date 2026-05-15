class UserModel{
  String? id;
  String? fullName;
  String? email;
  String? phone;

  UserModel({this.id, this.fullName, this.email, this.phone});

  UserModel copyWith({
    String? id,
    String? fullName,
    String? email,
    String? phone,
  }){
    return UserModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
    );
  }

  UserModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    fullName = json['fullName'];
    email = json['email'];
    phone = json['phone'];
  }

  Map<String, dynamic> toMap() => {
      'id': id,
      'fullName': fullName,
      'email': email,
      'phone': phone,
    };

  factory UserModel.fromMap(Map<String, dynamic> map) => UserModel.fromJson(map);
}
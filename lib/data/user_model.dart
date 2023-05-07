class User {
  int? id;
  String mobile;
  String name;
  int own;

  User({this.id, required this.mobile, required this.name, this.own = 0});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'mobile': mobile,
      'name': name,
      'own': own,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      mobile: map['mobile'],
      name: map['name'],
      own: map['own'],
    );
  }
}

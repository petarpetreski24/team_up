import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String id;
  final String name;
  final String email;
  final Map<String, String> sportsLevels;
  final List<String> hostedEvents;
  final List<String> participatedEvents;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.sportsLevels = const {},
    this.hostedEvents = const [],
    this.participatedEvents = const [],
  });

  User copyWith({
    String? name,
    Map<String, String>? sportsLevels,
    List<String>? hostedEvents,
    List<String>? participatedEvents,
  }) {
    return User(
      id: id,
      email: email,
      name: name ?? this.name,
      sportsLevels: sportsLevels ?? this.sportsLevels,
      hostedEvents: hostedEvents ?? this.hostedEvents,
      participatedEvents: participatedEvents ?? this.participatedEvents,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'sportsLevels': sportsLevels,
      'hostedEvents': hostedEvents,
      'participatedEvents': participatedEvents,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      sportsLevels: Map<String, String>.from(map['sportsLevels'] ?? {}),
      hostedEvents: List<String>.from(map['hostedEvents'] ?? []),
      participatedEvents: List<String>.from(map['participatedEvents'] ?? []),
    );
  }

  factory User.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data()!;
    return User.fromMap({
      'id': snapshot.id,
      ...data,
    });
  }
}
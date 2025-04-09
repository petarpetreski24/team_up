import 'package:cloud_firestore/cloud_firestore.dart';

class SportEvent {
  final String id;
  final String organizerId;
  final String sport;
  final DateTime dateTime;
  final String location;
  final int maxPlayers;
  final double pricePerPerson;
  final String description;
  final List<String> registeredPlayers;
  final List<String> acceptedPlayers;
  final bool isOpen;

  SportEvent({
    required this.id,
    required this.organizerId,
    required this.sport,
    required this.dateTime,
    required this.location,
    required this.maxPlayers,
    required this.pricePerPerson,
    this.description = '',
    this.registeredPlayers = const [],
    this.acceptedPlayers = const [],
    this.isOpen = true,
  });

  SportEvent copyWith({
    String? id,
    String? organizerId,
    String? sport,
    DateTime? dateTime,
    String? location,
    int? maxPlayers,
    double? pricePerPerson,
    String? description,
    List<String>? registeredPlayers,
    List<String>? acceptedPlayers,
    bool? isOpen,
  }) {
    return SportEvent(
      id: id ?? this.id,
      organizerId: organizerId ?? this.organizerId,
      sport: sport ?? this.sport,
      dateTime: dateTime ?? this.dateTime,
      location: location ?? this.location,
      maxPlayers: maxPlayers ?? this.maxPlayers,
      pricePerPerson: pricePerPerson ?? this.pricePerPerson,
      description: description ?? this.description,
      registeredPlayers: registeredPlayers ?? this.registeredPlayers,
      acceptedPlayers: acceptedPlayers ?? this.acceptedPlayers,
      isOpen: isOpen ?? this.isOpen,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'organizerId': organizerId,
      'sport': sport,
      'dateTime': Timestamp.fromDate(dateTime),
      'location': location,
      'maxPlayers': maxPlayers,
      'pricePerPerson': pricePerPerson,
      'description': description,
      'registeredPlayers': registeredPlayers,
      'acceptedPlayers': acceptedPlayers,
      'isOpen': isOpen,
    };
  }

  factory SportEvent.fromMap(Map<String, dynamic> map, String documentId) {
    return SportEvent(
      id: documentId,
      organizerId: map['organizerId'] ?? '',
      sport: map['sport'] ?? '',
      dateTime: (map['dateTime'] as Timestamp).toDate(),
      location: map['location'] ?? '',
      maxPlayers: map['maxPlayers'] ?? 0,
      pricePerPerson: (map['pricePerPerson'] ?? 0).toDouble(),
      description: map['description'] ?? '',
      registeredPlayers: List<String>.from(map['registeredPlayers'] ?? []),
      acceptedPlayers: List<String>.from(map['acceptedPlayers'] ?? []),
      isOpen: map['isOpen'] ?? true,
    );
  }

  factory SportEvent.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data()!;
    return SportEvent.fromMap(data, snapshot.id);
  }
}
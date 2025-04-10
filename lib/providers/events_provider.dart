import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/sport_event.dart';

class EventsProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<SportEvent> _events = [];

  List<SportEvent> get events => _events;

  EventsProvider() {
    _fetchEvents();
  }

  Future<void> _fetchEvents() async {
    try {
      final snapshot = await _firestore.collection('events').get();

      _events = snapshot.docs.map((doc) {
        final data = doc.data();
        return SportEvent(
          id: doc.id,
          organizerId: data['organizerId'] ?? '',
          sport: data['sport'] ?? '',
          dateTime: (data['dateTime'] as Timestamp).toDate(),
          location: data['location'] ?? '',
          latitude: (data['latitude'] ?? 0.0).toDouble(),
          longitude: (data['longitude'] ?? 0.0).toDouble(),
          maxPlayers: data['maxPlayers'] ?? 0,
          pricePerPerson: (data['pricePerPerson'] ?? 0).toDouble(),
          description: data['description'] ?? '',
          registeredPlayers: List<String>.from(data['registeredPlayers'] ?? []),
          acceptedPlayers: List<String>.from(data['acceptedPlayers'] ?? []),
          isOpen: data['isOpen'] ?? true,
          isCancelled: data['isCancelled'] ?? false,
        );
      }).toList();

      notifyListeners();
    } catch (e) {
      print('Error fetching events: $e');
    }
  }

  Future<void> createEvent(SportEvent event) async {
    try {
      // Make sure organizer is included in players lists
      List<String> registeredPlayers = List<String>.from(event.registeredPlayers);
      List<String> acceptedPlayers = List<String>.from(event.acceptedPlayers);

      // Add organizer to lists if not already there
      if (!registeredPlayers.contains(event.organizerId)) {
        registeredPlayers.add(event.organizerId);
      }

      if (!acceptedPlayers.contains(event.organizerId)) {
        acceptedPlayers.add(event.organizerId);
      }

      final docRef = await _firestore.collection('events').add({
        'organizerId': event.organizerId,
        'sport': event.sport,
        'dateTime': Timestamp.fromDate(event.dateTime),
        'location': event.location,
        'latitude': event.latitude,
        'longitude': event.longitude,
        'maxPlayers': event.maxPlayers,
        'pricePerPerson': event.pricePerPerson,
        'description': event.description,
        'registeredPlayers': registeredPlayers,
        'acceptedPlayers': acceptedPlayers,
        'isOpen': event.isOpen,
      });

      await _firestore.collection('users').doc(event.organizerId).update({
        'hostedEvents': FieldValue.arrayUnion([docRef.id]),
        'participatedEvents': FieldValue.arrayUnion([docRef.id])
      });

      await _fetchEvents();
    } catch (e) {
      print('Error creating event: $e');
      throw Exception('Failed to create event: $e');
    }
  }

  Future<void> registerForEvent(String eventId, String userId) async {
    try {
      final eventDoc = await _firestore.collection('events').doc(eventId).get();

      if (!eventDoc.exists) {
        throw Exception('Event not found');
      }

      final event = SportEvent.fromFirestore(eventDoc);

      if (!event.registeredPlayers.contains(userId)) {
        // Update the event document
        await _firestore.collection('events').doc(eventId).update({
          'registeredPlayers': FieldValue.arrayUnion([userId])
        });

        await _fetchEvents();
      }
    } catch (e) {
      print('Error registering for event: $e');
      throw Exception('Failed to register for event: $e');
    }
  }

  Future<void> acceptPlayer(String eventId, String userId) async {
    try {
      final eventDoc = await _firestore.collection('events').doc(eventId).get();

      if (!eventDoc.exists) {
        throw Exception('Event not found');
      }

      final event = SportEvent.fromFirestore(eventDoc);

      if (event.registeredPlayers.contains(userId) &&
          !event.acceptedPlayers.contains(userId)) {

        final updatedAcceptedPlayers = [...event.acceptedPlayers, userId];
        final isStillOpen = updatedAcceptedPlayers.length < event.maxPlayers;

        await _firestore.collection('events').doc(eventId).update({
          'acceptedPlayers': FieldValue.arrayUnion([userId]),
          'isOpen': isStillOpen
        });

        await _firestore.collection('users').doc(userId).update({
          'participatedEvents': FieldValue.arrayUnion([eventId])
        });

        await _fetchEvents();
      }
    } catch (e) {
      print('Error accepting player: $e');
      throw Exception('Failed to accept player: $e');
    }
  }

  Future<void> cancelEvent(String eventId) async {
    try {
      final eventDoc = await _firestore.collection('events').doc(eventId).get();

      if (!eventDoc.exists) {
        throw Exception('Event not found');
      }

      final event = SportEvent.fromFirestore(eventDoc);
      final List<String> registeredPlayers = List<String>.from(event.registeredPlayers);
      final List<String> acceptedPlayers = List<String>.from(event.acceptedPlayers);

      await _firestore.collection('events').doc(eventId).update({
        'isOpen': false,
        'isCancelled': true,
        'registeredPlayers': [],
        'acceptedPlayers': [],
      });

      final batch = _firestore.batch();

      final allPlayers = {...registeredPlayers, ...acceptedPlayers}.toList();

      for (final playerId in allPlayers) {
        final userRef = _firestore.collection('users').doc(playerId);
        batch.update(userRef, {
          'participatedEvents': FieldValue.arrayRemove([eventId])
        });
      }

      final organizerRef = _firestore.collection('users').doc(event.organizerId);
      batch.update(organizerRef, {
        'hostedEvents': FieldValue.arrayRemove([eventId])
      });

      await batch.commit();

      await _fetchEvents();
    } catch (e) {
      print('Error canceling event: $e');
      throw Exception('Failed to cancel event: $e');
    }
  }

  Future<void> rejectPlayer(String eventId, String playerId) async {
    try {
      final eventDoc = await _firestore.collection('events').doc(eventId).get();

      if (!eventDoc.exists) {
        throw Exception('Event not found');
      }

      await _firestore.collection('events').doc(eventId).update({
        'registeredPlayers': FieldValue.arrayRemove([playerId])
      });

      await _fetchEvents();
    } catch (e) {
      print('Error rejecting player: $e');
      throw Exception('Failed to reject player: $e');
    }
  }

  Future<void> leaveEvent(String eventId, String userId) async {
    try {
      final eventDoc = await _firestore.collection('events').doc(eventId).get();

      if (!eventDoc.exists) {
        throw Exception('Event not found');
      }

      await _firestore.collection('events').doc(eventId).update({
        'registeredPlayers': FieldValue.arrayRemove([userId]),
        'acceptedPlayers': FieldValue.arrayRemove([userId])
      });

      await _firestore.collection('users').doc(userId).update({
        'participatedEvents': FieldValue.arrayRemove([eventId])
      });

      await _fetchEvents();
    } catch (e) {
      print('Error leaving event: $e');
      throw Exception('Failed to leave event: $e');
    }
  }

  Future<List<SportEvent>> getEventsByOrganizer(String organizerId) async {
    try {
      final snapshot = await _firestore
          .collection('events')
          .where('organizerId', isEqualTo: organizerId)
          .get();

      return snapshot.docs.map((doc) => SportEvent.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error fetching events by organizer: $e');
      return [];
    }
  }

  Future<List<SportEvent>> getEventsByParticipant(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('events')
          .where('registeredPlayers', arrayContains: userId)
          .get();

      return snapshot.docs.map((doc) => SportEvent.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error fetching events by participant: $e');
      return [];
    }
  }

  Future<List<SportEvent>> getUpcomingEvents() async {
    try {
      final now = DateTime.now();
      final snapshot = await _firestore
          .collection('events')
          .where('isOpen', isEqualTo: true)
          .where('dateTime', isGreaterThan: Timestamp.fromDate(now))
          .orderBy('dateTime')
          .limit(10)
          .get();

      return snapshot.docs.map((doc) => SportEvent.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error fetching upcoming events: $e');
      return [];
    }
  }

  Future<void> updateEvent(SportEvent event) async {
    try {
      await _firestore.collection('events').doc(event.id).update({
        'sport': event.sport,
        'dateTime': Timestamp.fromDate(event.dateTime),
        'location': event.location,
        'latitude': event.latitude,
        'longitude': event.longitude,
        'maxPlayers': event.maxPlayers,
        'pricePerPerson': event.pricePerPerson,
        'description': event.description,
        'isOpen': event.isOpen,
      });

      await _fetchEvents();
    } catch (e) {
      print('Error updating event: $e');
      throw Exception('Failed to update event: $e');
    }
  }

  Future<SportEvent?> getEventById(String eventId) async {
    try {
      for (var event in _events) {
        if (event.id == eventId) {
          return event;
        }
      }

      final doc = await _firestore.collection('events').doc(eventId).get();

      if (!doc.exists) {
        return null;
      }

      return SportEvent.fromFirestore(doc);
    } catch (e) {
      print('Error fetching event by ID: $e');
      return null;
    }
  }
}
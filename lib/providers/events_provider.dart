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

  // Fetch all events from Firestore
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
        );
      }).toList();

      notifyListeners();
    } catch (e) {
      print('Error fetching events: $e');
    }
  }

  // Create a new event
  Future<void> createEvent(SportEvent event) async {
    try {
      // Generate a document with auto ID
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
        'registeredPlayers': event.registeredPlayers,
        'acceptedPlayers': event.acceptedPlayers,
        'isOpen': event.isOpen,
      });

      // Update the user's hosted events
      await _firestore.collection('users').doc(event.organizerId).update({
        'hostedEvents': FieldValue.arrayUnion([docRef.id])
      });

      await _fetchEvents();
    } catch (e) {
      print('Error creating event: $e');
      throw Exception('Failed to create event: $e');
    }
  }

  // Register for an event
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

        // Update the user's participated events
        await _firestore.collection('users').doc(userId).update({
          'participatedEvents': FieldValue.arrayUnion([eventId])
        });

        await _fetchEvents();
      }
    } catch (e) {
      print('Error registering for event: $e');
      throw Exception('Failed to register for event: $e');
    }
  }

  // Accept a player for an event
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

        // Update the event document
        await _firestore.collection('events').doc(eventId).update({
          'acceptedPlayers': FieldValue.arrayUnion([userId]),
          'isOpen': isStillOpen
        });

        await _fetchEvents();
      }
    } catch (e) {
      print('Error accepting player: $e');
      throw Exception('Failed to accept player: $e');
    }
  }

  // Cancel an event
  Future<void> cancelEvent(String eventId) async {
    try {
      final eventDoc = await _firestore.collection('events').doc(eventId).get();

      if (!eventDoc.exists) {
        throw Exception('Event not found');
      }

      // Update the event document
      await _firestore.collection('events').doc(eventId).update({
        'isOpen': false
      });

      await _fetchEvents();
    } catch (e) {
      print('Error canceling event: $e');
      throw Exception('Failed to cancel event: $e');
    }
  }

  // Reject a player from an event
  Future<void> rejectPlayer(String eventId, String playerId) async {
    try {
      final eventDoc = await _firestore.collection('events').doc(eventId).get();

      if (!eventDoc.exists) {
        throw Exception('Event not found');
      }

      // Update the event document
      await _firestore.collection('events').doc(eventId).update({
        'registeredPlayers': FieldValue.arrayRemove([playerId])
      });

      // Update the user's participated events
      await _firestore.collection('users').doc(playerId).update({
        'participatedEvents': FieldValue.arrayRemove([eventId])
      });

      await _fetchEvents();
    } catch (e) {
      print('Error rejecting player: $e');
      throw Exception('Failed to reject player: $e');
    }
  }

  // Leave an event
  Future<void> leaveEvent(String eventId, String userId) async {
    try {
      final eventDoc = await _firestore.collection('events').doc(eventId).get();

      if (!eventDoc.exists) {
        throw Exception('Event not found');
      }

      // Update the event document
      await _firestore.collection('events').doc(eventId).update({
        'registeredPlayers': FieldValue.arrayRemove([userId]),
        'acceptedPlayers': FieldValue.arrayRemove([userId])
      });

      // Update the user's participated events
      await _firestore.collection('users').doc(userId).update({
        'participatedEvents': FieldValue.arrayRemove([eventId])
      });

      await _fetchEvents();
    } catch (e) {
      print('Error leaving event: $e');
      throw Exception('Failed to leave event: $e');
    }
  }

  // Get events by organizer ID
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

  // Get events by participant ID
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

  // Get upcoming events
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

  // Update an event
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

  // Get event by ID
  Future<SportEvent?> getEventById(String eventId) async {
    try {
      // First check if we already have it in memory
      for (var event in _events) {
        if (event.id == eventId) {
          return event;
        }
      }

      // If not found in memory, fetch from Firestore
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
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ride_zo/models/ride_model.dart';
import 'package:ride_zo/utils/date_time_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RideService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _joinedRideId; // Tracks the joined ride ID
  final String currentUserId = 'user123'; // Simulated logged-in user ID

  Future<void> loadRides(
    BuildContext context,
    Function(List<Ride>) onLoaded,
  ) async {
    try {
      final snapshot = await _firestore.collection('rides').get();
      final rides =
          snapshot.docs.map((doc) => Ride.fromJson(doc.data())).toList();
      onLoaded(rides);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading rides: $e')));
      }
    }
  }

  Future<void> loadJoinedRide(
    BuildContext context,
    Function(String?) onLoaded,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _joinedRideId = prefs.getString('joinedRideId');
      onLoaded(_joinedRideId);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading joined ride: $e')),
        );
      }
    }
  }

  Future<void> saveJoinedRide(
    BuildContext context,
    String? joinedRideId,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (joinedRideId != null) {
        await prefs.setString('joinedRideId', joinedRideId);
      } else {
        await prefs.remove('joinedRideId');
      }
      _joinedRideId = joinedRideId; // Update local state
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving joined ride: $e')));
      }
    }
  }

  void addFakeRides(List<Ride> availableRides, Function(List<Ride>) onUpdated) {
    final fakeRides = [
      Ride(
        id: UniqueKey().toString(),
        from: 'NSU',
        destination: 'Farmget',
        seatsLeft: 3,
        date: '12 Jul 2025',
        time: '05:15 PM',
        genderPreference: 'Any',
        vehicleType: 'Car',
        creatorId: 'user001',
      ),
      Ride(
        id: UniqueKey().toString(),
        from: 'Bashundhara',
        destination: 'Kolabagan',
        seatsLeft: 2,
        date: '13 Jul 2025',
        time: '10:00 AM',
        genderPreference: 'Male',
        vehicleType: 'CNG',
        creatorId: 'user002',
      ),
      Ride(
        id: UniqueKey().toString(),
        from: 'Mirpur',
        destination: 'NSU',
        seatsLeft: 3,
        date: '14 Jul 2025',
        time: '03:30 PM',
        genderPreference: 'Female',
        vehicleType: 'Car',
        creatorId: 'user003',
      ),
      Ride(
        id: UniqueKey().toString(),
        from: 'Khilgao',
        destination: 'NSU',
        seatsLeft: 2,
        date: '15 Jul 2025',
        time: '09:00 AM',
        genderPreference: 'Any',
        vehicleType: 'CNG',
        creatorId: 'user004',
      ),
      Ride(
        id: UniqueKey().toString(),
        from: 'NSU',
        destination: 'Pollobi',
        seatsLeft: 3,
        date: '16 Jul 2025',
        time: '01:00 PM',
        genderPreference: 'Any',
        vehicleType: 'Car',
        creatorId: 'user005',
      ),
    ];
    final existingCreators = availableRides.map((r) => r.creatorId).toSet();
    availableRides.addAll(
      fakeRides.where((r) => !existingCreators.contains(r.creatorId)),
    );
    onUpdated(availableRides);
  }

  void createRide(
    BuildContext context,
    List<Ride> availableRides,
    String from,
    String destination,
    String date,
    String time,
    String genderPreference,
    String vehicleType,
    int cngSeats,
    Function(List<Ride>) onSuccess,
  ) {
    final userHasRide = availableRides.any(
      (ride) => ride.creatorId == currentUserId,
    );
    if (userHasRide) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You can only create one ride at a time!'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    if (from.trim().isEmpty ||
        destination.trim().isEmpty ||
        date.isEmpty ||
        time.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please fill all fields correctly!'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    final now = DateTime.now().toUtc().add(Duration(hours: 6));
    final dateParts = date.split(' ');
    final day = int.tryParse(dateParts[0]);
    final month = DateTimeUtils.monthNumber(dateParts[1]);
    final year = int.tryParse(dateParts[2]);
    if (day == null || month == null || year == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid date format!'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }
    final selectedDate = DateTime(year, month, day);
    if (selectedDate.isBefore(now)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Date cannot be in the past!'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    final timeParts = time.split(':');
    if (timeParts.length == 2) {
      final hour = int.tryParse(timeParts[0]);
      final minute = int.tryParse(timeParts[1].split(' ')[0]);
      final period = timeParts[1].split(' ')[1].toUpperCase();
      if (hour != null && minute != null) {
        int totalHours = hour;
        if (period == 'PM' && hour != 12) totalHours += 12;
        if (period == 'AM' && hour == 12) totalHours = 0;
        final selectedTime = DateTime(year, month, day, totalHours, minute);
        if (selectedDate == DateTime(now.year, now.month, now.day) &&
            selectedTime.isBefore(now)) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Time cannot be in the past!'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }
      }
    }

    final ride = Ride(
      id: UniqueKey().toString(),
      from: from.trim(),
      destination: destination.trim(),
      seatsLeft: vehicleType == 'Car' ? 3 : cngSeats,
      date: date,
      time: time,
      genderPreference: genderPreference,
      vehicleType: vehicleType,
      creatorId: currentUserId,
    );
    if (context.mounted) {
      availableRides.add(ride);
      _firestore.collection('rides').doc(ride.id).set(ride.toJson());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ride created successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      onSuccess(availableRides);
    }
  }

  Future<void> joinRide(
    BuildContext context,
    List<Ride> availableRides,
    Ride ride,
    String currentUserId,
    Function(List<Ride>) onSuccess,
  ) async {
    // Check if the user has already created a ride
    final userHasCreatedRide = availableRides.any(
      (r) => r.creatorId == currentUserId,
    );
    if (userHasCreatedRide) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'You cannot join another ride while you have an active created ride!',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    // Existing checks for joining a ride
    if (_joinedRideId != null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You have already joined a ride!'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }
    if (ride.creatorId == currentUserId) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You cannot join your own ride!'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Confirm Join'),
            content: Text(
              'Are you sure you want to join this ride from ${ride.from} to ${ride.destination}?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('No'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text('Yes'),
              ),
            ],
          ),
    );

    if (confirmed == true && context.mounted && ride.seatsLeft > 0) {
      ride.seatsLeft--;
      _joinedRideId = ride.id;
      _firestore.collection('rides').doc(ride.id).update({
        'seatsLeft': ride.seatsLeft,
      });
      await saveJoinedRide(context, _joinedRideId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You have successfully joined the ride!'),
          backgroundColor: Colors.blue,
        ),
      );
      onSuccess(availableRides);
    }
  }

  Future<void> leaveRide(
    BuildContext context,
    List<Ride> availableRides,
    Ride ride,
    String? joinedRideId,
    Function(List<Ride>) onSuccess,
  ) async {
    if (joinedRideId != ride.id) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You are not joined to this ride!'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Confirm Leave'),
            content: Text(
              'Are you sure you want to leave this ride from ${ride.from} to ${ride.destination}?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('No'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text('Yes'),
              ),
            ],
          ),
    );

    if (confirmed == true && context.mounted) {
      ride.seatsLeft++;
      _joinedRideId = null;
      _firestore.collection('rides').doc(ride.id).update({
        'seatsLeft': ride.seatsLeft,
      });
      await saveJoinedRide(context, null);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You have left the ride!'),
          backgroundColor: Colors.blue,
        ),
      );
      onSuccess(availableRides);
    }
  }

  Future<void> deleteRide(
    BuildContext context,
    List<Ride> availableRides,
    Ride ride,
    String? joinedRideId,
    Function(List<Ride>) onSuccess,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Confirm Delete'),
            content: Text(
              'Are you sure you want to delete this ride from ${ride.from} to ${ride.destination}?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('No'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text('Yes'),
              ),
            ],
          ),
    );

    if (confirmed == true && context.mounted) {
      availableRides.removeWhere((r) => r.id == ride.id);
      if (joinedRideId == ride.id) {
        _joinedRideId = null;
        await saveJoinedRide(context, null);
      }
      _firestore.collection('rides').doc(ride.id).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ride deleted successfully!'),
          backgroundColor: Colors.blue,
        ),
      );
      onSuccess(availableRides);
    }
  }
}

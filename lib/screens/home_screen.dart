import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ride_zo/models/ride_model.dart';
import 'package:ride_zo/services/ride_service.dart';
import 'package:ride_zo/screens/authentication_screens/signin_screen.dart';
import 'package:ride_zo/screens/chat_screen.dart';
import 'package:ride_zo/widgets/create_ride_dialog.dart';
import 'package:ride_zo/widgets/ride_list_item.dart';
import 'package:ride_zo/widgets/ride_option_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RideShareHomeScreen extends StatefulWidget {
  const RideShareHomeScreen({super.key});

  @override
  _RideShareHomeScreenState createState() => _RideShareHomeScreenState();
}

class _RideShareHomeScreenState extends State<RideShareHomeScreen> {
  final RideService _rideService = RideService();
  List<Ride> availableRides = [];
  String? _joinedRideId;
  final String currentUserId =
      'user123'; // Replace with FirebaseAuth.instance.currentUser!.uid
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _rideService.loadRides(context, (rides) {
      setState(() {
        availableRides = rides;
      });
    });
    _rideService.loadJoinedRide(context, (rideId) {
      setState(() {
        _joinedRideId = rideId;
      });
    });
    _rideService.addFakeRides(availableRides, (updatedRides) {
      setState(() {
        availableRides = updatedRides;
      });
    });
  }

  void _onItemTapped(int index) {
    if (mounted) {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  List<BottomNavigationBarItem> _buildBottomNavItems() {
    List<BottomNavigationBarItem> items = [
      BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
      BottomNavigationBarItem(icon: Icon(Icons.directions_car), label: 'Rides'),
    ];

    // Add chat option if user is in a ride
    if (_joinedRideId != null) {
      items.add(BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'));
    }

    items.add(
      BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
    );
    return items;
  }

  int _getCurrentNavIndex() {
    // Adjust the selected index based on available tabs
    if (_joinedRideId != null) {
      // When chat is available: Home(0), Rides(1), Chat(2), Profile(3)
      if (_selectedIndex >= 3) return 3; // Profile
      return _selectedIndex;
    } else {
      // When chat is not available: Home(0), Rides(1), Profile(2)
      if (_selectedIndex >= 2) return 2; // Profile
      return _selectedIndex;
    }
  }

  void _resetNavigationIfNeeded() {
    // Reset navigation to home or rides tab if currently on chat and no longer in a ride
    if (_selectedIndex == 2 && _joinedRideId == null) {
      _selectedIndex = 1; // Switch to rides tab
    }
    // Reset navigation if on profile tab and index is out of bounds
    if (_joinedRideId == null && _selectedIndex > 2) {
      _selectedIndex = 2; // Profile tab when no chat
    }
    if (_joinedRideId != null && _selectedIndex > 3) {
      _selectedIndex = 3; // Profile tab when chat is available
    }
  }

  @override
  void didUpdateWidget(RideShareHomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reset navigation when widget updates
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _resetNavigationIfNeeded();
        });
      }
    });
  }

  void _showChatAvailableSnackbar() {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Chat is now available! Tap the chat tab to communicate with your ride companions.',
          ),
          duration: Duration(seconds: 4),
          action: SnackBarAction(
            label: 'Open Chat',
            onPressed: () {
              setState(() {
                _selectedIndex = 2; // Switch to chat tab
              });
            },
          ),
        ),
      );
    }
  }

  Widget _buildCurrentTab() {
    if (_selectedIndex == 0) {
      return _buildHomeTab(context);
    } else if (_selectedIndex == 1) {
      return _buildRidesTab(context);
    } else if (_selectedIndex == 2) {
      if (_joinedRideId != null) {
        // Chat tab
        return ChatScreen(rideId: _joinedRideId!, currentUserId: currentUserId);
      } else {
        // Profile tab (when no chat available)
        return _buildProfileTab(context);
      }
    } else {
      // Profile tab (when chat is available, this is index 3)
      return _buildProfileTab(context);
    }
  }

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasLoggedIn', false);
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const SignInScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Ride Share',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: _buildCurrentTab(),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: Color(0xFF6B9EFF),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        currentIndex: _getCurrentNavIndex(),
        onTap: _onItemTapped,
        items: _buildBottomNavItems(),
      ),
    );
  }

  Widget _buildHomeTab(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Find a Ride',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: RideOptionButton(
                  title: 'Create Ride',
                  subtitle: 'Offer a ride to other students',
                  backgroundColor: Color(0xFFF2E8D5),
                  backgroundImage: 'assets/images/create.png',
                  onTap: () {
                    showCreateRideDialog(
                      context,
                      _rideService,
                      availableRides,
                      (updatedRides) {
                        setState(() {
                          availableRides = updatedRides;
                        });
                      },
                    );
                  },
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: RideOptionButton(
                  title: 'Join Ride',
                  subtitle: 'Find a ride offered by other students',
                  backgroundColor: Color.fromARGB(209, 254, 227, 211),
                  backgroundImage: 'assets/images/join.png',
                  onTap: () {
                    if (mounted) {
                      setState(() {
                        _selectedIndex = 1;
                      });
                    }
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 32),
          Text(
            'Available Rides',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 16),
          Expanded(
            child:
                availableRides.isEmpty
                    ? _buildEmptyState()
                    : ListView(
                      children:
                          availableRides.map((ride) {
                            return RideListItem(
                              ride: ride,
                              onJoin:
                                  () => _rideService.joinRide(
                                    context,
                                    availableRides,
                                    ride,
                                    currentUserId,
                                    (updatedRides) {
                                      setState(() {
                                        availableRides = updatedRides;
                                        _joinedRideId = ride.id;
                                      });
                                    },
                                  ),
                              onLeave:
                                  () => _rideService.leaveRide(
                                    context,
                                    availableRides,
                                    ride,
                                    _joinedRideId,
                                    (updatedRides) {
                                      setState(() {
                                        availableRides = updatedRides;
                                        _joinedRideId = null;
                                      });
                                    },
                                  ),
                              onDelete:
                                  () => _rideService.deleteRide(
                                    context,
                                    availableRides,
                                    ride,
                                    _joinedRideId,
                                    (updatedRides) {
                                      setState(() {
                                        availableRides = updatedRides;
                                        if (_joinedRideId == ride.id) {
                                          _joinedRideId = null;
                                        }
                                      });
                                    },
                                  ),
                              currentUserId: currentUserId,
                              hasJoinedRide: _joinedRideId != null,
                              isJoinedRide: _joinedRideId == ride.id,
                            );
                          }).toList(),
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildRidesTab(BuildContext context) {
    if (_joinedRideId != null) {
      final joinedRide = availableRides.firstWhere(
        (ride) => ride.id == _joinedRideId,
        orElse: () {
          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Joined ride not found')));
          }
          return Ride(
            id: '',
            from: '',
            destination: '',
            seatsLeft: 0,
            date: '',
            time: '',
            genderPreference: '',
            vehicleType: '',
            creatorId: '',
          );
        },
      );
      if (joinedRide.id.isNotEmpty) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your Joined Ride',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 16),
              RideListItem(
                ride: joinedRide,
                onJoin: () {},
                onLeave:
                    () => _rideService.leaveRide(
                      context,
                      availableRides,
                      joinedRide,
                      _joinedRideId,
                      (updatedRides) {
                        setState(() {
                          availableRides = updatedRides;
                          _joinedRideId = null;
                        });
                      },
                    ),
                onDelete: () {},
                currentUserId: currentUserId,
                hasJoinedRide: true,
                isJoinedRide: true,
              ),
            ],
          ),
        );
      }
    }
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Available Rides',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 16),
          Expanded(
            child:
                availableRides.isEmpty
                    ? _buildEmptyState()
                    : ListView(
                      children:
                          availableRides.map((ride) {
                            return RideListItem(
                              ride: ride,
                              onJoin:
                                  () => _rideService.joinRide(
                                    context,
                                    availableRides,
                                    ride,
                                    currentUserId,
                                    (updatedRides) {
                                      setState(() {
                                        availableRides = updatedRides;
                                        _joinedRideId = ride.id;
                                      });
                                    },
                                  ),
                              onLeave:
                                  () => _rideService.leaveRide(
                                    context,
                                    availableRides,
                                    ride,
                                    _joinedRideId,
                                    (updatedRides) {
                                      setState(() {
                                        availableRides = updatedRides;
                                        _joinedRideId = null;
                                      });
                                    },
                                  ),
                              onDelete:
                                  () => _rideService.deleteRide(
                                    context,
                                    availableRides,
                                    ride,
                                    _joinedRideId,
                                    (updatedRides) {
                                      setState(() {
                                        availableRides = updatedRides;
                                        if (_joinedRideId == ride.id) {
                                          _joinedRideId = null;
                                        }
                                      });
                                    },
                                  ),
                              currentUserId: currentUserId,
                              hasJoinedRide: _joinedRideId != null,
                              isJoinedRide: _joinedRideId == ride.id,
                            );
                          }).toList(),
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileTab(BuildContext context) {
    final userRides =
        availableRides
            .where((ride) => ride.creatorId == currentUserId)
            .toList();
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Profile',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          Text(
            'User ID: $currentUserId',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          SizedBox(height: 16),
          Text(
            'Your Created Rides',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          Expanded(
            child:
                userRides.isEmpty
                    ? _buildEmptyState(message: 'No rides created')
                    : ListView(
                      children:
                          userRides.map((ride) {
                            return RideListItem(
                              ride: ride,
                              onJoin: () {},
                              onLeave: () {},
                              onDelete:
                                  () => _rideService.deleteRide(
                                    context,
                                    availableRides,
                                    ride,
                                    _joinedRideId,
                                    (updatedRides) {
                                      setState(() {
                                        availableRides = updatedRides;
                                        if (_joinedRideId == ride.id) {
                                          _joinedRideId = null;
                                        }
                                      });
                                    },
                                  ),
                              currentUserId: currentUserId,
                              hasJoinedRide: _joinedRideId != null,
                              isJoinedRide: false,
                            );
                          }).toList(),
                    ),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _logout(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              minimumSize: Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: const Text(
              'Log Out',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState({String message = 'No rides available'}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.directions_car, size: 50, color: Colors.grey),
          SizedBox(height: 16),
          Text(message, style: TextStyle(fontSize: 18, color: Colors.grey)),
        ],
      ),
    );
  }
}

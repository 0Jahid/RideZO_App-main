import 'package:flutter/material.dart';
import 'package:ride_zo/models/ride_model.dart';
import 'package:ride_zo/services/ride_service.dart';
import 'package:ride_zo/utils/date_time_utils.dart';

void showCreateRideDialog(
  BuildContext context,
  RideService rideService,
  List<Ride> availableRides,
  Function(List<Ride>) onRideCreated,
) {
  final fromController = TextEditingController();
  final destinationController = TextEditingController();
  final dateController = TextEditingController();
  final timeController = TextEditingController();
  String selectedGender = 'Any';
  String selectedVehicle = 'Car';
  int cngSeats = 2;

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Create a Ride'),
        content: SingleChildScrollView(
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                children: [
                  TextField(
                    controller: fromController,
                    decoration: const InputDecoration(hintText: 'From'),
                  ),
                  TextField(
                    controller: destinationController,
                    decoration: const InputDecoration(hintText: 'To'),
                  ),
                  DropdownButton<String>(
                    value: selectedGender,
                    items:
                        ['Male', 'Female', 'Any']
                            .map(
                              (gender) => DropdownMenuItem(
                                value: gender,
                                child: Text(gender),
                              ),
                            )
                            .toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedGender = value!;
                      });
                    },
                    hint: Text('Select Gender Preference'),
                    isExpanded: true,
                  ),
                  DropdownButton<String>(
                    value: selectedVehicle,
                    items:
                        ['Car', 'CNG']
                            .map(
                              (vehicle) => DropdownMenuItem(
                                value: vehicle,
                                child: Text(vehicle),
                              ),
                            )
                            .toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedVehicle = value!;
                        if (selectedVehicle == 'Car') {
                          cngSeats = 3;
                        } else {
                          cngSeats = 2;
                        }
                      });
                    },
                    hint: Text('Select Vehicle Type'),
                    isExpanded: true,
                  ),
                  if (selectedVehicle == 'CNG')
                    DropdownButton<int>(
                      value: cngSeats,
                      items:
                          [2, 3]
                              .map(
                                (seats) => DropdownMenuItem(
                                  value: seats,
                                  child: Text('$seats Seats'),
                                ),
                              )
                              .toList(),
                      onChanged: (value) {
                        setState(() {
                          cngSeats = value!;
                        });
                      },
                      hint: Text('Select CNG Seats'),
                      isExpanded: true,
                    ),
                  TextField(
                    controller: dateController,
                    decoration: InputDecoration(
                      hintText: 'Date',
                      suffixIcon: IconButton(
                        icon: Icon(Icons.calendar_today),
                        onPressed:
                            () => DateTimeUtils.selectDate(
                              context,
                              dateController,
                              () {
                                setState(() {});
                              },
                            ),
                      ),
                    ),
                    readOnly: true,
                  ),
                  TextField(
                    controller: timeController,
                    decoration: InputDecoration(
                      hintText: 'Time',
                      suffixIcon: IconButton(
                        icon: Icon(Icons.access_time),
                        onPressed:
                            () => DateTimeUtils.selectTime(
                              context,
                              dateController,
                              timeController,
                              () {
                                setState(() {});
                              },
                            ),
                      ),
                    ),
                    readOnly: true,
                  ),
                ],
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              rideService.createRide(
                context,
                availableRides,
                fromController.text,
                destinationController.text,
                dateController.text,
                timeController.text,
                selectedGender,
                selectedVehicle,
                cngSeats,
                (updatedRides) {
                  fromController.clear();
                  destinationController.clear();
                  dateController.clear();
                  timeController.clear();
                  selectedGender = 'Any';
                  selectedVehicle = 'Car';
                  cngSeats = 2;
                  Navigator.pop(context);
                  onRideCreated(updatedRides);
                },
              );
            },
            child: const Text('Create Ride'),
          ),
        ],
      );
    },
  );
}

// historical-touch: 2025-06-24T16:05:00 by 0Jahid

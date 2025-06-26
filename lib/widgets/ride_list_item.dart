import 'package:flutter/material.dart';
import 'package:ride_zo/models/ride_model.dart';

class RideListItem extends StatelessWidget {
  final Ride ride;
  final VoidCallback onJoin;
  final VoidCallback onLeave;
  final VoidCallback onDelete;
  final String currentUserId;
  final bool hasJoinedRide;
  final bool isJoinedRide;

  const RideListItem({
    super.key,
    required this.ride,
    required this.onJoin,
    required this.onLeave,
    required this.onDelete,
    required this.currentUserId,
    required this.hasJoinedRide,
    this.isJoinedRide = false,
  });

  @override
  Widget build(BuildContext context) {
    bool isOwnRide = ride.creatorId == currentUserId;
    bool canJoin =
        ride.seatsLeft > 0 && !isOwnRide && !hasJoinedRide && !isJoinedRide;

    return Semantics(
      label: 'Ride from ${ride.from} to ${ride.destination}',
      child: Container(
        margin: EdgeInsets.only(bottom: 12),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'From: ${ride.from}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Text(
                    'To: ${ride.destination}',
                    style: TextStyle(fontSize: 14, color: Color(0xFF6B9EFF)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          'Vehicle: ${ride.vehicleType}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: 16),
                      Flexible(
                        child: Text(
                          'Gender: ${ride.genderPreference}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Date: ${ride.date} | Time: ${ride.time}',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${ride.seatsLeft} seats left',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
                if (isJoinedRide)
                  TextButton(
                    onPressed: onLeave,
                    child: Text(
                      'Leave Ride',
                      style: TextStyle(color: Colors.red),
                    ),
                  )
                else if (isOwnRide)
                  Row(
                    children: [
                      TextButton(
                        onPressed: null,
                        child: Text(
                          'Your Ride',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                      TextButton(
                        onPressed: onDelete,
                        child: Text(
                          'Delete',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  )
                else
                  TextButton(
                    onPressed: canJoin ? onJoin : null,
                    child: Text(
                      'Join Ride',
                      style: TextStyle(
                        color: canJoin ? Color(0xFF6B9EFF) : Colors.grey,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// historical-touch: 2025-06-26T09:30:00 by 0Jahid

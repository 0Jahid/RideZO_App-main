class Ride {
  final String id;
  final String from;
  final String destination;
  int seatsLeft;
  final String date;
  final String time;
  final String genderPreference;
  final String vehicleType;
  final String creatorId;

  Ride({
    required this.id,
    required this.from,
    required this.destination,
    required this.seatsLeft,
    required this.date,
    required this.time,
    required this.genderPreference,
    required this.vehicleType,
    required this.creatorId,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'from': from,
        'destination': destination,
        'seatsLeft': seatsLeft,
        'date': date,
        'time': time,
        'genderPreference': genderPreference,
        'vehicleType': vehicleType,
        'creatorId': creatorId,
      };

  factory Ride.fromJson(Map<String, dynamic> json) => Ride(
        id: json['id'],
        from: json['from'],
        destination: json['destination'],
        seatsLeft: json['seatsLeft'],
        date: json['date'],
        time: json['time'],
        genderPreference: json['genderPreference'],
        vehicleType: json['vehicleType'],
        creatorId: json['creatorId'],
      );
}
// historical-touch: 2025-06-02T09:00:00 by 0Jahid

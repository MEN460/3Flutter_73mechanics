class ServiceRequest {
  final int id;
  final int carOwnerId;
  final int? mechanicId;
  final double latitude;
  final double longitude;
  final String description;
  final String status;
  final DateTime? acceptedAt;
  final double? distance;
   final String? carModel;
  final String? carPlate;
  final String? ownerName;

  ServiceRequest({
    required this.id,
    required this.carOwnerId,
    this.mechanicId,
    required this.latitude,
    required this.longitude,
    required this.description,
    required this.status,
    this.acceptedAt,
    this.distance,
     this.carModel,
    this.carPlate,
    this.ownerName,
  });

  factory ServiceRequest.fromJson(Map<String, dynamic> json) {
    return ServiceRequest(
      id: json['id'],
      carOwnerId: json['car_owner_id'],
      mechanicId: json['mechanic_id'],
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      description: json['description'],
      status: json['status'],
      acceptedAt: json['accepted_at'] != null
          ? DateTime.parse(json['accepted_at'])
          : null,
       distance: json['distance'] != null
          ? (json['distance'] is int
                ? json['distance'].toDouble()
                : json['distance'])
          : null,

      carModel: json['car_model'],
      carPlate: json['car_plate'],
      ownerName: json['owner_name'],
    );
  }

  ServiceRequest copyWith({
    int? id,
    int? carOwnerId,
    int? mechanicId,
    double? latitude,
    double? longitude,
    String? description,
    String? status,
    DateTime? acceptedAt,
    double? distance,
    String? carModel,
    String? carPlate,
    String? ownerName,
  }) {
    return ServiceRequest(
      id: id ?? this.id,
      carOwnerId: carOwnerId ?? this.carOwnerId,
      mechanicId: mechanicId ?? this.mechanicId,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      description: description ?? this.description,
      status: status ?? this.status,
      acceptedAt: acceptedAt ?? this.acceptedAt,
      distance: distance ?? this.distance,
      carModel: carModel ?? this.carModel,
      carPlate: carPlate ?? this.carPlate,
      ownerName: ownerName ?? this.ownerName,
    );
  }
}

class MarketplaceItem {
  final int id;
  final String serviceName;
  final String description;
  final String ownerName;
  final String contact;
  final String location;
  final double perDayCost;
  final String imageUrl;
  final String availability;

  MarketplaceItem({
    required this.id,
    required this.serviceName,
    required this.description,
    required this.ownerName,
    required this.contact,
    required this.location,
    required this.perDayCost,
    required this.imageUrl,
    required this.availability,
  });

  factory MarketplaceItem.fromJson(Map<String, dynamic> json) {
    return MarketplaceItem(
      id: json['id'] as int,
      serviceName: json['service_name'] as String,
      description: json['description'] as String,
      ownerName: json['owner_name'] as String,
      contact: json['contact'] as String,
      location: json['location'] as String,
      perDayCost: (json['per_day_cost'] as num).toDouble(),
      imageUrl: json['image_url'] as String,
      availability: json['availability'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'service_name': serviceName,
      'description': description,
      'owner_name': ownerName,
      'contact': contact,
      'location': location,
      'per_day_cost': perDayCost,
      'image_url': imageUrl,
      'availability': availability,
    };
  }
}

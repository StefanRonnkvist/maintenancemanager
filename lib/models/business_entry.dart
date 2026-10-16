import 'dart:convert';

class BusinessLocation {
  const BusinessLocation({
    required this.name,
    required this.address,
    required this.directPhone,
    this.nearestAirport = '',
  });

  final String name;
  final String address;
  final String directPhone;
  final String nearestAirport;

  Map<String, String> toJson() => {
    'name': name,
    'address': address,
    'directPhone': directPhone,
    'nearestAirport': nearestAirport,
  };

  factory BusinessLocation.fromJson(Map<String, dynamic> json) =>
      BusinessLocation(
        name: json['name'] as String? ?? '',
        address: json['address'] as String? ?? '',
        directPhone: json['directPhone'] as String? ?? '',
        nearestAirport: json['nearestAirport'] as String? ?? '',
      );
}

class BusinessEntry {
  const BusinessEntry({
    required this.name,
    required this.address,
    required this.directPhone,
    this.directPhoneExtension = '',
    this.businessType = '',
    this.cellPhone = '',
    this.email = '',
    this.businessName = '',
    this.locationName = '',
    this.nearestAirport = '',
    this.locations = const [],
    this.airports = const [],
  });

  final String name;
  final String address;
  final String directPhone;
  final String directPhoneExtension;
  final String businessType;
  final String cellPhone;
  final String email;
  final String businessName;
  final String locationName;
  final String nearestAirport;
  final List<BusinessLocation> locations;
  final List<String> airports;

  Map<String, Object?> toJson() => {
    'name': name,
    'address': address,
    'directPhone': directPhone,
    'directPhoneExtension': directPhoneExtension,
    'businessType': businessType,
    'cellPhone': cellPhone,
    'email': email,
    'businessName': businessName,
    'locationName': locationName,
    'nearestAirport': nearestAirport,
    'locations': jsonEncode(
      locations.map((location) => location.toJson()).toList(),
    ),
    'airports': jsonEncode(airports),
  };

  factory BusinessEntry.fromJson(Map<String, dynamic> json) => BusinessEntry(
    name: json['name'] as String? ?? '',
    address: json['address'] as String? ?? '',
    directPhone: json['directPhone'] as String? ?? '',
    directPhoneExtension: json['directPhoneExtension'] as String? ?? '',
    businessType: json['businessType'] as String? ?? '',
    cellPhone: json['cellPhone'] as String? ?? '',
    email: json['email'] as String? ?? '',
    businessName: json['businessName'] as String? ?? '',
    locationName: json['locationName'] as String? ?? '',
    nearestAirport: json['nearestAirport'] as String? ?? '',
    locations: _decodeLocations(json['locations']),
    airports: _decodeAirports(json['airports']),
  );

  static List<BusinessLocation> _decodeLocations(Object? value) {
    Object? decoded = value;
    if (decoded is String) {
      try {
        decoded = jsonDecode(decoded);
      } catch (_) {
        return const [];
      }
    }
    if (decoded is! List) return const [];
    return decoded
        .whereType<Map>()
        .map(
          (item) => BusinessLocation.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList(growable: false);
  }

  static List<String> _decodeAirports(Object? value) {
    Object? decoded = value;
    if (decoded is String) {
      try {
        decoded = jsonDecode(decoded);
      } catch (_) {
        return const [];
      }
    }
    if (decoded is! List) return const [];
    return decoded.whereType<String>().toList(growable: false);
  }
}

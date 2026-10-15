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
}

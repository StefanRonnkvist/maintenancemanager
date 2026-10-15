class EquipmentRecord {
  const EquipmentRecord({
    required this.localName,
    required this.localNumber,
    required this.manufacturerName,
    required this.equipmentName,
    required this.equipmentModel,
    required this.serialNumber,
    required this.maintenanceManual,
    required this.publisher,
    required this.businessName,
    required this.locationName,
  });

  static const List<String> columns = [
    'Business Name',
    'Location Name',
    'Local Name',
    'Local Number',
    'Manufacturer Name',
    'Equipment Name',
    'Equipment Model',
    'Serial Number',
    'Maintenance Manual',
    'Publisher',
  ];

  final String localName;
  final String localNumber;
  final String manufacturerName;
  final String equipmentName;
  final String equipmentModel;
  final String serialNumber;
  final String maintenanceManual;
  final String publisher;
  final String businessName;
  final String locationName;

  List<String> get values => [
    businessName,
    locationName,
    localName,
    localNumber,
    manufacturerName,
    equipmentName,
    equipmentModel,
    serialNumber,
    maintenanceManual,
    publisher,
  ];
}

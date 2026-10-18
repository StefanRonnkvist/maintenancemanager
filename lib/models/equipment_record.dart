/// Values captured for one equipment row and persisted by EquipmentTab.
class EquipmentRecord {
  const EquipmentRecord({
    required this.businessName,
    required this.locationName,
    required this.equipmentCategory,
    required this.localName,
    required this.localNumber,
    required this.manufacturerName,
    required this.equipmentName,
    required this.equipmentModel,
    required this.serialNumber,
    required this.maintenanceManual,
    required this.publisher,
  });

  final String businessName;
  final String locationName;
  final String equipmentCategory;
  final String localName;
  final String localNumber;
  final String manufacturerName;
  final String equipmentName;
  final String equipmentModel;
  final String serialNumber;
  final String maintenanceManual;
  final String publisher;

  /// Converts the record to the key/value shape used by local storage and CSV.
  Map<String, Object> toJson() => {
    'businessName': businessName,
    'locationName': locationName,
    'equipmentCategory': equipmentCategory,
    'localName': localName,
    'localNumber': localNumber,
    'manufacturerName': manufacturerName,
    'equipmentName': equipmentName,
    'equipmentModel': equipmentModel,
    'serialNumber': serialNumber,
    'maintenanceManual': maintenanceManual,
    'publisher': publisher,
  };

  /// Rebuilds a record and defaults absent fields for backward compatibility.
  factory EquipmentRecord.fromJson(Map<String, dynamic> json) =>
      EquipmentRecord(
        businessName: json['businessName'] as String? ?? '',
        locationName: json['locationName'] as String? ?? '',
        equipmentCategory: json['equipmentCategory'] as String? ?? '',
        localName: json['localName'] as String? ?? '',
        localNumber: json['localNumber'] as String? ?? '',
        manufacturerName: json['manufacturerName'] as String? ?? '',
        equipmentName: json['equipmentName'] as String? ?? '',
        equipmentModel: json['equipmentModel'] as String? ?? '',
        serialNumber: json['serialNumber'] as String? ?? '',
        maintenanceManual: json['maintenanceManual'] as String? ?? '',
        publisher: json['publisher'] as String? ?? '',
      );
}

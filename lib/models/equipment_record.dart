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
    required this.subsection1LocalName,
    required this.subsection1LocalNumber,
    required this.subsection1ManufacturerName,
    required this.subsection1EquipmentName,
    required this.subsection1EquipmentModel,
    required this.subsection1SerialNumber,
    required this.subsection1MaintenanceManual,
    required this.subsection1Publisher,
    required this.subsection2LocalName,
    required this.subsection2LocalNumber,
    required this.subsection2ManufacturerName,
    required this.subsection2EquipmentName,
    required this.subsection2EquipmentModel,
    required this.subsection2SerialNumber,
    required this.subsection2MaintenanceManual,
    required this.subsection2Publisher,
    required this.subsection3LocalName,
    required this.subsection3LocalNumber,
    required this.subsection3ManufacturerName,
    required this.subsection3EquipmentName,
    required this.subsection3EquipmentModel,
    required this.subsection3SerialNumber,
    required this.subsection3MaintenanceManual,
    required this.subsection3Publisher,
    required this.subsection4LocalName,
    required this.subsection4LocalNumber,
    required this.subsection4ManufacturerName,
    required this.subsection4EquipmentName,
    required this.subsection4EquipmentModel,
    required this.subsection4SerialNumber,
    required this.subsection4MaintenanceManual,
    required this.subsection4Publisher,
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
  final String subsection1LocalName;
  final String subsection1LocalNumber;
  final String subsection1ManufacturerName;
  final String subsection1EquipmentName;
  final String subsection1EquipmentModel;
  final String subsection1SerialNumber;
  final String subsection1MaintenanceManual;
  final String subsection1Publisher;
  final String subsection2LocalName;
  final String subsection2LocalNumber;
  final String subsection2ManufacturerName;
  final String subsection2EquipmentName;
  final String subsection2EquipmentModel;
  final String subsection2SerialNumber;
  final String subsection2MaintenanceManual;
  final String subsection2Publisher;
  final String subsection3LocalName;
  final String subsection3LocalNumber;
  final String subsection3ManufacturerName;
  final String subsection3EquipmentName;
  final String subsection3EquipmentModel;
  final String subsection3SerialNumber;
  final String subsection3MaintenanceManual;
  final String subsection3Publisher;
  final String subsection4LocalName;
  final String subsection4LocalNumber;
  final String subsection4ManufacturerName;
  final String subsection4EquipmentName;
  final String subsection4EquipmentModel;
  final String subsection4SerialNumber;
  final String subsection4MaintenanceManual;
  final String subsection4Publisher;

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
    'subsection1LocalName': subsection1LocalName,
    'subsection1LocalNumber': subsection1LocalNumber,
    'subsection1ManufacturerName': subsection1ManufacturerName,
    'subsection1EquipmentName': subsection1EquipmentName,
    'subsection1EquipmentModel': subsection1EquipmentModel,
    'subsection1SerialNumber': subsection1SerialNumber,
    'subsection1MaintenanceManual': subsection1MaintenanceManual,
    'subsection1Publisher': subsection1Publisher,
    'subsection2LocalName': subsection2LocalName,
    'subsection2LocalNumber': subsection2LocalNumber,
    'subsection2ManufacturerName': subsection2ManufacturerName,
    'subsection2EquipmentName': subsection2EquipmentName,
    'subsection2EquipmentModel': subsection2EquipmentModel,
    'subsection2SerialNumber': subsection2SerialNumber,
    'subsection2MaintenanceManual': subsection2MaintenanceManual,
    'subsection2Publisher': subsection2Publisher,
    'subsection3LocalName': subsection3LocalName,
    'subsection3LocalNumber': subsection3LocalNumber,
    'subsection3ManufacturerName': subsection3ManufacturerName,
    'subsection3EquipmentName': subsection3EquipmentName,
    'subsection3EquipmentModel': subsection3EquipmentModel,
    'subsection3SerialNumber': subsection3SerialNumber,
    'subsection3MaintenanceManual': subsection3MaintenanceManual,
    'subsection3Publisher': subsection3Publisher,
    'subsection4LocalName': subsection4LocalName,
    'subsection4LocalNumber': subsection4LocalNumber,
    'subsection4ManufacturerName': subsection4ManufacturerName,
    'subsection4EquipmentName': subsection4EquipmentName,
    'subsection4EquipmentModel': subsection4EquipmentModel,
    'subsection4SerialNumber': subsection4SerialNumber,
    'subsection4MaintenanceManual': subsection4MaintenanceManual,
    'subsection4Publisher': subsection4Publisher,
  };

  /// Rebuilds a record and defaults absent fields for backward compatibility.
  factory EquipmentRecord.fromJson(
    Map<String, dynamic> json,
  ) => EquipmentRecord(
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
    subsection1LocalName: json['subsection1LocalName'] as String? ?? '',
    subsection1LocalNumber: json['subsection1LocalNumber'] as String? ?? '',
    subsection1ManufacturerName:
        json['subsection1ManufacturerName'] as String? ?? '',
    subsection1EquipmentName: json['subsection1EquipmentName'] as String? ?? '',
    subsection1EquipmentModel:
        json['subsection1EquipmentModel'] as String? ?? '',
    subsection1SerialNumber: json['subsection1SerialNumber'] as String? ?? '',
    subsection1MaintenanceManual:
        json['subsection1MaintenanceManual'] as String? ?? '',
    subsection1Publisher: json['subsection1Publisher'] as String? ?? '',
    subsection2LocalName: json['subsection2LocalName'] as String? ?? '',
    subsection2LocalNumber: json['subsection2LocalNumber'] as String? ?? '',
    subsection2ManufacturerName:
        json['subsection2ManufacturerName'] as String? ?? '',
    subsection2EquipmentName: json['subsection2EquipmentName'] as String? ?? '',
    subsection2EquipmentModel:
        json['subsection2EquipmentModel'] as String? ?? '',
    subsection2SerialNumber: json['subsection2SerialNumber'] as String? ?? '',
    subsection2MaintenanceManual:
        json['subsection2MaintenanceManual'] as String? ?? '',
    subsection2Publisher: json['subsection2Publisher'] as String? ?? '',
    subsection3LocalName: json['subsection3LocalName'] as String? ?? '',
    subsection3LocalNumber: json['subsection3LocalNumber'] as String? ?? '',
    subsection3ManufacturerName:
        json['subsection3ManufacturerName'] as String? ?? '',
    subsection3EquipmentName: json['subsection3EquipmentName'] as String? ?? '',
    subsection3EquipmentModel:
        json['subsection3EquipmentModel'] as String? ?? '',
    subsection3SerialNumber: json['subsection3SerialNumber'] as String? ?? '',
    subsection3MaintenanceManual:
        json['subsection3MaintenanceManual'] as String? ?? '',
    subsection3Publisher: json['subsection3Publisher'] as String? ?? '',
    subsection4LocalName: json['subsection4LocalName'] as String? ?? '',
    subsection4LocalNumber: json['subsection4LocalNumber'] as String? ?? '',
    subsection4ManufacturerName:
        json['subsection4ManufacturerName'] as String? ?? '',
    subsection4EquipmentName: json['subsection4EquipmentName'] as String? ?? '',
    subsection4EquipmentModel:
        json['subsection4EquipmentModel'] as String? ?? '',
    subsection4SerialNumber: json['subsection4SerialNumber'] as String? ?? '',
    subsection4MaintenanceManual:
        json['subsection4MaintenanceManual'] as String? ?? '',
    subsection4Publisher: json['subsection4Publisher'] as String? ?? '',
  );
}

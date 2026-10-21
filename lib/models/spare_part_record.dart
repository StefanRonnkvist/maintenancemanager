/// Values captured for a single spare-part inventory row.
class SparePartRecord {
  const SparePartRecord({
    required this.oemPartNumber,
    required this.oemDescription,
    required this.vendorPartNumber,
    required this.vendorDescription,
    required this.serialNumber,
    required this.vendorName,
    required this.locationName,
    required this.quantityInStock,
    required this.location,
  });

  final String oemPartNumber;
  final String oemDescription;
  final String vendorPartNumber;
  final String vendorDescription;
  final String serialNumber;
  final String vendorName;
  final String locationName;
  final String quantityInStock;
  final String location;

  /// Keeps table values in the same order as [SparePartsTable]'s columns.
  List<String> get values => [
    oemPartNumber,
    oemDescription,
    vendorPartNumber,
    vendorDescription,
    serialNumber,
    vendorName,
    locationName,
    quantityInStock,
    location,
  ];

  /// Converts this record to the map persisted by SparePartsTab.
  Map<String, Object?> toJson() => {
    'oemPartNumber': oemPartNumber,
    'oemDescription': oemDescription,
    'vendorPartNumber': vendorPartNumber,
    'vendorDescription': vendorDescription,
    'serialNumber': serialNumber,
    'vendorName': vendorName,
    'locationName': locationName,
    'quantityInStock': quantityInStock,
    'storageLocation': location,
  };

  /// Restores a record from local storage or database/import field aliases.
  /// Unknown fields are ignored; missing values are shown as empty strings.
  factory SparePartRecord.fromJson(Map<String, dynamic> json) =>
      SparePartRecord(
        oemPartNumber: _readString(json, const [
          'oemPartNumber',
          'oem_part_number',
          'OEM Part Number',
        ]),
        oemDescription: _readString(json, const [
          'oemDescription',
          'oem_description',
          'OEM Description',
        ]),
        vendorPartNumber: _readString(json, const [
          'vendorPartNumber',
          'vendor_part_number',
          'Vendor Part Number',
        ]),
        vendorDescription: _readString(json, const [
          'vendorDescription',
          'vendor_description',
          'Vendor Description',
        ]),
        serialNumber: _readString(json, const [
          'serialNumber',
          'serial_number',
          'Serial Number',
        ]),
        vendorName: _readString(json, const [
          'vendorName',
          'vendor_name',
          'Vendor Name',
        ]),
        locationName: _readString(json, const [
          'locationName',
          'location_name',
          'Location Name',
        ]),
        quantityInStock: _readString(json, const [
          'quantityInStock',
          'quantity_in_stock',
          'Quantity in Stock',
        ]),
        location: _readString(json, const [
          'location',
          'storageLocation',
          'storage_location',
          'Storage Location',
        ]),
      );

  static String _readString(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value != null) return value.toString();
    }
    return '';
  }
}

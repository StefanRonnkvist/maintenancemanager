class SparePartRecord {
  const SparePartRecord({
    required this.oemPartNumber,
    required this.oemDescription,
    required this.vendorPartNumber,
    required this.vendorDescription,
    required this.serialNumber,
    required this.vendorName,
    required this.quantityInStock,
    required this.location,
  });

  static const List<String> columns = [
    'OEM Part Number',
    'OEM Description',
    'Vendor Part Number',
    'Vendor Description',
    'Serial Number',
    'Vendor Name',
    'Quantity in Stock',
    'Location',
  ];

  final String oemPartNumber;
  final String oemDescription;
  final String vendorPartNumber;
  final String vendorDescription;
  final String serialNumber;
  final String vendorName;
  final String quantityInStock;
  final String location;

  List<String> get values => [
    oemPartNumber,
    oemDescription,
    vendorPartNumber,
    vendorDescription,
    serialNumber,
    vendorName,
    quantityInStock,
    location,
  ];
}

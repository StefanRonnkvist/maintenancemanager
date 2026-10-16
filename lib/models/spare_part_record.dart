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

  Map<String, Object?> toJson() => {
    'oemPartNumber': oemPartNumber,
    'oemDescription': oemDescription,
    'vendorPartNumber': vendorPartNumber,
    'vendorDescription': vendorDescription,
    'serialNumber': serialNumber,
    'vendorName': vendorName,
    'quantityInStock': quantityInStock,
    'location': location,
  };

  factory SparePartRecord.fromJson(Map<String, dynamic> json) =>
      SparePartRecord(
        oemPartNumber: json['oemPartNumber'] as String? ?? '',
        oemDescription: json['oemDescription'] as String? ?? '',
        vendorPartNumber: json['vendorPartNumber'] as String? ?? '',
        vendorDescription: json['vendorDescription'] as String? ?? '',
        serialNumber: json['serialNumber'] as String? ?? '',
        vendorName: json['vendorName'] as String? ?? '',
        quantityInStock: json['quantityInStock'] as String? ?? '',
        location: json['location'] as String? ?? '',
      );
}

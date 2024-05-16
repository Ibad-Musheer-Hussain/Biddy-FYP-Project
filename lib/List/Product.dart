// ignore_for_file: file_names, non_constant_identifier_names

class Product {
  final String brand, model;
  final List<String> uploadedImageUrls;
  final String title;
  final String id;
  final String collectionValue;
  final String description;
  final String fuel;
  final String transmission;
  final String city;
  int year;
  int kms;
  int price;
  int timestamp;
  int timestamp2;

  Product(
      {required this.brand,
      required this.model,
      required this.year,
      required this.title,
      required this.id,
      required this.price,
      required this.kms,
      required this.city,
      required this.transmission,
      required this.collectionValue,
      required this.timestamp,
      required this.description,
      required this.fuel,
      required this.timestamp2,
      required this.uploadedImageUrls});

  factory Product.fromMap(Map<String, dynamic> data) {
    final Map<String, dynamic> castedData = data;
    final List<dynamic> picsDynamic = castedData['pics'] ?? [];

    // Explicitly cast 'picsDynamic' to 'List<String>'
    final List<String> uploadedImageUrls =
        picsDynamic.map((pic) => pic.toString()).toList();

    return Product(
        brand: castedData['brand'],
        model: castedData['model'],
        year: castedData['year'],
        title: castedData['title'],
        uploadedImageUrls: uploadedImageUrls,
        id: castedData['id'],
        fuel: castedData['fuel'],
        city: castedData['city'],
        transmission: castedData['transmission'],
        kms: castedData['kms'],
        collectionValue: castedData['collectionValue'],
        timestamp: castedData['timestamp'],
        description: castedData['description'],
        timestamp2: castedData['timestamp2'],
        price: castedData['price']);
  }
}

List<Product> Sedans = [
  Product(
      brand: "asd",
      model: "asd",
      year: 49,
      uploadedImageUrls: [],
      title: '',
      id: " ",
      fuel: '',
      city: "Karachi",
      transmission: "Automatic",
      kms: 123,
      timestamp: 123,
      timestamp2: 123,
      collectionValue: '',
      description: '',
      price: 12),
];

List<Product> PowerTools = [
  Product(
      brand: "asd",
      model: "asd",
      year: 49,
      uploadedImageUrls: [],
      title: '',
      fuel: '',
      city: "Karachi",
      transmission: "Automatic",
      kms: 123,
      timestamp: 123,
      timestamp2: 123,
      description: '',
      collectionValue: '',
      id: " ",
      price: 12),
];

class Vehicle {
  final String plateNo;
  final String carMake;
  final String carModel;
  final String carColor;

  Vehicle({this.plateNo, this.carMake, this.carModel, this.carColor});

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
        plateNo: json['plate_no'],
        carMake: json['car_make'],
        carModel: json['car_model'],
        carColor: json['car_color']);
  }
}

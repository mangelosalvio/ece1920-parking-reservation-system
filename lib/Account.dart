import 'package:parking_reservation_system/Vehicle.dart';

class Account {
  String idNo;
  String name;
  String accountType;
  int creditsAvailable;
  List<Vehicle> vehicles;

  Account(
      {this.idNo,
      this.name,
      this.accountType,
      this.vehicles,
      this.creditsAvailable});

  factory Account.fromJson(Map<String, dynamic> json) {
    var vehicles = json['vehicles'] as List;

    List<Vehicle> _vehicles = vehicles.map((o) => Vehicle.fromJson(o)).toList();
    return Account(
        idNo: json['id_no'],
        name: json['name'],
        accountType: json['account_type'],
        creditsAvailable: json['credits_available'],
        vehicles: _vehicles);
  }
}

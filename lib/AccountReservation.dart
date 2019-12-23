import 'package:parking_reservation_system/Account.dart';
import 'package:timezone/timezone.dart';

class AccountReservation {
  String id;
  String slotNo;
  int reservationNo;
  Account account;
  DateTime reservationDateTime;
  DateTime estimatedDateOfArrival;

  AccountReservation(
      {this.id,
      this.slotNo,
      this.reservationNo,
      this.account,
      this.reservationDateTime,
      this.estimatedDateOfArrival});

  factory AccountReservation.fromJson(Map<String, dynamic> json) {
    Account account = Account.fromJson(json['account']);
    return AccountReservation(
        id: json['_id'],
        slotNo: json['slot_no'],
        reservationNo: json['reservation_no'],
        account: account,
        reservationDateTime: TZDateTime.from(
            DateTime.parse(json['reservation_datetime']),
            getLocation('Asia/Manila')),
        estimatedDateOfArrival: TZDateTime.from(
            DateTime.parse(json['est_date_of_arrival']),
            getLocation('Asia/Manila')));
  }
}

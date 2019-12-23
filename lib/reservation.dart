import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:parking_reservation_system/AccountReservation.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Reservation extends StatelessWidget {
  final AccountReservation accountReservation;
  final String slotNo;

  const Reservation({Key key, this.accountReservation, this.slotNo})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return ReservationScreen(
        title: "Reservation",
        accountReservation: accountReservation,
        slotNo: slotNo);
  }
}

class ReservationScreen extends StatefulWidget {
  final String title;
  final AccountReservation accountReservation;
  final String slotNo;
  const ReservationScreen(
      {Key key, this.title, this.accountReservation, this.slotNo})
      : super(key: key);

  @override
  _ReservationScreen createState() => _ReservationScreen();
}

class _ReservationScreen extends State<ReservationScreen> {
  _showDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Cancel Reservation"),
            content:
                Text("Would you like to proceed cancelling your reservation?"),
            actions: <Widget>[
              FlatButton(
                child: Text("Cancel Reservation"),
                onPressed: () {
                  cancelReservation(context);
                  Navigator.of(context).pop("test a");
                },
              )
            ],
          );
        });
  }

  cancelReservation(context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String idNo = prefs.getString('id_no');

    String ip = prefs.getString('HOST');
    String host = 'http://' + ip + ':5000/api';

    final response = await http.post(
        host + '/reservations/cancel-reservation/id_no',
        body: {"id_no": idNo});
    if (response.statusCode == 200) {
      Navigator.pop(context, true);
    } else {
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text("Host cannot be reached."),
      ));
      throw Exception('Failed to load Account.');
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    final cancelReservation = Material(
      elevation: 5.0,
      color: Colors.redAccent,
      borderRadius: BorderRadius.circular(4.0),
      child: MaterialButton(
        minWidth: MediaQuery.of(context).size.width,
        onPressed: () async {
          await _showDialog(context);
        },
        child: Text(
          "Cancel Reservation",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white),
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        automaticallyImplyLeading: true,
      ),
      body: Center(
        child: Container(
          padding: EdgeInsets.all(36.0),
          child: Column(
            children: <Widget>[
              Text(
                "Scan QR Code upon parking",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                'Valid until, ${DateFormat.yMMMd().add_jm().format(widget.accountReservation.estimatedDateOfArrival)} for Slot # ${widget.accountReservation.slotNo}',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
              SizedBox(height: 64.0),
              QrImage(
                data: widget.accountReservation.id,
                version: QrVersions.auto,
                size: 200.0,
              ),
              SizedBox(height: 64.0),
              cancelReservation,
            ],
          ),
        ),
      ),
    );
  }
}

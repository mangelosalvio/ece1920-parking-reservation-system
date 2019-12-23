import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:parking_reservation_system/Account.dart';
import 'package:parking_reservation_system/AccountReservation.dart';
import 'package:parking_reservation_system/Vehicle.dart';
import 'package:parking_reservation_system/reservation.dart';
import 'package:parking_reservation_system/slot_selection.dart';
import 'package:parking_reservation_system/vehicle_profile.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:adhara_socket_io/adhara_socket_io.dart';

void main() => runApp(Profile());

class Profile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return ProfileScreen(title: "User Profile");
  }
}

class ProfileScreen extends StatefulWidget {
  ProfileScreen({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Future<Account> account;
  Future<AccountReservation> accountReservation;
  String studentNumber;
  String name;

  SocketIOManager manager;
  SocketIO socket;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initSocket();
    refresh();
  }

  initSocket() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String ip = prefs.getString('HOST');
    String uri = 'http://' + ip + ':5000/';

    print("Connecting...");
    manager = new SocketIOManager();
    socket = await manager.createInstance(SocketOptions(uri,
        enableLogging: true,
        transports: [Transports.WEB_SOCKET, Transports.POLLING]));
    socket.onConnect((data) {
      print("Connected...");
    });
    print("Done Connecting...");

    socket.on("update-slot", (data) {
      refresh();

      print("Update Slots in profile...");
    });
    socket.connect();
  }

  refresh() {
    setState(() {
      account = getAccount();
      accountReservation = getReservation();
    });
  }

  logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('id_no');
    Navigator.of(context).pop();
  }

  Future<Account> getAccount() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String idNo = prefs.getString('id_no');
    String ip = prefs.getString('HOST');
    String url = 'http://' + ip + ':5000/api';

    final response =
        await http.post(url + '/accounts/id_no', body: {"id_no": idNo});
    if (response.statusCode == 200) {
      return Account.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load Account.');
    }
  }

  Future<AccountReservation> getReservation() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String idNo = prefs.getString('id_no');

    String ip = prefs.getString('HOST');
    String url = 'http://' + ip + ':5000/api';

    final response =
        await http.post(url + '/reservations/id_no', body: {"id_no": idNo});

    if (response.statusCode == 200) {
      return AccountReservation.fromJson(json.decode(response.body));
    } else if (response.statusCode == 401) {
      return null;
    } else {
      throw Exception('Failed to load Account.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final sizedBox = SizedBox(height: 8.0);

    final studentNumberField = FutureBuilder<Account>(
      future: account,
      builder: (context, snapshot) {
        String data = "";
        if (snapshot.hasData) {
          data = snapshot.data.idNo;
        }

        return TextFormField(
          controller: TextEditingController(
            text: data,
          ),
          decoration: InputDecoration(
              hintText: "e.g. 1912345",
              labelText: 'Student No.',
              icon: Icon(Icons.class_)),
        );
      },
    );

    final nameField = FutureBuilder<Account>(
      future: account,
      builder: (context, snapshot) {
        String data = "";
        if (snapshot.hasData) {
          data = snapshot.data.name;
        }

        return TextFormField(
          controller: TextEditingController(
            text: data,
          ),
          decoration: InputDecoration(
              hintText: "e.g. Juan de la Cru",
              labelText: 'Name',
              icon: Icon(Icons.person)),
        );
      },
    );

    final vehicleList = FutureBuilder<Account>(
      future: account,
      builder: (context, snapshot) {
        List<Vehicle> vehicles = [];
        if (snapshot.hasData) {
          vehicles = snapshot.data.vehicles;
        }

        return ListView.builder(
          itemCount: vehicles.length,
          itemBuilder: (context, index) {
            Vehicle v = vehicles[index];

            return ListTile(
              leading: Icon(Icons.directions_car),
              title: Text(v.plateNo),
              subtitle: Text('${v.carMake}/${v.carModel}'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => VehicleScreen(
                            vehicle: v,
                          )),
                );
              },
            );
          },
          scrollDirection: Axis.vertical,
        );
      },
    );

    final reserveButton = FutureBuilder(
      future: Future.wait([accountReservation, account]),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data[0] != null) {
          return Material(
            elevation: 5.0,
            color: Colors.orangeAccent,
            borderRadius: BorderRadius.circular(4.0),
            child: MaterialButton(
              minWidth: MediaQuery.of(context).size.width,
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Reservation(
                      accountReservation: snapshot.data[0],
                    ),
                  ),
                );

                /**
                 * GET DATA WHEN SCREEN COMES BACK
                 */
                refresh();
              },
              child: Text(
                "View Reservation",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white),
              ),
            ),
          );
        } else {
          if (!snapshot.hasData) {
            return SizedBox();
          }
          Account account = snapshot.data[1];

          if (account.creditsAvailable <= 0) {
            return SizedBox();
          }
          return Material(
            elevation: 5.0,
            color: Colors.green,
            borderRadius: BorderRadius.circular(4.0),
            child: MaterialButton(
              minWidth: MediaQuery.of(context).size.width,
              onPressed: () async {
                final result = await Navigator.push(context,
                    MaterialPageRoute(builder: (context) => SlotSelection()));

                /**
                 * GET DATA WHEN SCREEN COMES BACK
                 */
                refresh();
              },
              child: Text(
                "Reserve",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white),
              ),
            ),
          );
        }
      },
    );

    final creditsLeft = FutureBuilder<Account>(
      future: account,
      builder: (context, snapshot) {
        int creditsAvailable = 0;

        if (snapshot.hasData) {
          creditsAvailable = snapshot.data.creditsAvailable;
        }

        return Text('Vehicle List - $creditsAvailable credits left');
      },
    );

    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        automaticallyImplyLeading: false,
        actions: <Widget>[
          PopupMenuButton(
            onSelected: (int i) {
              logout();
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 1,
                child: Text("Logout"),
              )
            ],
          )
        ],
      ),
      body: Container(
          padding: EdgeInsets.all(36.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              studentNumberField,
              sizedBox,
              nameField,
              SizedBox(
                height: 32.0,
              ),
              creditsLeft,
              sizedBox,
              Expanded(
                child: vehicleList,
              ),
              reserveButton
            ],
          )),
    );
  }
}

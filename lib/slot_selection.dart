import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:parking_reservation_system/Slot.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:adhara_socket_io/adhara_socket_io.dart';

void main() => runApp((SlotSelection()));

class SlotSelection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return SlotSelectionScreen(title: "Select an available slot");
  }
}

class SlotSelectionScreen extends StatefulWidget {
  final String title;

  const SlotSelectionScreen({Key key, this.title}) : super(key: key);
  @override
  _SlotSelectionScreen createState() => _SlotSelectionScreen();
}

class _SlotSelectionScreen extends State<SlotSelectionScreen> {
  Future<List<Slot>> slots;

  SocketIOManager manager;
  SocketIO socket;

  Future<List<Slot>> getSlots() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String ip = prefs.getString('HOST');
    String url = 'http://' + ip + ':5000/api';

    final response = await http.get(url + '/slots');
    if (response.statusCode == 200) {
      var slots = json.decode(response.body) as List;
      List<Slot> _slots = slots.map((o) => Slot.fromJson(o)).toList();
      return _slots;
    } else {
      throw Exception('Failed to load Account.');
    }
  }

  _showReserveDialog(BuildContext context, Slot slot) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          if (slot.status == "Available") {
            return AlertDialog(
              title: Text("Reservation"),
              content: Text("Would you like to proceed with your reservation?"),
              actions: <Widget>[
                FlatButton(
                  child: Text("Reserve"),
                  onPressed: () {
                    reserveSlot(context, slot.slotNo);
                  },
                )
              ],
            );
          } else {
            return AlertDialog(
              title: Text("Slot Unavailable"),
              content: Text("Slot is currently unavailable"),
              actions: <Widget>[
                FlatButton(
                  child: Text("Cancel"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                )
              ],
            );
          }
        });
  }

  reserveSlot(context, slotNo) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String idNo = prefs.getString('id_no');
    String ip = prefs.getString('HOST');
    String url = 'http://' + ip + ':5000/api';

    final response = await http
        .put(url + '/reservations', body: {"id_no": idNo, 'slot_no': slotNo});
    if (response.statusCode == 200) {
      Navigator.of(context, rootNavigator: true).pop();
      Navigator.of(context, rootNavigator: true).pop();
    } else {
      throw Exception('Failed to load Account.');
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    slots = getSlots();
    initSocket();
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
      setState(() {
        slots = getSlots();
      });

      print("Update Slots in selection...");
    });
    socket.connect();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    FutureBuilder<List<Slot>> listViewSlot = FutureBuilder<List<Slot>>(
      future: slots,
      builder: (context, snapshot) {
        List<Slot> slots = [];

        if (snapshot.hasData) {
          slots = snapshot.data;
        }

        int length = slots != null ? slots.length : 0;

        return GridView.builder(
            itemCount: length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10.0,
            ),
            itemBuilder: (context, index) {
              Slot slot = slots[index];

              Color slotColor = Colors.greenAccent;
              if (slot.status == "Occupied") {
                slotColor = Colors.redAccent;
              } else if (slot.status == "Reserved") {
                slotColor = Colors.orangeAccent;
              }

              return GestureDetector(
                onTap: () {
                  _showReserveDialog(context, slot);
                },
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black12),
                    borderRadius: BorderRadius.circular(4.0),
                    color: slotColor,
                  ),
                  height: 200.0,
                  child: Center(child: Text(slot.slotNo)),
                ),
              );
            });
      },
    );

    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Center(
          child: Container(
            child: listViewSlot,
            height: 250.0,
          ),
        ),
      ),
    );
  }
}

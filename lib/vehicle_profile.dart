import 'package:flutter/material.dart';

import 'Vehicle.dart';

void main() => runApp(VehicleProfile());

class VehicleScreen extends StatelessWidget {
  final Vehicle vehicle;
  const VehicleScreen({Key key, this.vehicle}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return VehicleProfile(
      title: "Vehicle Profile",
      vehicle: vehicle,
    );
  }
}

class VehicleProfile extends StatefulWidget {
  final String title;
  final Vehicle vehicle;
  VehicleProfile({Key key, this.title, this.vehicle}) : super(key: key);

  @override
  _VehicleProfileState createState() => _VehicleProfileState();
}

class _VehicleProfileState extends State<VehicleProfile> {
  String plateNumber;
  String carMake;
  String carModel;
  String carColor;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      plateNumber = widget.vehicle.plateNo;
      carMake = widget.vehicle.carMake;
      carModel = widget.vehicle.carModel;
      carColor = widget.vehicle.carColor;
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    final plateNumberField = TextFormField(
      controller: TextEditingController(
        text: '$plateNumber',
      ),
      decoration: InputDecoration(labelText: 'Plate No.'),
    );

    final carMakeField = TextFormField(
      controller: TextEditingController(
        text: '$carMake',
      ),
      decoration: InputDecoration(labelText: 'Make'),
    );

    final carModelField = TextFormField(
      controller: TextEditingController(
        text: '$carModel',
      ),
      decoration: InputDecoration(labelText: 'Model'),
    );

    final carColorField = TextFormField(
      controller: TextEditingController(
        text: '$carColor',
      ),
      decoration: InputDecoration(labelText: 'Color'),
    );

    final divider = SizedBox(
      height: 16.0,
    );

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(widget.title),
      ),
      body: Container(
        padding: EdgeInsets.all(32.0),
        child: Column(
          children: <Widget>[
            plateNumberField,
            divider,
            carMakeField,
            divider,
            carModelField,
            divider,
            carColorField
          ],
        ),
      ),
    );
  }
}

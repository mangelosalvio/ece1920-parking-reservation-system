import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(Settings());

class Settings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return SettingScreen(title: "Settings");
  }
}

class SettingScreen extends StatefulWidget {
  SettingScreen({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _SettingScreenState createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  Future<String> host;
  TextEditingController controller;

  Future<String> getSharedPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('HOST');
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    host = getSharedPrefs();
  }

  @override
  Widget build(BuildContext context) {
    controller = TextEditingController();

    final hostField = FutureBuilder<String>(
      future: host,
      builder: (context, snapshot) {
        String data = "";
        if (snapshot.hasData) {
          data = snapshot.data;
        }

        TextEditingController hostController =
            TextEditingController(text: data);

        return TextFormField(
          onChanged: (value) async {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            prefs.setString('HOST', value);
          },
          controller: hostController,
          decoration: InputDecoration(
              hintText: "e.g. 192.168.1.100",
              labelText: 'Host',
              icon: Icon(Icons.class_)),
        );
      },
    );

    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        automaticallyImplyLeading: true,
      ),
      body: Container(
          padding: EdgeInsets.all(36.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              hostField,
              SizedBox(
                height: 32.0,
              ),
            ],
          )),
    );
  }
}

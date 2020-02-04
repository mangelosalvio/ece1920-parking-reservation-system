import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

void main() => runApp(UpdatePassword());

class UpdatePassword extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return UpdatePasswordScreen(title: "Update Password");
  }
}

class UpdatePasswordScreen extends StatefulWidget {
  UpdatePasswordScreen({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _UpdatePasswordScreenState createState() => _UpdatePasswordScreenState();
}

class _UpdatePasswordScreenState extends State<UpdatePasswordScreen> {
  Future<String> host;
  TextEditingController passwordFieldController, confirmPasswordFieldController;

  updatePassword(BuildContext context) async {
    print(passwordFieldController.text.toString() !=
        confirmPasswordFieldController.text.toString());
    if (passwordFieldController.text.toString() !=
        confirmPasswordFieldController.text.toString()) {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("Error"),
              content: Text("Password does not match"),
              actions: <Widget>[
                FlatButton(
                  child: Text("Cancel"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                )
              ],
            );
          });
    } else {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String ip = prefs.getString('HOST');
      String idNo = prefs.getString('id_no');

      String url = 'http://' + ip + ':5000/api';

      final response = await http.post(url + '/accounts/update-password',
          body: {"id_no": idNo, 'password': passwordFieldController.text});
      if (response.statusCode == 200) {
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text("Update Password"),
                content: Text("Your Password has been updated"),
                actions: <Widget>[
                  FlatButton(
                    child: Text("Done"),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  )
                ],
              );
            });
      }
    }
  }

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
    passwordFieldController = TextEditingController();
    confirmPasswordFieldController = TextEditingController();

    TextFormField passwordField = TextFormField(
      obscureText: true,
      controller: passwordFieldController,
      decoration: InputDecoration(
        hintText: "Password",
        icon: Icon(Icons.vpn_key),
      ),
    );

    TextFormField confirmPasswordField = TextFormField(
      obscureText: true,
      controller: confirmPasswordFieldController,
      decoration: InputDecoration(
        hintText: "Confirm Password",
        icon: Icon(Icons.vpn_key),
      ),
    );

    final updatePasswordButton = Material(
      elevation: 5.0,
      color: Colors.green,
      borderRadius: BorderRadius.circular(4.0),
      child: MaterialButton(
        minWidth: MediaQuery.of(context).size.width,
        onPressed: () {
          updatePassword(context);
        },
        child: Text(
          "Update Password",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white),
        ),
      ),
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
              passwordField,
              SizedBox(
                height: 32.0,
              ),
              confirmPasswordField,
              SizedBox(
                height: 32.0,
              ),
              updatePasswordButton
            ],
          )),
    );
  }
}

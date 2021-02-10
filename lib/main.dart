import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:share/share.dart';

import "package:path_provider/path_provider.dart";

// For using PlatformException
import 'package:flutter/services.dart';

import 'package:flutter/material.dart';


// for Wifi info (android)

import 'package:wifi_info_flutter/wifi_info_flutter.dart';

import 'package:http/http.dart';
// import 'package:dio/dio.dart';

void main() => runApp(MyApp());


final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

// Get
TextEditingController customControllerSsid = TextEditingController();
TextEditingController customController = TextEditingController();

TextEditingController customControllerCapture = TextEditingController();

TextEditingController customControllerIp = TextEditingController();

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smile Symbol',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: BluetoothApp(),
    );
  }
}

class BluetoothApp extends StatefulWidget {
  @override
  _BluetoothAppState createState() => _BluetoothAppState();
}

class _BluetoothAppState extends State<BluetoothApp> {
  //Creat Alert Dialog
  CreatAlertDialog(BuildContext context, String ssid) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Colors.grey[900],
            shape: new RoundedRectangleBorder(
                side: new BorderSide(color: Colors.orange[400], width: 1.0),
                borderRadius: BorderRadius.circular(15.0)),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  "ssid",
                  textDirection: TextDirection.rtl,
                  style: TextStyle(fontSize: 14, color: Colors.white70),
                ),
                Text(
                  "password",
                  textDirection: TextDirection.rtl,
                  style: TextStyle(fontSize: 14, color: Colors.white70),
                ),
              ],
            ),
            content: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Flexible(
                  child: TextField(
                    style: new TextStyle(color: Colors.white),
                    // keyboardType: TextInputType.number,
                    controller: customControllerSsid,
                    decoration: new InputDecoration(
                      hintText: "Ssid",
                      hintStyle:
                      TextStyle(fontSize: 15.0, color: Colors.white30),
                    ),
                  ),
                ),
                SizedBox(
                  width: 30,
                ),
                Flexible(
                  child: TextField(
                    style: new TextStyle(color: Colors.white),
                    // keyboardType: TextInputType.number,
                    controller: customController,
                    decoration: new InputDecoration(
                      hintText: "Password",
                      hintStyle:
                      TextStyle(fontSize: 15.0, color: Colors.white30),
                    ),
                  ),
                ),
              ],
            ),
            actions: <Widget>[
              MaterialButton(
                color: Colors.orange,
                elevation: 5.0,
                child: Text(
                  "send",
                  style: TextStyle(color: Colors.white70),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  String password = customController.text.toString();
                  String ssid1 = customControllerSsid.text.toString();
                  ShareJson(ssid1, password, '1');

                  customController.clear();
                },
              )
            ],
          );
        });
  }

  //end





  //bluetooth


  //


  @override
  void initState() {
    super.initState();
    //   fireAllFutures() ;
    // Get current state





  }

  //Wifi info init
// fireAllFutures() {
//   setState(() {

//     ssid = AndroidWifiInfo.ssid;

//   });
// }




  //
  // save paired devices


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text("Smile Symbol"),
          backgroundColor: Colors.deepPurple,
          actions: <Widget>[

          ],
        ),
        body: Container(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[


              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        RaisedButton(
                          elevation: 2,
                          child: Text("Send Json"),
                          onPressed: () async {
                            var wifiName = await WifiInfo().getWifiName();
                            print(wifiName);
                            customControllerSsid =
                            new TextEditingController(text: wifiName);
                            CreatAlertDialog(context, wifiName);
                          },
                        ),
                        Flexible(
                          child: TextField(
                            style: new TextStyle(color: Colors.black),
                            keyboardType: TextInputType.number,
                            controller: customControllerCapture,
                            decoration: InputDecoration(
                                labelText: 'Enter # of photos to take'),
                          ),
                        ),
                        MaterialButton(
                          color: Colors.orange,
                          elevation: 5.0,
                          child: Text(
                            "Send to Smart Scan",
                            style: TextStyle(color: Colors.white70),
                          ),
                          onPressed: () {
                            String number_of_photos_to_capture =
                            customControllerCapture.text.toString();
                            PostCommand(number_of_photos_to_capture);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  //
  void PostCommand(String numberOfPhotosToCapture,
      {String host = "camera.smilesymbol.com", String port = "5000"}) async {
    // String url ="https://camera.smilesymbol.com/camera"+capture;
    String url = "http://" + host + ":" + port + "/capture/" + numberOfPhotosToCapture;
    print(url);
    Response response = await get(url);
    // sample info available in response
    int statusCode = response.statusCode;
    Map<String, String> headers = response.headers;
    String contentType = headers['content-type'];
    String json = response.body;
    print(json);
  }







  //Save Json File*****************************
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/wifi_info');
  }

  Future<File> writeJson(String counter) async {
    final file = await _localFile;

    // Write the file.
    return file.writeAsString('$counter');
  }

  //end

  // Share JSON
  void ShareJson(String ssid, String password, String user_id) async {
    Map<String, dynamic> map = {
      'ssid': ssid,
      'password': password,
      'user_id': user_id,
    };

    String wifi_info = "network={\n ssid=\"$ssid\" \n psk=\"$password\"\n}";
    //end

    String rawJson = jsonEncode(map);

    writeJson(wifi_info);
    print("___________________");

    var temp = await _localPath;
    print(temp);
    // Share.share('{SSid:HusseinCopol,pasword:1234,user_id:1}');
    Share.shareFiles(['$temp/wifi_info'], text: 'Great  ');
  }


}

class TText extends StatelessWidget {
  final text;

  TText(this.text, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    child: Container(child: Text(text, textAlign: TextAlign.left)),
  );
}


import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:share/share.dart';

import"package:path_provider/path_provider.dart";

// For using PlatformException
import 'package:flutter/services.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

// for Wifi info (android)

import 'package:wifi_info_flutter/wifi_info_flutter.dart';


import 'package:http/http.dart';

void main() => runApp(MyApp());

TextEditingController customControllerSsid = TextEditingController();
TextEditingController customController = TextEditingController();

TextEditingController customControllerCapture = TextEditingController();

TextEditingController customControllerIp = TextEditingController();

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smile Symbol',
      theme: ThemeData(
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
  CreatAlertDialog(BuildContext context,String ssid)
  {
    return showDialog(context: context,builder: (context){
      return AlertDialog(
        backgroundColor: Colors.grey[900],
        shape:new RoundedRectangleBorder(
            side: new BorderSide(color: Colors.orange[400], width: 1.0),
            borderRadius: BorderRadius.circular(15.0)) ,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[

            Text(
              "ssid",
              textDirection: TextDirection.rtl,
              style: TextStyle(fontSize: 14,color: Colors.white70),
            ),
            Text(
              "password",
              textDirection: TextDirection.rtl,
              style: TextStyle(fontSize: 14,color: Colors.white70),
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
                controller:customControllerSsid ,
                decoration:new InputDecoration(
                  hintText: "Ssid",
                  hintStyle: TextStyle(fontSize: 15.0, color: Colors.white30),
                ) ,
              ),
            ),
            SizedBox(
              width: 30,
            ),
            Flexible(
              child: TextField(
                style: new TextStyle(color: Colors.white),
               // keyboardType: TextInputType.number,
                controller:customController ,
                decoration:new InputDecoration(
                  hintText: "Password",
                    hintStyle: TextStyle(fontSize: 15.0, color: Colors.white30),
                ) ,
              ),
            ),

          ],
        ),
        actions: <Widget>[
          MaterialButton(

            color: Colors.orange,
            elevation: 5.0,
            child: Text("send"
              ,style: TextStyle(color: Colors.white70),),
            onPressed: (){
              Navigator.of(context).pop();
              String password= customController.text.toString();
              String ssid1 = customControllerSsid.text.toString();
              ShareJson(ssid1,password,'1');




              customController.clear();


            },
          )
        ],
      );
    });
  }







  //end
















  //Wifi Information



  // Initializing the Bluetooth connection state to be unknown
  BluetoothState _bluetoothState = BluetoothState.UNKNOWN;
  // Initializing a global key, as it would help us in showing a SnackBar later
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  // Get the instance of the Bluetooth
  FlutterBluetoothSerial _bluetooth = FlutterBluetoothSerial.instance;
  // Track the Bluetooth connection with the remote device
  BluetoothConnection connection;

  int _deviceState;

  bool isDisconnecting = false;

  Map<String, Color> colors = {
    'onBorderColor': Colors.green,
    'offBorderColor': Colors.red,
    'neutralBorderColor': Colors.transparent,
    'onTextColor': Colors.green[700],
    'offTextColor': Colors.red[700],
    'neutralTextColor': Colors.blue,










  };

 //bluetooth
  bool get isConnected => connection != null && connection.isConnected;

  //
  List<BluetoothDevice> _devicesList = [];
  BluetoothDevice _device;
  bool _connected = false;
  bool _isButtonUnavailable = false;

  @override
  void initState() {
    super.initState();
 //   fireAllFutures() ;
    // Get current state
    FlutterBluetoothSerial.instance.state.then((state) {
      setState(() {
        _bluetoothState = state;
      });
    });

    _deviceState = 0; // neutral


    enableBluetooth();

    // Listen for further state changes
    FlutterBluetoothSerial.instance
        .onStateChanged()
        .listen((BluetoothState state) {
      setState(() {
        _bluetoothState = state;
        if (_bluetoothState == BluetoothState.STATE_OFF) {
          _isButtonUnavailable = true;
        }
        getPairedDevices();
      });
    });
  }



  //Wifi info init
// fireAllFutures() {
//   setState(() {

//     ssid = AndroidWifiInfo.ssid;

//   });
// }

  @override
  void dispose() {
    // Avoid  disconnect
    if (isConnected) {
      isDisconnecting = true;
      connection.dispose();
      connection = null;
    }

    super.dispose();
  }


  Future<void> enableBluetooth() async {

    _bluetoothState = await FlutterBluetoothSerial.instance.state;

    if (_bluetoothState == BluetoothState.STATE_OFF) {
      await FlutterBluetoothSerial.instance.requestEnable();
      await getPairedDevices();
      return true;
    } else {
      await getPairedDevices();
    }
    return false;
  }

  //
  // save paired devices
  Future<void> getPairedDevices() async {
    List<BluetoothDevice> devices = [];


    try {
      devices = await _bluetooth.getBondedDevices();
    } on PlatformException {
      print("Error");
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _devicesList = devices;
    });
  }

  //UI
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text("Smile Symbol"),
          backgroundColor: Colors.deepPurple,
          actions: <Widget>[
            FlatButton.icon(
              icon: Icon(
                Icons.refresh,
                color: Colors.white,
              ),
              label: Text(
                "Refresh",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              splashColor: Colors.deepPurple,
              onPressed: () async {

                await getPairedDevices().then((_) {
                  show('Device list refreshed');
                });
              },
            ),
          ],
        ),
        body: Container(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Visibility(
                visible: _isButtonUnavailable &&
                    _bluetoothState == BluetoothState.STATE_ON,
                child: LinearProgressIndicator(
                  backgroundColor: Colors.yellow,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        'Enable Bluetooth',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Switch(
                      value: _bluetoothState.isEnabled,
                      onChanged: (bool value) {
                        future() async {
                          if (value) {
                            await FlutterBluetoothSerial.instance
                                .requestEnable();
                          } else {
                            await FlutterBluetoothSerial.instance
                                .requestDisable();
                          }

                          await getPairedDevices();
                          _isButtonUnavailable = false;

                          if (_connected) {
                            _disconnect();
                          }
                        }

                        future().then((_) {
                          setState(() {});
                        });
                      },
                    )
                  ],
                ),
              ),

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
                            customControllerSsid = new TextEditingController(text: wifiName);
                            CreatAlertDialog(context,wifiName);


                          },
                        ),
                        Flexible(
                          child: TextField(
                            style: new TextStyle(color: Colors.black),
                            keyboardType: TextInputType.number,
                            controller:customControllerCapture ,
                            decoration: InputDecoration(
                                labelText: 'Enter a number'
                            ),
                          ),
                        ),
                        Flexible(
                          child: TextField(
                            style: new TextStyle(color: Colors.black),
                            keyboardType: TextInputType.number,
                            controller:customControllerIp,
                            decoration: InputDecoration(
                                labelText: 'Enter an ip'
                            ),
                          ),
                        ),
                        MaterialButton(

                          color: Colors.orange,
                          elevation: 5.0,
                          child: Text("capture"
                            ,style: TextStyle(color: Colors.white70),),
                          onPressed: (){
                            String capture=customControllerCapture.text.toString();
                            String ip=customControllerIp.text.toString();
                            PostCommand(capture,ip);
                            print(capture + " " + ip);

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
  void PostCommand(String capture,String ip) async
  {


    // String url ="https://72.68.100.221/"+capture;
    String url ="https://" + ip+  "/"+capture;
    Response response =await get(url);
    setState(() {

    });



  }


  // Dropdown Menu
  List<DropdownMenuItem<BluetoothDevice>> _getDeviceItems() {
    List<DropdownMenuItem<BluetoothDevice>> items = [];
    if (_devicesList.isEmpty) {
      items.add(DropdownMenuItem(
        child: Text('NONE'),
      ));
    } else {
      _devicesList.forEach((device) {
        items.add(DropdownMenuItem(
          child: Text(device.name),
          value: device,
        ));
      });
    }
    return items;
  }

  // connect to bluetooth
  void _connect() async {
    setState(() {
      _isButtonUnavailable = true;
    });
    if (_device == null) {
      show('No device selected');
    } else {
      if (!isConnected) {
        await BluetoothConnection.toAddress(_device.address)
            .then((_connection) {
          print('Connected to the device');
          connection = _connection;
          setState(() {
            _connected = true;
          });

          connection.input.listen(null).onDone(() {
            if (isDisconnecting) {
              print('Disconnecting locally!');
            } else {
              print('Disconnected remotely!');
            }
            if (this.mounted) {
              setState(() {});
            }
          });
        }).catchError((error) {
          print('Cannot connect, exception occurred');
          print(error);
        });
        show('Device connected');

        setState(() => _isButtonUnavailable = false);
      }
    }
  }

  // void _onDataReceived(Uint8List data) {
  //   // Allocate buffer for parsed data
  //   int backspacesCounter = 0;
  //   data.forEach((byte) {
  //     if (byte == 8 || byte == 127) {
  //       backspacesCounter++;
  //     }
  //   });
  //   Uint8List buffer = Uint8List(data.length - backspacesCounter);
  //   int bufferIndex = buffer.length;

  //   // Apply backspace control character
  //   backspacesCounter = 0;
  //   for (int i = data.length - 1; i >= 0; i--) {
  //     if (data[i] == 8 || data[i] == 127) {
  //       backspacesCounter++;
  //     } else {
  //       if (backspacesCounter > 0) {
  //         backspacesCounter--;
  //       } else {
  //         buffer[--bufferIndex] = data[i];
  //       }
  //     }
  //   }
  // }

  // Method to disconnect bluetooth
  void _disconnect() async {
    setState(() {
      _isButtonUnavailable = true;
      _deviceState = 0;
    });

    await connection.close();
    show('Device disconnected');
    if (!connection.isConnected) {
      setState(() {
        _connected = false;
        _isButtonUnavailable = false;
      });
    }
  }

  // Method to send message,
  // for turning the Bluetooth device on
  void _sendStringMessageToBluetooth() async {
    connection.output.add(utf8.encode("1" + "\r\n"));
    await connection.output.allSent;

  }

  Future _sendJSONToBluetooth(String ssid,String pasword,String user_id) async {

    Map<String, dynamic> map = {
      'ssid': ssid,
      'password': pasword,
      'user_id': user_id,
    };

    String rawJson = jsonEncode(map);

  //  connection.output.add(utf8.encode(rawJson));
    connection.output.add(utf8.encode("1"));
    await connection.output.allSent;

  }


  //show a Snackbar,
  Future show(
    String message, {
    Duration duration: const Duration(seconds: 3),
  }) async {
    await new Future.delayed(new Duration(milliseconds: 100));
    _scaffoldKey.currentState.showSnackBar(
      new SnackBar(
        content: new Text(
          message,
        ),
        duration: duration,
      ),
    );
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
  void ShareJson (String ssid,String password,String user_id) async
  {

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

    var temp =await _localPath;
    print(temp);
    // Share.share('{SSid:HusseinCopol,pasword:1234,user_id:1}');
    Share.shareFiles(['$temp/wifi_info'], text: 'Great picture');
  }


  Widget buildFutureListTile({
    @required Future future,
    @required String name,
    @required Widget description,
    @required String type,
  }) {
    List<Widget> expansionTileChildren = [
      Padding(
        padding: EdgeInsets.all(8.0),
        child: Row(
          children: [
            Text('Type: '),
            Text(type, style: TextStyle(fontFamily: 'monospace')),
          ],
        ),
      ),
      Padding(padding: EdgeInsets.all(8.0), child: description),
    ];
    final nameWidget = Text(
      '$name ',
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontFamily: 'monospace',
      ),
    );
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
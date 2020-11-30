import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(

        primarySwatch: Colors.blue,

        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  FlutterBlue flutterBlue = FlutterBlue.instance;
  List<BluetoothDevice> devices = new List();
  List<BluetoothService> services;
  BluetoothDevice device;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();


  @override
  Widget build(BuildContext context) {

    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      key: _scaffoldKey,
      body: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(top: width/5),
            child: Center(
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Image.asset(
                      'assets/logo_login.png',
                      width: width/2,
                    )
                  ),
                  MaterialButton(
                    onPressed: () {
                      _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text('Escaneando...')));
                      scan();
                    },
                    child: Text('Escanear'),
                    color: Colors.green
                  ),
                ]
              )
            )
          ),
          device != null ? Container(
            width: width - 40,
            margin: EdgeInsets.only(top: 40),
            child: Column (
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Text("Connected to: ${device.name}"),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 20),
                  child: TextField(
                    decoration: InputDecoration(
                      filled: true,
                      labelText: 'SSID'
                    )
                  )
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 20),
                  child: TextField(
                    decoration: InputDecoration(
                      filled: true,
                      labelText: 'Password'
                    ),
                    obscureText: true
                  )
                ),
                MaterialButton(
                  onPressed: () {
                    print('Sending data');
                    // await device.write(utf8.encode(str));
                  },
                  child: Text('Send data'),
                  color: Colors.green
                )
              ]
            )
          )
          : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(left: 20, top: 20),
                child: Text('Devices:', style: TextStyle(fontWeight: FontWeight.bold))
              ),
              Container(
                height: height - width,
                child: ListView.builder(
                  itemCount: devices.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: GestureDetector(
                        onTap: () {
                          _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text('Conectando ...')));
                          device = devices[index];
                          connect();
                        },
                        child: Text("${devices[index].name} - ${devices[index].id}", maxLines: 2),
                      )
                    );
                  }
                )
              )
            ]
          )
        ]
      )
    );
  }

  void connect() async {
    // bool wait = true;
    // Timer(Duration(seconds: 5), () {
    //   wait = false;
    // });
    await device.connect();
    // print('here');
    // while(wait){
    //   print(wait);
    // }
    // print('here2');
    bool connected = (await flutterBlue.connectedDevices).length > 0;
    if(connected)
      _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text('Conectado')));
    else {
      _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text('No fue posible conectar')));
      device = null;
    }
    setState(() {});
  }

  void scan() async {
    if(device != null) {
      device.disconnect();
      device = null;
    }
    devices.clear();
    try{
      dynamic results = await flutterBlue.startScan(timeout: Duration(seconds: 5));
      for(var i in results) {
        // print(i.device.id);
        if(i.device.name != "")
          devices.add(i.device);
      }
    } catch(e) {
      print(e);
      _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text('Error inesperado, intente nuevamente.')));
    }
    
    setState(() {
      if(devices.length == 0)
        _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text('No se encontraron dispositivos')));
    });
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(
  MaterialApp(
    title: "MENTAHAN 21/10/20",
    home: MyApp(),
  )
);

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String tanggal = DateFormat('yyyy-MM-dd').format(DateTime.now());
  Position dataTempat;
  String kota;
  List data;

  void getPosition() async{
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    print(position);

    List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
    print(placemarks.first.subAdministrativeArea);

    setState(() {
      dataTempat = position;
      kota = placemarks.first.subAdministrativeArea;
    });
    ambilData();
  }

  Future ambilData() async{
    http.Response hasil = await http.get(
        // ${kota}
      Uri.encodeFull("https://api.pray.zone/v2/times/day.json?city=bekasi&date=${tanggal}"), headers: {"Accept" : "application/json"}
    );
    // print(jsonEncode(hasil.body));
    Map<String, dynamic> map = jsonDecode(hasil.body);
    // print(map['results']['datetime']);
    setState(() {
      data = map['results']['datetime'];
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Waktu Sholat mentahan MVVM"), centerTitle: true,),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            RaisedButton(onPressed: (){
              getPosition();
            },
            color: Colors.blue,
            child: Text("get Location")),
            data == null ?
            Text(tanggal)
                : Column(
              children: <Widget>[
                Text("Waktu Sholat " + kota),
                Text("Subuh : " + data[0]['times']['Fajr']),
                Text("Dzuhur : " + data[0]['times']['Dhuhr']),
                Text("Ashar : " + data[0]['times']['Asr']),
                Text("Maghrib : " + data[0]['times']['Maghrib']),
                Text("Isya : " + data[0]['times']['Isha']),
              ],
            )
          ],
        ),
      ),
    );
  }
}


import 'package:flutter/material.dart';
import 'globals.dart' as globals;
import 'apiclient.dart' as apiclient;

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Widget> exchanges = [];
  
  getData() async {
    if(exchanges.length > 0)  return;
    var apiClient = new apiclient.ApiClient();
    var currencies = await apiClient.getTodaysExchangeRateV2();
    globals.currencies = currencies.sublist(3);
    setState(() {
      exchanges = currencies.sublist(3).map<Widget>((entry) => 
        ListTile(
          leading: Icon(Icons.album, size: 50),
          title: Text(entry['YUKSEK'].toString()),
          subtitle: Text(entry['ACIKLAMA']),
        )).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    getData();
    return Card(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: exchanges,
      ),
    );
  }
}
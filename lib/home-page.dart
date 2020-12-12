import 'package:flutter/material.dart';
import 'globals.dart' as globals;
import 'apiclient.dart' as apiclient;

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Widget> exchanges = [];
  var dolarRate, euroRate, goldRate;
  
  getData() async {
    if(exchanges.length > 0)  return;
    var apiClient = new apiclient.ApiClient();
    var currencies = await apiClient.getTodaysExchangeRateV2();
    
    globals.currencies = currencies;
    dolarRate = currencies.firstWhere( (currency) => currency['ACIKLAMA'] == "EURO/TURK LIRASI");
    euroRate = currencies.firstWhere( (currency) => currency['ACIKLAMA'] == "DOLAR/TURK LIRASI");
    goldRate = currencies.firstWhere( (currency) => currency['ACIKLAMA'] == "ALTIN GRAM - TL");
    
    var currencyWidget = [dolarRate, euroRate, goldRate].map<Widget>((entry) => 
        ListTile(
          leading: globals.iconSet[globals.propNameCurrencyMap[entry['SEMBOL']]],
          title: Text(entry['YUKSEK'].toString()),
          subtitle: Text(entry['ACIKLAMA']),
        )).toList();
    setState(() {
      exchanges = currencyWidget;
    });
  }

  @override
  Widget build(BuildContext context) {
    getData();
    return exchanges.length == 0 ? 
      Center(
        child: CircularProgressIndicator(),
      ) :
      Card(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: exchanges,
        ),
      );
  }
}
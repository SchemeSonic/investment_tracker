import 'package:investment_tracker/investment-crud.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'globals.dart' as globals;
import 'apiclient.dart' as apiclient;
import 'utils.dart' as utils;

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Widget> exchanges = [];
  Widget investmentSummary;
  var dolarRate, euroRate, goldRate;
  
  getData() async {
    if(exchanges.length > 0)  return;
    var apiClient = new apiclient.ApiClient();
    var currencies = await apiClient.getTodaysExchangeRateV3();
    currencies = utils.UtilsService.prepareCurrencies(currencies);
    globals.currencies = currencies;
    
    dolarRate = currencies['ABD DOLARI'];
    euroRate = currencies['EURO'];
    goldRate = currencies['Gram Altın'];
    
    var currencyWidget = [dolarRate, euroRate, goldRate].map<Widget>((entry) => 
        ListTile(
          leading: globals.iconSet[globals.propNameCurrencyMap[entry['SEMBOL']]],
          title: Text(entry['Satış'].toString()),
          subtitle: Text(entry['ACIKLAMA']),
        )).toList();

    currencyWidget.insert(0, Text("Döviz ve Altın Kurları", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),));
      
    setState(() {
      exchanges = currencyWidget;
    });
    getInvestments();
  }

  Widget getSummaryContainer(summary) {
    return Container(
          padding: EdgeInsets.fromLTRB(20, 30, 0, 30),
          height: 200,
          alignment: Alignment.centerLeft,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Toplam Varlık", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white54)),
                      Text("${summary['grandTotal'].toStringAsFixed(0)} TL", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 40))
                    ],
                  ),
                  Container(
                    padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                    child: Text("${summary['rate'] > 0 ? "+" : ""}${summary['rate'].toStringAsFixed(1)}%", style: TextStyle(fontWeight: FontWeight.bold, color: summary['rate'] >= 0 ? Colors.green : Colors.red, fontSize: 40)),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(topLeft:  Radius.circular(40), bottomLeft:  Radius.circular(40)),
                    )
                  )
                ]
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text("Varlık Ayrıntıları", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white54)),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(
                    children: [
                      Row(
                        children: [
                          FaIcon(FontAwesomeIcons.dollarSign, size: 36.0, color: Colors.white,),
                          Padding(
                            padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children:
                              [
                                Text("Dolar", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white54)),
                                Text("${summary['totalDolar'].toStringAsFixed(0)}", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))
                              ]
                            )
                          )
                        ],
                      )
                    ],
                  ),
                  Column(
                    children: [
                      Row(
                        children: [
                          FaIcon(FontAwesomeIcons.euroSign, size: 36.0, color: Colors.white),
                          Padding(
                            padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children:
                              [
                                Text("Euro", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white54)),
                                Text(summary['totalEuro'].toStringAsFixed(0), style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))
                              ]
                            )
                          )
                        ],
                      )
                    ],
                  ),
                  Column(
                    children: [
                      Row(
                        children: [
                          FaIcon(FontAwesomeIcons.coins, size: 36.0, color: Colors.white),
                          Padding(
                            padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children:
                              [
                                Text("Altın", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white54)),
                                Text("${summary['totalGold'].toStringAsFixed(2)}gr", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))
                              ]
                            )
                          )
                        ],
                      )
                    ],
                  )
                ]
              )
            ],
          ),
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(50),
            )
          ),
        );
  }

  getInvestments() async {
    if (investmentSummary != null)  return;
    double initialTotal = 0;
    Map<String, double> totals = {
      'totalDolar': 0, 
      'totalEuro': 0, 
      'totalGold': 0, 
      'grandTotal': 0,
      'rate': 1
    };

    CollectionReference investmentAPI = FirebaseFirestore.instance.collection('Investments');
    QuerySnapshot snapshot = await investmentAPI.where('email', isEqualTo: globals.currentUser.email).get();
    for (var doc in snapshot.docs) {
      var data = doc.data();
      var investment = new Investment(null, data['currency'], data['date'], data['perPrice'], data['amount']);

      if (investment.currency == 0) {
        totals['totalDolar'] += investment.amount;
        totals['grandTotal'] += investment.amount * dolarRate['Satış'];
      }
      if (investment.currency == 1) {
        totals['totalEuro'] += investment.amount;
        totals['grandTotal'] += investment.amount * euroRate['Satış'];
      }
      if (investment.currency == 2) {
        totals['totalGold'] += investment.amount;
        totals['grandTotal'] += investment.amount * goldRate['Satış'];
      }

      initialTotal += investment.amount * investment.perPrice;
    }
    
    totals['rate'] = ((totals['grandTotal'] / initialTotal) - 1) * 100;
    
    Widget summary = getSummaryContainer(totals);

    setState(() {
      investmentSummary = summary;
    });
  }
  @override
  Widget build(BuildContext context) {
    getData();

    return exchanges.length == 0 || investmentSummary == null ? 
      Center(
        child: CircularProgressIndicator(),
      ) : Column(
        children:[
          investmentSummary,
          Flexible(
            child: Card(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: exchanges,
              ),
            )
          ,)
        ]
      );
  }
}
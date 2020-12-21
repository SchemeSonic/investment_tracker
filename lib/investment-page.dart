import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:investment_tracker/investment-crud.dart';
import 'package:flutter/material.dart';
import 'package:flushbar/flushbar.dart';

import 'globals.dart' as globals;

class InvestmentPage extends StatelessWidget {
  final GlobalKey<_InvestmentsState> _investmentsState = GlobalKey<_InvestmentsState>();
  @override
  Widget build(BuildContext context) {
    var widget = new Investments(key: _investmentsState);
    return Scaffold(
      body: widget,
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(context,MaterialPageRoute(builder: (context) => InvestmentCrud(null)))
            .then((result) {
              if(result == null) return;
              _investmentsState.currentState.onInvestmentAction(result['data'], "create");
              Flushbar(message:  "Yatırım başarı ile eklendi.", duration:  Duration(seconds: 3))..show(context);
            });
          },
          child: Icon(Icons.add),
          backgroundColor: Colors.blue
        )
    );
  }
}

class InvestmentCard extends StatefulWidget {
  final investment;
  final callback;

  const InvestmentCard ({ Key key, this.investment, this.callback }): super(key: key);
  @override
  _InvestmentCardState createState() => _InvestmentCardState();
}

class _InvestmentCardState extends State<InvestmentCard> {

  @override
  Widget build(BuildContext context) {
    var currentCurrency = globals.getCurrency(widget.investment['currency']);
    var redColor = currentCurrency['Satış'] < widget.investment['perPrice'];
    var currency = globals.currencyEnums[widget.investment['currency']];
    var symbol = globals.symbols[currency];
    var icon = globals.iconSet["${redColor ? 'red' : 'green'}_" + currency];
    var rate = (((currentCurrency['Satış'] / widget.investment['perPrice']) - 1) * 100).abs().toStringAsFixed(2);

    _onInvestmentUpdated(investment) {
      widget.callback(investment, "update");
    }

    _onInvestmentDeleted(investmentId) {
      widget.callback(investmentId, "delete");
    }
    
    return Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                ListTile(
                  leading: icon,
                  title: Text("${(widget.investment['amount'] * currentCurrency['Satış']).toStringAsFixed(1)} TL (${redColor ? "-" : "+"} $rate%)", style: TextStyle(fontWeight: FontWeight.bold, color: redColor ? Colors.red : Colors.green)),
                  subtitle: Text(
                    '${currentCurrency['Satış']} x ${widget.investment['amount']} $symbol',
                    style: TextStyle(color: Colors.black.withOpacity(0.6)),
                  ),
                  trailing: IconButton(
                    icon: Icon(
                      Icons.keyboard_arrow_right,
                      size: 40.0,
                      color: Colors.brown[900],
                    ),
                    onPressed: () {
                      Investment investmentInstance = new Investment(widget.investment['id'],  widget.investment['currency'], widget.investment['date'], widget.investment['perPrice'], widget.investment['amount']);
                      Navigator.push(context,MaterialPageRoute(builder: (context) => InvestmentCrud(investmentInstance)))
                      .then((result) {
                        if(result == null) return;
                        if(result['action'] == "update") {
                          _onInvestmentUpdated(result['data']);
                          Flushbar(message:  "Yatırım başarı ile güncellendi.", duration:  Duration(seconds: 3))..show(context);
                        }
                        if(result['action'] == "delete"){
                          _onInvestmentDeleted(result['data']);
                          Flushbar(message:  "Yatırım başarı ile silindi.", duration:  Duration(seconds: 3))..show(context);
                        }
                      });
                    },
                  )
                ),
                ButtonBar(
                  alignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Text('Yatırım Tarihi'),
                        Text('${widget.investment['date']}')
                        ]
                      ),
                      Column(
                      children: [
                        Text('Yatırım Anı Kur'),
                        Text('${widget.investment['perPrice']} TL')
                        ]
                      ),
                    Column(
                      children: [
                        Text('Yatırım Miktarı'),
                        Text('${widget.investment['amount']} $symbol / ${(widget.investment['amount'] * widget.investment['perPrice']).toStringAsFixed(1)} TL')
                        ]
                      )
                  ],
                ),
              ],
            ),
          );
  }
}

class Investments extends StatefulWidget {
  final investments;
  Investments({Key key, this.investments}): super(key: key);
  @override
  _InvestmentsState createState() => _InvestmentsState();
}

class _InvestmentsState extends State<Investments> {
  var _investments = [];
  List<Widget> investmentList = [];
  onInvestmentAction(investment, mode) {
    if(mode == "create") {
      setState(() {
        investmentList.add(new InvestmentCard(investment: {
            "currency": investment.currency,
            "perPrice": investment.perPrice,
            "amount": investment.amount,
            "date": investment.date,
            "id": investment.id
          }, callback: onInvestmentAction) 
        );
      });
    }
    if(mode == "update"){
      var index = _investments.indexWhere((item) => item['id'] == investment.id);
      setState(() => {
        investmentList[index] = new InvestmentCard(investment: {
            "currency": investment.currency,
            "perPrice": investment.perPrice,
            "amount": investment.amount,
            "date": investment.date,
            "id": investment.id
          }, callback: onInvestmentAction) 
      });
    } if(mode == "delete") {
      var index = _investments.indexWhere((item) => item['id'] == investment);
      setState(() => {
        investmentList[index] = null
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    CollectionReference investmentAPI = FirebaseFirestore.instance.collection('Investments');
    investmentList = [];

    return FutureBuilder<QuerySnapshot>(
      future: investmentAPI.where('email', isEqualTo: globals.currentUserEmail).get(),
      builder:
          (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {

        if (snapshot.hasError) {
          return Text("Something went wrong");
        }

        if (snapshot.connectionState == ConnectionState.done) {
          for (var i = 0; i < snapshot.data.docs.length; i++) {
            var investment = snapshot.data.docs[i].data();
            investment['id'] = snapshot.data.docs[i].id;
            _investments.add(investment);
            investmentList.add(new InvestmentCard(investment: investment, callback: onInvestmentAction));
          }
          
          return ListView(children: investmentList);
        }

        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'globals.dart' as globals;

class Investment {
  String id;
  int currency;
  double perPrice;
  double amount;
  String date;
  String email;
  Investment(this.id, this.currency, this.date, this.perPrice, this.amount);
}

class InvestmentForm extends StatefulWidget {
  final Investment investment;

  const InvestmentForm ({ Key key, this.investment }): super(key: key);

  @override
  _InvestmentFormState createState() => _InvestmentFormState();
}

class _InvestmentFormState extends State<InvestmentForm> {
  final _formKey = GlobalKey<FormState>();
  var _amountController = TextEditingController();
  var _perPriceController = TextEditingController(text: globals.currencies['ABD DOLARI']["Satış"].toString());
  var _dateController = TextEditingController(text: DateFormat("yyyy-MM-dd").format(DateTime.now()));
  int _currency = 0;
  String mode = "create";
  

  void _handleRadioValueChange1(value) => setState(() {
    _currency = value;
    var currency = globals.getCurrency(value);
    _perPriceController.text = currency["Satış"].toString();
  });

  void _selectDate() => {
    showDatePicker(
      context: context,
      initialDate: DateTime.parse(_dateController.text),
      firstDate: DateTime(2019, 1),
      lastDate: DateTime(2021,12),
    ).then((selectedDate) {
      if(selectedDate!=null){
        _dateController.text = DateFormat("yyyy-MM-dd").format(selectedDate);
      }
    })
  };

  Future<dynamic> addInvestment(Investment investment) {
    CollectionReference investmentCollection = FirebaseFirestore.instance.collection('Investments');
    return investmentCollection
        .add({
          "currency": investment.currency,
          "perPrice": investment.perPrice,
          "amount": investment.amount,
          "date": investment.date,
          "email": globals.currentUser.email
        });
  }

  Future<void> updateInvestment(Investment investment) {
    CollectionReference investmentCollection = FirebaseFirestore.instance.collection('Investments');
    return investmentCollection
        .doc(investment.id).update({
          "currency": investment.currency,
          "perPrice": investment.perPrice,
          "amount": investment.amount,
          "date": investment.date,
          "email": globals.currentUser.email
        });
  }

  Future<void> deleteInvestment(String investmentId) {
    CollectionReference investmentCollection = FirebaseFirestore.instance.collection('Investments');
    return investmentCollection
        .doc(investmentId).delete();
  }

  @override
  Widget build(BuildContext context) {
    if(widget?.investment?.date?.isNotEmpty != null) {
      _currency = widget.investment.currency;
      _amountController = TextEditingController(text: widget.investment.amount.toString());
      _perPriceController = TextEditingController(text: widget.investment.perPrice.toString());
      _dateController = TextEditingController(text: widget.investment.date);
      mode = "update";
    }

    return Padding(
        padding: EdgeInsets.all(16),
        child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            new Text(
              'Yatırım Türü :',
              style: new TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18.0,
              ),
            ),
            new Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                new Radio(
                  value: 0,
                  groupValue: _currency,
                  onChanged: _handleRadioValueChange1,
                ),
                new Text(
                  '\$ Dolar',
                  style: new TextStyle(fontSize: 16.0),
                ),
                new Radio(
                  value: 1,
                  groupValue: _currency,
                  onChanged: _handleRadioValueChange1,
                ),
                new Text(
                  '€ Euro',
                  style: new TextStyle(
                    fontSize: 16.0,
                  ),
                ),
                new Radio(
                  value: 2,
                  groupValue: _currency,
                  onChanged: _handleRadioValueChange1,
                ),
                new Text(
                  'Altın',
                  style: new TextStyle(fontSize: 16.0),
                ),
              ],
            ),
            TextFormField(
              onTap: _selectDate,
              controller: _dateController,
              decoration: InputDecoration(
                labelText: 'Yatırım Tarihi'
              )
            ),
            TextFormField(
              decoration: InputDecoration(
                hintText: 'Biriminin kaç TL olduğunu giriniz.',
                labelText: 'Birim Fiyat'
              ),
              controller: _perPriceController,
              keyboardType: TextInputType.numberWithOptions(signed: false, decimal: true),
              validator: (value) {
                if (value.isEmpty) {
                  return 'Lütfen değer giriniz.';
                }
                return null;
              },
            ),
            TextFormField(
              decoration: InputDecoration(
                hintText: _currency == 2 ? 'Gram giriniz.' : 'Yatırım yapılan miktarı giriniz.',
                labelText: 'Yatırım Miktarı'
              ),
              controller: _amountController,
              keyboardType: TextInputType.numberWithOptions(signed: false, decimal: true),
              validator: (value) {
                if (value.isEmpty) {
                  return 'Lütfen değer giriniz.';
                }
                return null;
              },
            ),
            Row(
              children: [
                if(mode == "update") 
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(primary: Colors.red),
                    onPressed: () {
                      if (_formKey.currentState.validate()) {
                        deleteInvestment(widget.investment.id).then((value) => {
                          Navigator.pop(context, {
                              "action": "delete",
                              "data": widget.investment.id
                            })
                        }).catchError((error) => print("Bir hata oluştu: $error"));
                      }
                    },
                    child: Text('Sil'),
                  )
                ),
                Expanded( 
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState.validate()) {
                        final investment = new Investment("", _currency,_dateController.text,double.parse(_perPriceController.text), double.parse(_amountController.text));
                        if(mode == "create") {
                          addInvestment(investment).then((value) => {
                            investment.id = value.id,
                            Navigator.pop(context, {
                              "action": "create",
                              "data": investment
                            })
                          }).catchError((error) => print("Bir hata oluştu: $error"));
                        }
                        else {
                          investment.id = widget.investment.id;
                          updateInvestment(investment).then((value) => {
                            Navigator.pop(context, {
                              "action": "update",
                              "data": investment
                            })
                          }).catchError((error) => print("Bir hata oluştu: $error"));
                        }
                      }
                    },
                    child: Text('${mode == "update" ? 'Güncelle' : 'Ekle'}'),
                  )
                )
              ],
            ),
          ],
        ),
      )
    );
  }
}

class InvestmentCrud extends StatelessWidget {
  InvestmentCrud(this.investment);

  final Investment investment;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Yatırım Olustur'),
      ),
      body: new InvestmentForm(investment: investment)
    );
  }
}
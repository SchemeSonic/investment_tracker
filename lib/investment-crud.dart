import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'globals.dart' as globals;

class Investment {
  int currency;
  double perPrice;
  double amount;
  String date;
  Investment(this.currency, this.date, this.perPrice, this.amount);
}

class InvestmentForm extends StatefulWidget {
  @override
  _InvestmentFormState createState() => _InvestmentFormState();
}

class _InvestmentFormState extends State<InvestmentForm> {
  
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _perPriceController = TextEditingController(text: globals.currencies.where((currency) => currency['SEMBOL'] == "USDTRY").toList()[0]["SATIS"].toString());
  final _dateController = TextEditingController(text: DateFormat("yyyy-MM-dd").format(DateTime.now()));
  int _currency = 0;

  getCurrency(value) {
    var currencyType = globals.currencyPropNameMap[globals.currencyEnums[value]];
    var currency = globals.currencies.where((currency) => currency['SEMBOL'] == currencyType).toList()[0];
    return currency;
  }
  

  void _handleRadioValueChange1(value) => setState(() {
    _currency = value;
    var currency = getCurrency(value);
    _perPriceController.text = currency["SATIS"].toString();
    print(currency);
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

  @override
  Widget build(BuildContext context) {
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
            ),
            TextFormField(
              decoration: InputDecoration(
                hintText: 'Biriminin kaç TL olduğunu giriniz.',
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
            Padding(
              padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
              child:SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState.validate()) {
                    final investment = new Investment(_currency,_dateController.text,double.parse(_perPriceController.text), double.parse(_amountController.text));
                    Navigator.pop(context, investment);
                  }
                },
                child: Text('Ekle'),
              ),
            ),
            )
          ],
        ),
      )
    );
  }
}

class InvestmentCrud extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Yatırım Olustur'),
      ),
      body: new InvestmentForm()
    );
  }
}
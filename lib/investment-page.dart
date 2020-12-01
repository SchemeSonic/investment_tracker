import 'package:example_app/investment-crud.dart';
import 'package:flutter/material.dart';

class InvestmentPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
    floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context,MaterialPageRoute(builder: (context) => InvestmentCrud()))
          .then((result) {
            if(result == null) return;
            print("is created");
            print(result);
          });
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.blue
      )
  );
  }
}

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
var currentUser;
String currentUserEmail = "";
var currencies = {};
var currencyEnums = {
  0: "dolar",
  1: "euro",
  2: "gold"
};
var iconSet = {
  "dolar":  FaIcon(FontAwesomeIcons.dollarSign, size: 36.0),
  "euro":   FaIcon(FontAwesomeIcons.euroSign, size: 36.0),
  "gold":   FaIcon(FontAwesomeIcons.coins, size: 36.0),
  "red_dolar": FaIcon(FontAwesomeIcons.dollarSign, size: 36.0, color: Colors.red,),
  "green_dolar": FaIcon(FontAwesomeIcons.dollarSign, size: 36.0, color: Colors.green,),
  "red_euro": FaIcon(FontAwesomeIcons.euroSign, size: 36.0, color: Colors.red,),
  "green_euro": FaIcon(FontAwesomeIcons.euroSign, size: 36.0, color: Colors.green,),
  "red_gold": FaIcon(FontAwesomeIcons.coins, size: 36.0, color: Colors.red,),
  "green_gold": FaIcon(FontAwesomeIcons.coins, size: 36.0, color: Colors.green,)
};
var currencyPropNameMap = {
  "dolar": "USDTRY",
  "euro": "EURTRY",
  "gold": "GLDGR"
};

var currencyMap = {
  "dolar": "ABD DOLARI",
  "euro": "EURO",
  "gold": "Gram Altın"
};

var propNameCurrencyMap = {
  "USDTRY": "dolar",
  "EURTRY": "euro",
  "GLDGR": "gold"
};
var symbols = {
  "dolar": "\$",
  "euro": "€",
  "gold": "gr"
};

getCurrency(value) {
  var currencyType = currencyMap[currencyEnums[value]];
  var currency = currencies[currencyType];
  return currency;
}
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:xml2json/xml2json.dart';

class ApiClient {
  final xmlTransformer = Xml2Json();

  getTodaysExchangeRateV3() async {
    String url = "https://finans.truncgil.com/today.json";

    var response = await http.get(url);
    if (response.statusCode == 200) {
      var body = utf8.decode(response.bodyBytes);
      var currencies = json.decode(body);
      return currencies;
    } else {
      print('${response.statusCode}.');
      return {};
    }
  }

  getTodaysExchangeRateV2() async {
    String url = "https://api.bigpara.hurriyet.com.tr/doviz/headerlist/anasayfa";

    var response = await http.get(url);
    
    if (response.statusCode == 200) {
      var body = json.decode(response.body);
      var currencies = body['data'];
      return currencies;
    } else {
      print('${response.statusCode}.');
      return {};
    }
  }


  getTodaysExchangeRateV1() async {
    String url = "https://www.tcmb.gov.tr/kurlar/today.xml";

    var response = await http.get(url);
    
    if (response.statusCode == 200) {
      xmlTransformer.parse(response.body);
      var body = jsonDecode(xmlTransformer.toParker());
      var currencies = this._getCurrencies(body["Tarih_Date"]["Currency"]);
      return currencies;
    } else {
      print('${response.statusCode}.');
      return {};
    }
  }

  Map<String, Map<dynamic, dynamic>> _getCurrencies(currencyList) {
    var currencies = {
      "dolar": {},
      "euro": {},
      "gbp": {}
    };

    currencyList.forEach((currency) => {
      if(currency['Isim'] == 'ABD DOLARI')
        currencies['dolar'] = currency
      else if(currency['Isim'] == 'EURO')
        currencies['euro'] = currency
      else if(currency['CurrencyName'] == 'POUND STERLING'){
        currencies['gbp'] = currency,
        currencies['gbp']["Isim"] = "İNGİLİZ STERLİNİ"
      }
    });

    return currencies;
  }
}
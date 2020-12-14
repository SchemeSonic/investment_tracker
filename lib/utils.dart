class Utils {
  prepareCurrencies(currencies) {
    var dolarRate = currencies['ABD DOLARI'];
    dolarRate['ACIKLAMA'] = "DOLAR/TURK LIRASI";
    dolarRate['SEMBOL'] = "USDTRY";
    dolarRate['Satış'] = double.parse(dolarRate['Satış']);
    var euroRate = currencies['EURO'];
    euroRate['ACIKLAMA'] = "EURO/TURK LIRASI";
    euroRate['SEMBOL'] = "EURTRY";
    euroRate['Satış'] = double.parse(euroRate['Satış']);
    var goldRate = currencies['Gram Altın'];
    goldRate['ACIKLAMA'] = "ALTIN GRAM - TL";
    goldRate['SEMBOL'] = "GLDGR";
    goldRate['Satış'] = goldRate['Satış'].replaceFirst(RegExp(','), '.'); 
    goldRate['Satış'] = double.parse(goldRate['Satış']);
    return currencies;
  }
}

Utils UtilsService = new Utils();
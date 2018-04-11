import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:blockframe_daemon/controller/database/database.dart';
import 'package:blockframe_daemon/model/custom_candle.dart';
import 'package:test/test.dart';

HttpClient client = new HttpClient();

const int height = 514999;
Map block = {};

Future<Map> fetchBlock() async {

  HttpClientRequest request = await client.getUrl(Uri.parse('https://blockchain.info/pt/block-height/$height?format=json'));
  HttpClientResponse response = await request.close();

  Map block = JSON.decode(await response.transform(UTF8.decoder).join());

  return block['blocks'].first;

}

Future main() async {

  await Database.instance.open();

  block = await fetchBlock();

  group('blockchain.info',() {

    test('find latest timestamp', () async {

        var latest = await Database.instance.blockchain.findLastestTimestamp();
        expect(latest is int,true);

    });

  });

  group('Bitfinex',() {

    test('fetch candle data', () async {

      int older = await Database.instance.blockchain.findLastestTimestamp();
      int newer = block['time'];

      var candles = await Database.instance.bitfinex.fetchCandles(older * pow(10,6), newer * pow(10,6));
      expect(candles.length >= 0,true);

    });
    
    test('adjust candle data', () async {

      Map<String,num> data = {'volume': 147.81158993000005,	'open': 6749.60, 'high' : 6759.50, 'low' : 6749.60, 'close' :	6755.00 };

      List<CustomCandle> candles = await Database.instance.bitfinex.fetchCandlesByBlockHeight(516840);

      CustomCandle adjusted = CustomCandle.adjustValues(candles);

      expect(adjusted.volume == data['volume'],true);
      expect(adjusted.open == data['open'],true);
      expect(adjusted.high == data['high'],true);
      expect(adjusted.low == data['low'],true);
      expect(adjusted.close == data['close'],true);

    });

  });

}

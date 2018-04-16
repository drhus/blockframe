import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:blockframe_daemon/controller/database/dao/dao.dart';
import 'package:blockframe_daemon/controller/database/database.dart';
import 'package:blockframe_daemon/model/custom_candle.dart';
import 'package:test/test.dart';

HttpClient client = new HttpClient();

Blockchain blockchain = Database.instance.blockchain;
Bitfinex bitfinex = Database.instance.bitfinex;

Future<Map> fetchBlockFromURL(int height) async {

  HttpClientRequest request = await client.getUrl(Uri.parse('https://blockchain.info/pt/block-height/$height?format=json'));
  HttpClientResponse response = await request.close();

  Map block = JSON.decode(await response.transform(UTF8.decoder).join());

  return block['blocks'].first;

}

Future main() async {

  await Database.instance.open();

  group('blockchain.info',() {

    test('find latest timestamp', () async {

        var latest = await Database.instance.blockchain.findLastestTimestamp();
        expect(latest is int,true);

    });

    test('block exists', () async {

      expect(await blockchain.exists(516840),true);
      expect(await blockchain.exists(616840),false);

    });

    test('has next block', () async {

      expect(await blockchain.hasNext(516840),true);
      expect(await blockchain.hasNext(616840),false);

    });

    test('next block', () async {

      // Return results sorted descending
      List<Map> blocks = await blockchain.fetchLastBlocks(limit: 2);

      int next = await blockchain.next(blocks.last['height']);

      expect(next == blocks.first['height'],true);

    });

  });

  group('Bitfinex',() {

    test('fetch candle data', () async {

      int older = await blockchain.findLastestTimestamp();
      int newer = (await blockchain.fetchBlock(516840))['time'];

      var candles = await blockchain.fetchLatestBlock();
      expect(candles.length >= 0,true);

    });
    
    test('adjust candle data', () async {

      Map<String,num> data = {'volume': 147.81158993000005,	'open': 6749.60, 'high' : 6759.50, 'low' : 6749.60, 'close' :	6755.00 };

      List<CustomCandle> candles = await Database.instance.fetchCandlesByBlockHeight(516840);

      CustomCandle adjusted = CustomCandle.adjustValues(candles);

      expect(adjusted.volume == data['volume'],true);
      expect(adjusted.open == data['open'],true);
      expect(adjusted.high == data['high'],true);
      expect(adjusted.low == data['low'],true);
      expect(adjusted.close == data['close'],true);

    });

  });

}

import 'package:blockframe_daemon/controller/database.dart';
import 'package:blockframe_daemon/controller/websockets/bitfinex/bitfinex.dart';
import 'package:blockframe_daemon/controller/websockets/blockchain.info/blockchain.dart';

main(List<String> arguments) async {

  BlockChain blockchain = new BlockChain();
  Bitfinex bitfinex = new Bitfinex();

  await blockchain.connect();
  await Database.instance.open();

  blockchain.onBlockFrames.listen((Map blockChainData) async {

    await bitfinex.connect();

    bitfinex.onCandles.listen((List candles) async {

      await bitfinex.disconnect();

      blockChainData['candles'] = candles;
      await Database.instance.save(blockChainData);

    });

  });

}
# Blockframe Daemon

A daemon process that connects to some FOREX endpoints and saves price data information from different crypto currencies.

Current implementation listens to Bitcoin data from these 2 endpoints:

1. Bitfinex: wss://api.bitfinex.com/ws/2 - [API documentation](https://bitfinex.readme.io/v2/docs/ws-general)
2. Blockchain.info: wss://ws.blockchain.info/inv - [API documentation](https://blockchain.info/api/api_websocket)

The daemon subscribes to each of these websockets channels and listen for events.

# Installation

Dart
----

You need to install the Dart SDK. Instructions are available here: https://www.dartlang.org/install

Then run the file **main.dart** file inside the _bin_ folder.

For faster startups, use the [--snapshots](https://www.dartlang.org/dart-vm/tools/dart-vm#snapshot-option) parameters of the dart command line program. Example:

`dart --snapshot=blockframe-daemon main.dart`

Run
---

`dart blockframe-daemon`

Upon start the daemon will save Bitfinex candle tick data to a collection called _bitfinex_candle_ and as soon as new block frames are received it will save the data inside the _bitcoin_block_ collection. 

Mongo
-----

You also need to install the mongodb server.

https://docs.mongodb.com/manual/installation/

After you install it, create a database called blockframe. The daemon connects to the default _27017_ port.
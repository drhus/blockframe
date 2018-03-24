# Blockframe Daemon

A daemon process that connects to some FOREX endpoints and saves price data information from different crypto currencies.

Current implementation listens to Bitcoin data from these 2 endpoints:

1. Bitfinex: wss://api.bitfinex.com/ws/2 - [API documentation](https://bitfinex.readme.io/v2/docs/ws-general)
2. Blockchain.info: wss://ws.blockchain.info/inv - [API documentation](https://blockchain.info/api/api_websocket)

The daemon subscribes to each of these websockets channels and listen for events.

# Installation

After you install the Dart SDK as mentioned in the main README.md file, run
__pub get__ in order to fetch dependencies. 

Run
---

Create a snapshot of the `main.dart` file:

`dart --snapshot=blockframe-daemon main.dart`

Now run the daemon by using 

`dart blockframe-daemon`

If you are on Linux and installed **update-binfmts** add the execute flag to blockframe-daemon snapshot:

`chmod a+x blockframe-daemon`

Now you can run the blockframe-daemon just as any other executable on the system.
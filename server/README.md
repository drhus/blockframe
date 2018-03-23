# Blockframe Server

A server that provides a REST and Websocket endpoints for cryptocurrencies data.   

REST Endpoints
--------------

1. http://blockframe.xyz:8000/last/{number}

Fetches the last {_number_} blocks

2. http://blockframe.xyz:8000/range/{first}-{last}

Fetches block {_first_} through { _last_ } 

````

[
	{
		"_id": "5ab3fff59c0009ea778240b0",
		"txIndexes": [
			337865946,
			337859334
		],
		"nTx": 2004,
		"totalBTCSent": 919203881733,
		"estimatedBTCSent": 44093859759,
		"reward": 0,
		"size": 1154783,
		"weight": 3992924,
		"blockIndex": 1683005,
		"prevBlockIndex": 1684092,
		"height": 514710,
		"hash": "000000000000000000178adc82acaa4257b0b4415215b7b2a9059cada394162c",
		"mrklRoot": "9045d4c6a5ce36f16ba6a91a6b17401984934dceea50fd1749500db8571612da",
		"version": 536870912,
		"time": 1521745830,
		"bits": 391203401,
		"nonce": 3830603908,
		"foundBy": {
			"description": "Unknown",
			"ip": "127.0.0.1",
			"link": "http://www.blockchain.info/tx/2970491f977a88fcc1a7e5ef46e4e7d13755eb14d9a8e8c40710f0a01dd6f5d5",
			"time": 1521745830
		},
		"candle": {
			"luts": 1521745326185816,
			"candle": {
				"mts": 1521745320000,
				"open": 8649,
				"close": 8618.7,
				"high": 8670,
				"low": 8616,
				"volume": 2668.979939309999
			}
		}
	}
]

````

The daemon subscribes to each of these websockets channels and listen for events.

# Installation

Dart
----

You need to install the Dart SDK. Instructions are available here: https://www.dartlang.org/install

Then run the file **main.dart** file inside the _bin_ folder.

For faster startups, use the [--snapshots](https://www.dartlang.org/dart-vm/tools/dart-vm#snapshot-option) parameters of the dart command line program. Example:

`dart --snapshot=blockframe-server main.dart`

Run
---

`dart blockframe-daemon`

The application will start a HTTP server that listens to connections on port _8000_. It spawn isolates in order to handle incoming connections through the available cores at the local machine, thanks to the [Acqueduct Framework](https://aqueduct.io/).

If you're using Linux you can also run dart snapshots just as an executable file by using [update-binfmts]() 

sudo update-binfmts --package dart --install dart-script /usr/bin/dart --magic '\xf5\xf5\xdc\xdc'

<h1 align="center">
        <br>
        <img width="200" src="docs/img/logo.png" alt="blockFrame">
        <br>
        <h3 align="center">Blockframe Chart</h4>
        <br>
</h1>

Constructing a blockFrame chart as a graphical representations of a series of crypto asset price movements over block heights, -instead of time- where the basic graphical frame is one block, and the multipliers n blocks used for diverse graphical chart frames.

blockframe instead of timeframe charting, for a universe -Blockchain- where objective time doesn't exist, and succession materialize only by mining new blocks.

This project performs the following tasks:

1. **daemon**: a daemon that fetches crypto currencies information and OCHLV (open,close,high,low,volume) data from different sources.
2. **server**: a REST API with endpoints that shows crypto currencies historical data
3. **website**: the actual blockframe chart that represents block height X price instead of time X price.

Installation
------------

Dart
----

You need to install the Dart SDK. Instructions are available here: https://www.dartlang.org/install

After you install it, you need to run _pub get_ on both daemon and server root folders in order to fetch dependencies. 

For faster startups, use the [--snapshots](https://www.dartlang.org/dart-vm/tools/dart-vm#snapshot-option) parameters of the dart command line program.

If you're using Linux you can also run dart snapshots just as an executable file by using [update-binfmts]() 

  sudo update-binfmts --package dart --install dart-script /usr/bin/dart --magic '\xf5\xf5\xdc\xdc'

_See the README.md files in each folder for more details_

Mongo
-----

You also need to install the mongodb server.

https://docs.mongodb.com/manual/installation/

The daemon connects to the default _27017_ port.

Linux Systemd Scripts
---------------------

You can use the scripts located at scripts folders in order to stop and start the daemon as a _systemd_ service.
Modify the script to suit your own needs and check _systemd_ documentation for more information on how to use it.

## Contributing

Bug reports and pull requests are welcome at https://github.com/drhus/blockframe. check our TODO/Roadmap >> http://blockframe.xyz 
*If you have any questions please contact @kaede28*

### Maintainers

* [Daniel vieira](https://github.com/kaede28)
* [Husam](https://github.com/drhus)

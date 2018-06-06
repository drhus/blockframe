import 'package:blockframe_daemon/model/ohlcv.dart';

class Price extends OHLCV {

  /// millisecond time stamp
  int mts;

  int blockHeight;
  int blockTime;

  Price(this.blockHeight,this.blockTime,this.mts,num open, num close, num high, num low, num volume) : super(open, close, high, low, volume);

  @override
  String toString() {

    return 'Price{mts: $mts, blockHeight: $blockHeight, blockTime: $blockTime}';

  }

}
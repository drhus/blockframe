import 'package:blockframe_daemon/model/ohlcv.dart';
import 'package:quiver/core.dart';

class Candle extends OHLCV {

  /// millisecond time stamp
  int mts;

  Candle(this.mts,int open, int close, int high, int low, int volume) : super(open,close,high,low,volume);

  Map get asMap => { 'mts' : mts, 'open' : open, 'close' : close, 'high' : high, 'low' : low, 'volume' : volume };

  Candle.fromList(List data) :

        mts = data[0],
        super(data[1],data[2],data[3],data[4],data[5]);

  static Candle adjustValues(List<Candle> candles) {

    num open = candles.first.open;
    num close = candles.last.close;

    int mts = candles.last.mts;

    candles.sort((Candle a,Candle b) => a.high.compareTo(b.high));
    num high = candles.last.high;

    candles.sort((Candle a,Candle b) => a.low.compareTo(b.low));
    num low = candles.first.low;

    num volume = candles.fold(0, (num volume, Candle candle) => volume + candle.volume);

    return new Candle(mts, open, close, high, low, volume);

  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Candle &&
              runtimeType == other.runtimeType &&
              mts == other.mts &&
              open == other.open &&
              close == other.close &&
              high ==  other.close &&
              low ==  other.low &&
              volume == other.volume;

  @override
  int get hashCode => identityHashCode(this);
  int get candleHashCode => hashObjects([mts,open,close,high,low,volume]);

  @override
  String toString() {

    return 'Candle {mts: $mts, ${super.toString()}';

  }

}
import 'package:quiver/core.dart';

class Candle {

  Candle(this.mts, this.open, this.close, this.high, this.low, this.volume);

  /// MTS	int	millisecond time stamp
  int mts;

  /// OPEN	float	First execution during the time frame
  num open;

  /// CLOSE	float	Last execution during the time frame
  num close;

  /// HIGH	float	Highest execution during the time frame
  num high;

  /// LOW	float	Lowest execution during the timeframe
  num low;

  /// VOLUME	float	Quantity of symbol traded within the timeframe
  num volume;

  Map get asMap => { 'mts' : mts, 'open' : open, 'close' : close, 'high' : high, 'low' : low, 'volume' : volume };

  Candle.fromList(List data) :

        mts = data[0],
        open = data[1],
        close = data[2],
        high = data[3],
        low = data[4],
        volume = data[5];

  Candle.fromMap (Map candle) :

      mts = candle['mts'],
      open = candle['open'],
      close = candle['close'],
      high = candle['high'],
      low = candle['low'],
      volume = candle['volume'];

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

    return 'Candle {mts: $mts, open: $open, close: $close, high: $high, low: $low, volume: $volume}';

  }

}
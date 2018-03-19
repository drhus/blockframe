/// Provides a way to access charting candle info

class Candle {

  Candle(this.mts, this.open, this.close, this.high, this.low, this.volume);

  Candle.fromList(List<num> data) {

    mts = data[0] ~/ 1000;
    open = data[1];
    close = data[2];
    high = data[3];
    low = data[4];
    volume = data[5];

  }

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

  static Candle adjustValues(List<Candle> candles) {

    num open = candles.first.open;
    num close = candles.last.close;

    candles.sort((Candle a,Candle b) => a.high.compareTo(b.high));
    num high = candles.last.high;

    candles.sort((Candle a,Candle b) => a.low.compareTo(b.low));
    num low = candles.first.low;

    num volume = candles.fold(0, (num volume, Candle candle) => volume + candle.volume);

    return new Candle(candles.last.mts, open, close, high, low, volume);

  }

}
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

}
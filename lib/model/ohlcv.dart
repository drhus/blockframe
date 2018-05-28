class OHLCV {

  OHLCV(this.open, this.close, this.high, this.low, this.volume);

  /// First execution during the time frame
  num open;

  /// Last execution during the time frame
  num close;

  /// Highest execution during the time frame
  num high;

  /// Lowest execution during the timeframe
  num low;

  /// Quantity of symbol traded within the timeframe
  num volume;

  @override
  String toString() {

    return 'OHLCV{open: $open, close: $close, high: $high, low: $low, volume: $volume}';

  }

}
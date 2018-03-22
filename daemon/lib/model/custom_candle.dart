import 'dart:core';
import 'package:blockframe_daemon/model/candle.dart';
import 'package:quiver/core.dart';

class CustomCandle extends Candle {

  /// Local microsecond timestamp
  int luts;

  CustomCandle(this.luts,int mts,num open,num close, num high, num low, num volume) : super(mts, open, close, high, low, volume);

  CustomCandle.fromList(List<num> candle) : super(candle[0], candle[1], candle[2], candle[3], candle[4], candle[5]) {

    this.luts = new DateTime.now().microsecondsSinceEpoch;

    mts = candle[0];
    open = candle[1];
    close = candle[2];
    high = candle[3];
    low = candle[4];
    volume = candle[5];

  }

  Map get asMap => { 'luts' : luts, 'candle' : super.asMap};

  static CustomCandle adjustValues(List<CustomCandle> candles) {

    num open = candles.first.open;
    num close = candles.last.close;

    candles.sort((CustomCandle a,CustomCandle b) => a.high.compareTo(b.high));
    num high = candles.last.high;

    candles.sort((CustomCandle a,CustomCandle b) => a.low.compareTo(b.low));
    num low = candles.first.low;

    num volume = candles.fold(0, (num volume, CustomCandle candle) => volume + candle.volume);

    return new CustomCandle(candles.last.luts,candles.last.mts, open, close, high, low, volume);

  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is CustomCandle &&
              runtimeType == other.runtimeType &&
              luts == other.luts &&
              mts == other.mts &&
              open == other.open &&
              close == other.close &&
              high ==  other.close &&
              low ==  other.low &&
              volume == other.volume;

  @override
  int get hashCode => identityHashCode(this);
  int get candleHashCode => hashObjects([mts,open,close,high,low,volume]);

}
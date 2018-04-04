class Requests {

  static const String subscribeToCandles = '{"event":"subscribe","channel":"candles","key":"trade:1m:tBTCUSD"}';
  static String ping(int channelID) => '{"event":"ping","cid":$channelID}';

}
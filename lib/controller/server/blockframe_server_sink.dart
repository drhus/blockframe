import 'package:blockframe_daemon/controller/database/database.dart';
import 'package:blockframe_daemon/model/candle.dart';

import 'blockframe_server.dart';

/// This class handles setting up this application.
///
/// Override methods from [RequestSink] to set up the resources your
/// application uses and the routes it exposes.
///
/// See the documentation in this file for the constructor, [setupRouter] and [willOpen]
/// for the purpose and order of the initialization methods.
///
/// Instances of this class are the type argument to [Application].
/// See http://aqueduct.io/docs/http/request_sink
/// for more details.
class BlockframeServerSink extends RequestSink {

  /// Constructor called for each isolate run by an [Application].
  ///
  /// This constructor is called for each isolate an [Application] creates to serve requests.
  /// The [appConfig] is made up of command line arguments from `aqueduct serve`.
  ///
  /// Configuration of database connections, [HTTPCodecRepository] and other per-isolate resources should be done in this constructor.
  BlockframeServerSink(ApplicationConfiguration appConfig) : super(appConfig) {

    logger.onRecord.listen((rec) => print("$rec ${rec.error ?? ""} ${rec.stackTrace ?? ""}"));

  }

  /// All routes must be configured in this method.
  ///
  /// This method is invoked after the constructor and before [willOpen] Routes must be set up in this method, as
  /// the router gets 'compiled' after this method completes and routes cannot be added later.
  @override
  void setupRouter(Router router) {
    // Prefer to use `pipe` and `generate` instead of `listen`.
    // See: https://aqueduct.io/docs/http/request_controller/

    router.route("/last/[:blocks]").generate(() => new BlocksController());
    //router.route("/range/[:blocks]").generate(() => new RangeController());
    //router.route("/csv/blockframes").generate(() => new CSVBlockframes());
    //router.route("/csv/candles/[:height]").generate(() => new CSVCandlesByBlockFrame());

    /*router

        .route("/*")
        .pipe(new HTTPFileController("/home/daniel/developer/blockframe/resources/website")); */*/

  }

  /// Final initialization method for this instance.
  ///
  /// This method allows any resources that require asynchronous initialization to complete their
  /// initialization process. This method is invoked after [setupRouter] and prior to this
  /// instance receiving any requests.
  @override
  Future willOpen() async {

    await Database.instance.open();

  }

}

class BlocksController extends HTTPController {

  @httpGet
  Future<Response> getLastBlocks(@HTTPPath("blocks") int blocks) async {

    if (blocks > 0) {

      List<Map> data = await Database.instance.price.fetchLastPrices(limit: blocks);

      return new Response.ok(data)

        ..contentType = ContentType.JSON;

    }

    else return new Response.badRequest();

  }

}

class CSVBlockframes extends HTTPController {

  final String header = 'block height,microsecond timestamp,milisecond timestamp,volume,open,high,low,close';

  @httpGet
  Future<Response> getBlocks(@HTTPPath("height") int height) async {

    /*Price price = Database.instance.price;
    List<Map> blocks = [];

    StringBuffer csv = new StringBuffer();

    height == null

        ? blocks = await price.fetchLastPrices()
        : blocks.add(await price.priceCollection.find());

    // Header
    csv.writeln(header);

      blocks.forEach((Map block) {

        CustomCandle candle = new CustomCandle.fromList(block['price']['candle']);
        csv.writeln("${block['height']},${candle.luts},${candle.mts},${candle.volume},${candle.open},${candle.high},${candle.low},${candle.close}");

      });

      return new Response.ok(csv.toString())

        ..contentType = new ContentType("text", "csv", charset: "utf-8")
        ..headers = { 'Content-Disposition' : 'attachment; filename=blockframes.csv' }; */

    }

}

class CSVCandlesByBlockFrame extends HTTPController {

  final String header = 'block height,microsecond timestamp,milisecond timestamp,volume,open,high,low,close';

  @httpGet
  Future<Response> getCandlesByHeight(@HTTPPath("height") int height) async {

    StringBuffer csv = new StringBuffer();

    List<Candle> candles = await Database.instance.fetchCandlesByBlockHeight(height);

    csv.writeln(header);

    candles.forEach((Candle candle) {

      csv.writeln("$height,${candle.mts},${candle.volume},${candle.open},${candle.high},${candle.low},${candle.close}");

    });

    return new Response.ok(csv.toString())

      ..contentType = new ContentType("text", "csv", charset: "utf-8")
      ..headers = { 'Content-Disposition' : 'attachment; filename=block-${height}-candles.csv' };

  }

}

class RangeController extends HTTPController {

  @httpGet
  Future<Response> getBlocksByRange(@HTTPPath("range") String range) async {

    var blocks = range.split('-');

    int first = int.parse(blocks.first);
    int last = int.parse(blocks.last);

    List<Map> data = await Database.instance.blockchain.fetchBlocks(first,last);

    return new Response.ok(data)

      ..contentType = ContentType.JSON;

  }

}
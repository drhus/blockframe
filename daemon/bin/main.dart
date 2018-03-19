import 'dart:core';

import 'package:blockframe_daemon/controller/loader.dart';

main(List<String> arguments) async {

  Loader loader = new Loader();

  await loader.start();

}

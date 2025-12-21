import 'package:no_screenshot/no_screenshot.dart';

class ScreenshotOff {
  final _noScreenshot = NoScreenshot.instance;


  void screenshotOff() async {
    await _noScreenshot.screenshotOff();
  }

  void screenshotOn() async {
    await _noScreenshot.screenshotOn();
  }
}

void myScreenshotOn()  {
  ScreenshotOff().screenshotOn();
}

void myScreenshotOff() {
  ScreenshotOff().screenshotOff();
}

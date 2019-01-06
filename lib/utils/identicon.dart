import 'package:image/image.dart';

// Based on https://github.com/stewartlord/identicon.js
List<int> identicon(String hash, {
  size: 64,
  margin: 0.08,
  saturation: 0.7,
  brightness: 0.5,
}) {
  final image = Image(size, size);
  final background = Color.fromRgba(240, 240, 240, 255);
  final hue = int.parse(hash.substring(hash.length - 7), radix: 16) / 0xfffffff;
  final foreground = Color.fromHsl(hue, saturation, brightness);
  final baseMargin = (size * margin).floor();
  int cell = ((size - (baseMargin * 2)) / 5).floor();
  int margin1 = ((size - cell * 5) / 2).floor();

  final rect = (int x, int y, int w, int h, int color) {
    for (int i = x; i < x + w; i++)
      for (int j = y; j < y + h; j++)
        image.setPixel(i, j, color);
  };

  int i = 0;
  int color;
  for (i = 0; i < 15; i++) {
    color = int.parse(hash[i], radix: 16) % 2 > 0 ? background : foreground;
    if (i < 5) {
      rect(2 * cell + margin1, i * cell + margin1, cell, cell, color);
    } else if (i < 10) {
      rect(1 * cell + margin1, (i - 5) * cell + margin1, cell, cell, color);
      rect(3 * cell + margin1, (i - 5) * cell + margin1, cell, cell, color);
    } else if (i < 15) {
      rect(0 * cell + margin1, (i - 10) * cell + margin1, cell, cell, color);
      rect(4 * cell + margin1, (i - 10) * cell + margin1, cell, cell, color);
    }
  }

  return encodePng(image);
}


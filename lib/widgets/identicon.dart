import 'package:flutter/material.dart';
import 'package:whalechat_app/models/identity.dart';
import 'package:whalechat_app/utils/identicon.dart';

class Identicon {
  static final _cache = Map<String, Image>();

  static Image of(Identity identity) {
    if (!_cache.containsKey(identity.publicKey))
      _cache[identity.publicKey] = Image.memory(identicon(identity.publicKey));
    return _cache[identity.publicKey];
  }
}

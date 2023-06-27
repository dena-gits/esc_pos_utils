/*
 * esc_pos_utils
 * Created by Andrey U.
 * 
 * Copyright (c) 2019-2020. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import 'dart:convert' show json;

import 'package:flutter/services.dart' show rootBundle;

class PosCodePage {
  PosCodePage(this.id, this.name);
  int id;
  String name;
}

class PosCapabilityProfile {
  PosCapabilityProfile._internal(this.name, this.codePages);

  /// Public factory
  static Future<PosCapabilityProfile> load({String name = 'default'}) async {
    final content = await rootBundle
        .loadString('packages/esc_pos_utils/resources/capabilities.json');
    Map capabilities = json.decode(content);

    var profile = capabilities['profiles'][name];

    if (profile == null) {
      throw Exception("The CapabilityProfile '$name' does not exist");
    }

    List<PosCodePage> list = [];
    profile['codePages'].forEach((k, v) {
      list.add(PosCodePage(int.parse(k), v));
    });

    // Call the private constructor
    return PosCapabilityProfile._internal(name, list);
  }

  String name;
  List<PosCodePage>? codePages;

  int getCodePageId(String? codePage) {
    if (codePages == null) {
      throw Exception("The CapabilityProfile isn't initialized");
    }

    return codePages!
        .firstWhere((cp) => cp.name == codePage,
            orElse: () => throw Exception(
                "Code Page '$codePage' isn't defined for this profile"))
        .id;
  }

  static Future<List<dynamic>> getAvailableProfiles() async {
    final content = await rootBundle
        .loadString('packages/esc_pos_utils/resources/capabilities.json');
    Map capabilities = json.decode(content);

    var profiles = capabilities['profiles'];

    List<dynamic> res = [];

    profiles.forEach((k, v) {
      res.add({
        'key': k,
        'vendor': v['vendor'] is String ? v['vendor'] : '',
        'model': v['model'] is String ? v['model'] : '',
        'description': v['description'] is String ? v['description'] : '',
      });
    });

    return res;
  }
}

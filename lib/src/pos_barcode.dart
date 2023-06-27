/*
 * esc_pos_utils
 * Created by Andrey U.
 * 
 * Copyright (c) 2019-2020. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

class PosBarcodeType {
  const PosBarcodeType._internal(this.value);
  final int value;

  /// UPC-A
  static const upcA = PosBarcodeType._internal(0);

  /// UPC-E
  static const upcE = PosBarcodeType._internal(1);

  /// JAN13 (EAN13)
  static const ean13 = PosBarcodeType._internal(2);

  /// JAN8 (EAN8)
  static const ean8 = PosBarcodeType._internal(3);

  /// CODE39
  static const code39 = PosBarcodeType._internal(4);

  /// ITF (Interleaved 2 of 5)
  static const itf = PosBarcodeType._internal(5);

  /// CODABAR (NW-7)
  static const codabar = PosBarcodeType._internal(6);

  /// CODE128
  static const code128 = PosBarcodeType._internal(73);
}

class PosBarcodeText {
  const PosBarcodeText._internal(this.value);
  final int value;

  /// Not printed
  static const none = PosBarcodeText._internal(0);

  /// Above the barcode
  static const above = PosBarcodeText._internal(1);

  /// Below the barcode
  static const below = PosBarcodeText._internal(2);

  /// Both above and below the barcode
  static const both = PosBarcodeText._internal(3);
}

class PosBarcodeFont {
  const PosBarcodeFont._internal(this.value);
  final int value;

  static const fontA = PosBarcodeFont._internal(0);
  static const fontB = PosBarcodeFont._internal(1);
  static const fontC = PosBarcodeFont._internal(2);
  static const fontD = PosBarcodeFont._internal(3);
  static const fontE = PosBarcodeFont._internal(4);
  static const specialA = PosBarcodeFont._internal(97);
  static const specialB = PosBarcodeFont._internal(98);
}

class PosBarcode {
  /// UPC-A
  ///
  /// k = 11, 12
  /// d = '0' – '9'
  PosBarcode.upcA(List<dynamic> barcodeData) {
    final k = barcodeData.length;
    if (![11, 12].contains(k)) {
      throw Exception('Barcode: Wrong data range');
    }

    final numeric = RegExp(r'^[0-9]$');
    final bool isDataValid =
        barcodeData.every((dynamic d) => numeric.hasMatch(d.toString()));
    if (!isDataValid) {
      throw Exception('Barcode: Data is not valid');
    }

    _type = PosBarcodeType.upcA;
    _data = _convertData(barcodeData);
  }

  /// UPC-E
  ///
  /// k = 6 – 8, 11, 12
  /// d = '0' – '9' (However, d0 = '0' when k = 7, 8, 11, 12)
  PosBarcode.upcE(List<dynamic> barcodeData) {
    final k = barcodeData.length;
    if (![6, 7, 8, 11, 12].contains(k)) {
      throw Exception('Barcode: Wrong data range');
    }

    if ([7, 8, 11, 12].contains(k) && barcodeData[0].toString() != '0') {
      throw Exception('Barcode: Data is not valid');
    }

    final numeric = RegExp(r'^[0-9]$');
    final bool isDataValid =
        barcodeData.every((dynamic d) => numeric.hasMatch(d.toString()));
    if (!isDataValid) {
      throw Exception('Barcode: Data is not valid');
    }

    _type = PosBarcodeType.upcE;
    _data = _convertData(barcodeData);
  }

  /// JAN13 (EAN13)
  ///
  /// k = 12, 13
  /// d = '0' – '9'
  PosBarcode.ean13(List<dynamic> barcodeData) {
    final k = barcodeData.length;
    if (![12, 13].contains(k)) {
      throw Exception('Barcode: Wrong data range');
    }

    final numeric = RegExp(r'^[0-9]$');
    final bool isDataValid =
        barcodeData.every((dynamic d) => numeric.hasMatch(d.toString()));
    if (!isDataValid) {
      throw Exception('Barcode: Data is not valid');
    }

    _type = PosBarcodeType.ean13;
    _data = _convertData(barcodeData);
  }

  /// JAN8 (EAN8)
  ///
  /// k = 7, 8
  /// d = '0' – '9'
  PosBarcode.ean8(List<dynamic> barcodeData) {
    final k = barcodeData.length;
    if (![7, 8].contains(k)) {
      throw Exception('Barcode: Wrong data range');
    }

    final numeric = RegExp(r'^[0-9]$');
    final bool isDataValid =
        barcodeData.every((dynamic d) => numeric.hasMatch(d.toString()));
    if (!isDataValid) {
      throw Exception('Barcode: Data is not valid');
    }

    _type = PosBarcodeType.ean8;
    _data = _convertData(barcodeData);
  }

  /// CODE39
  ///
  /// k >= 1
  /// d: '0'–'9', A–Z, SP, $, %, *, +, -, ., /
  PosBarcode.code39(List<dynamic> barcodeData) {
    final k = barcodeData.length;
    if (k < 1) {
      throw Exception('Barcode: Wrong data range');
    }

    final regex = RegExp(r'^[0-9A-Z \$\%\*\+\-\.\/]$');
    final bool isDataValid =
        barcodeData.every((dynamic d) => regex.hasMatch(d.toString()));
    if (!isDataValid) {
      throw Exception('Barcode: Data is not valid');
    }

    _type = PosBarcodeType.code39;
    _data = _convertData(barcodeData);
  }

  /// ITF (Interleaved 2 of 5)
  ///
  /// k >= 2 (even number)
  /// d = '0'–'9'
  PosBarcode.itf(List<dynamic> barcodeData) {
    final k = barcodeData.length;
    if (k < 2 || !k.isEven) {
      throw Exception('Barcode: Wrong data range');
    }

    final numeric = RegExp(r'^[0-9]$');
    final bool isDataValid =
        barcodeData.every((dynamic d) => numeric.hasMatch(d.toString()));
    if (!isDataValid) {
      throw Exception('Barcode: Data is not valid');
    }

    _type = PosBarcodeType.itf;
    _data = _convertData(barcodeData);
  }

  /// CODABAR (NW-7)
  ///
  /// k >= 2
  /// d: '0'–'9', A–D, a–d, $, +, −, ., /, :
  /// However, d0 = A–D, dk = A–D (65-68)
  /// d0 = a-d, dk = a-d (97-100)
  PosBarcode.codabar(List<dynamic> barcodeData) {
    final k = barcodeData.length;
    if (k < 2) {
      throw Exception('Barcode: Wrong data range');
    }

    final regex = RegExp(r'^[0-9A-Da-d\$\+\-\.\/\:]$');
    final bool isDataValid =
        barcodeData.every((dynamic d) => regex.hasMatch(d.toString()));
    if (!isDataValid) {
      throw Exception('Barcode: Data is not valid');
    }

    if ((_charcode(barcodeData[0]) >= 65 && _charcode(barcodeData[0]) <= 68) &&
        !(_charcode(barcodeData[k - 1]) >= 65 &&
            _charcode(barcodeData[k - 1]) <= 68)) {
      throw Exception('Barcode: Wrong data range');
    }

    if ((_charcode(barcodeData[0]) >= 97 && _charcode(barcodeData[0]) <= 100) &&
        !(_charcode(barcodeData[k - 1]) >= 97 &&
            _charcode(barcodeData[k - 1]) <= 100)) {
      throw Exception('Barcode: Wrong data range');
    }

    _type = PosBarcodeType.codabar;
    _data = _convertData(barcodeData);
  }

  /// CODE128
  ///
  /// k >= 2
  /// d: '{A'/'{B'/'{C' => '0'–'9', A–D, a–d, $, +, −, ., /, :
  /// usage:
  /// {A = QRCode type A
  /// {B = QRCode type B
  /// {C = QRCode type C
  /// barcodeData ex.: "{A978020137962".split("");
  PosBarcode.code128(List<dynamic> barcodeData) {
    final k = barcodeData.length;
    if (k < 2) {
      throw Exception('Barcode: Wrong data range');
    }

    final regex = RegExp(r'^\{[A-C][\x00-\x7F]+$');
    final bool isDataValid = regex.hasMatch(barcodeData.join());

    if (!isDataValid) {
      throw Exception('Barcode: Data is not valid');
    }

    _type = PosBarcodeType.code128;
    _data = _convertData(barcodeData);
  }

  PosBarcodeType? _type;
  List<int>? _data;

  List<int> _convertData(List<dynamic> list) =>
      list.map((dynamic d) => d.toString().codeUnitAt(0)).toList();

  int _charcode(dynamic ch) => ch.toString().codeUnitAt(0);

  PosBarcodeType? get type => _type;
  List<int>? get data => _data;
}

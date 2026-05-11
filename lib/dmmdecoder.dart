const xorKey = [
  0x41,
  0x21,
  0x73,
  0x55,
  0xA2,
  0xC1,
  0x32,
  0x71,
  0x66,
  0xAA,
  0x3B,
  0xD0,
  0xE2,
  0xA8,
  0x33,
  0x14,
  0x20,
  0x21,
  0xAA,
  0xBB,
];

const digitMap = {
  "1111101": "0",
  "0000101": "1",
  "1011011": "2",
  "0011111": "3",
  "0100111": "4",
  "0111110": "5",
  "1111110": "6",
  "0010101": "7",
  "1111111": "8",
  "0111111": "9",
  "1110111": "A",
  "1001100": "u",
  "1101010": "t",
  "1001110": "o",
  "1101000": "L",
  "1111010": "E",
  "1110010": "F",
  "0000000": " ",
  "0000010": "-",
};

List<int> parseHex(String data) =>
    data.split(' ').map((e) => int.parse(e, radix: 16)).toList();

String reverseBits(int value) =>
    value.toRadixString(2).padLeft(8, '0').split('').reversed.join();

String decodeDisplay(String bits) {
  final groups = [
    for (int i = 0; i < bits.length; i += 8) bits.substring(i, i + 8),
  ];

  final out = StringBuffer();

  for (int i = 0; i < groups.length; i++) {
    final group = groups[i];

    if (i == 0 && group[0] == '1') {
      out.write('-');
    }

    if (i > 0 && group[0] == '1') {
      out.write('.');
    }

    out.write(digitMap[group.substring(1)] ?? '?');
  }

  return out.toString();
}

List<String> decodeIcons(String bits, String typeID) {
  final icons = typeID == "11"
      ? [
          "LowBattery",
          "Delta",
          "BT",
          "BUZ",
          "HOLD",
          "oF",
          "oC",
          "DIODE",
          "MAX",
          "MIN",
          "%",
          "AC",
          "F",
          "u(F)",
          "m(F)",
          "n(F)",
          "Hz",
          "ohm",
          "K(ohm)",
          "M(ohm)",
          "V",
          "m(V)",
          "DC",
          "A",
          "AUTO",
          "?7",
          "u(A)",
          "m(A)",
          "?8",
          "?9",
          "?10",
          "?11",
        ]
      : [
          "?1",
          "HOLD",
          "FLASH",
          "BUZ",
          " ",
          " ",
          " ",
          " ",
          "NANO",
          "V",
          "DC",
          "AC",
          "F",
          "DIODE",
          "A",
          "u(F)",
          "ohm",
          "K(ohm)",
          "M(ohm)",
          " ",
          "Hz",
          "ºF",
          "ºC",
        ];

  return [
    for (int i = 0; i < bits.length && i < icons.length; i++)
      if (bits[i] == '1') icons[i],
  ];
}

Map<String, dynamic> decode(dynamic data) {
  final bytes = switch (data) {
    String s => parseHex(s),
    List<int> l => l,
    _ => throw Exception("Invalid input"),
  };

  final binary = List.generate(
    bytes.length,
    (i) => reverseBits(bytes[i] ^ xorKey[i]),
  ).join();

  final typeID = binary.substring(16, 18);

  return {
    "typeID": typeID,
    "display": decodeDisplay(binary.substring(28, 60)),
    "icons": decodeIcons(
      binary.substring(24, 28) + binary.substring(60, 87),
      typeID,
    ),
  };
}

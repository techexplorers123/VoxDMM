import 'package:voxdmm/enums/meter_enums.dart';
import 'package:voxdmm/models/meter_state.dart';
import 'speech_service.dart';

class MeterProcessor {
  String? lastSpokenValue;
  String? lastStableValue;
  DateTime lastChangeTime = DateTime.now();
  final SpeechService speech;
  MeterProcessor(this.speech);
  MeterState old = MeterState();
  final Map<Family, dynamic> unitTables = {
    Family.auto: "Auto",
    Family.voltageV: "volts",
    Family.voltageMV: "millivolts",
    Family.currentA: "amps",
    Family.currentMA: "milliamps",
    Family.currentU: "micro amps",
    Family.frequency: "hertz",
    Family.duty: "%",
    Family.temperatureC: "celsius",
    Family.temperatureF: "fahrenheit",
    Family.diodeContinuity: "volts",
    Family.resistance: {
      ResistanceUnit.ohm: "ohms",
      ResistanceUnit.kOhm: "kiloohms",
      ResistanceUnit.mOhm: "megaohms",
    },
    Family.capacitance: {
      CapacitanceUnit.uFarads: "micro farads",
      CapacitanceUnit.nFarads: "nano farads",
      CapacitanceUnit.mFarads: "milli farads",
    },
  };
  final Map<Family, String> modeNames = {
    Family.auto: "auto",
    Family.voltageV: "voltage",
    Family.voltageMV: "millivolt",
    Family.currentA: "amp",
    Family.currentMA: "milliamp",
    Family.currentU: "microamp",
    Family.resistance: "resistance",
    Family.capacitance: "capacitance",
    Family.frequency: "frequency",
    Family.duty: "duty cycle",
    Family.temperatureC: "celsius",
    Family.temperatureF: "fahrenheit",
    Family.diodeContinuity: "continuity diode test",
    Family.ncv: "non-contact voltage",
  };
  bool isOverload(String display) {
    final cleaned = display
        .toUpperCase()
        .replaceAll(".", "")
        .replaceAll(" ", "")
        .replaceAll("-", "");
    if (["OL", "0L", "L", "I", "1"].contains(cleaned)) {
      return true;
    }
    return cleaned.contains("OL");
  }

  MinMaxMode decodeMinMax(Set<String> icons) {
    if (icons.contains("MAX")) {
      return MinMaxMode.max;
    }
    if (icons.contains("MIN")) {
      return MinMaxMode.min;
    }
    return MinMaxMode.none;
  }

  RangeMode decodeRange(Set<String> icons) {
    if (icons.contains("AUTO")) {
      return RangeMode.auto;
    }
    return RangeMode.manual;
  }

  ACDC decodeACDC(Set<String> icons) {
    if (icons.contains("DC")) {
      return ACDC.dc;
    }
    if (icons.contains("AC")) {
      return ACDC.ac;
    }
    return ACDC.none;
  }

  CapacitanceUnit decodeCapacitanceUnit(Set<String> icons) {
    if (icons.contains("u(F)")) {
      return CapacitanceUnit.uFarads;
    }
    if (icons.contains("m(F)")) {
      return CapacitanceUnit.mFarads;
    }
    return CapacitanceUnit.nFarads;
  }

  ResistanceUnit decodeResistanceUnit(Set<String> icons) {
    if (icons.contains("K(ohm)")) {
      return ResistanceUnit.kOhm;
    }
    if (icons.contains("M(ohm)")) {
      return ResistanceUnit.mOhm;
    }
    return ResistanceUnit.ohm;
  }

  String resolveUnit(MeterState state) {
    final unit = unitTables[state.family];
    if (unit is Map) {
      if (state.family == Family.resistance) {
        return unit[state.resistanceUnit] ?? "";
      }
      if (state.family == Family.capacitance) {
        return unit[state.capacitanceUnit] ?? "";
      }
    }
    return unit ?? "";
  }

  String acdcPrefix(MeterState state) {
    if (state.acdc == ACDC.ac) {
      return "AC";
    }
    if (state.acdc == ACDC.dc) {
      return "DC";
    }
    return "";
  }

  bool nearlyEqual(String a, String? b, [double tolerance = 0.02]) {
    try {
      final aa = double.parse(a);
      final bb = double.parse(b ?? "");
      return (aa - bb).abs() <= tolerance;
    } catch (_) {
      return a == b;
    }
  }

  MeterState decodeMeterState(String display, Set<String> icons) {
    final state = MeterState();
    state.value = display;
    if (icons.contains("m(V)")) {
      state.family = Family.voltageMV;
      state.rangeEnabled = true;
    } else if (icons.contains("V")) {
      state.family = Family.voltageV;
      state.rangeEnabled = true;
    } else if (icons.contains("u(A)")) {
      state.family = Family.currentU;
      state.rangeEnabled = true;
    } else if (icons.contains("m(A)")) {
      state.family = Family.currentMA;
      state.rangeEnabled = true;
    } else if (icons.contains("A")) {
      state.family = Family.currentA;
      state.rangeEnabled = true;
    } else if (icons.contains("Hz")) {
      state.family = Family.frequency;
    }
    if (display == "Auto") {
      state.family = Family.auto;
      state.rangeEnabled = false;
    }
    if (display.contains("EF")) {
      state.family = Family.ncv;
      state.rangeEnabled = false;
    }
    if (icons.contains("ohm") && !icons.contains("BUZ")) {
      state.family = Family.resistance;
      state.rangeEnabled = true;
      state.resistanceUnit = decodeResistanceUnit(icons);
    }
    if (icons.contains("BUZ") || icons.contains("DIODE")) {
      state.family = Family.diodeContinuity;
      state.rangeEnabled = false;
    }
    if (icons.contains("F")) {
      state.family = Family.capacitance;
      state.rangeEnabled = false;
      state.capacitanceUnit = decodeCapacitanceUnit(icons);
    }
    state.acdc = decodeACDC(icons);
    state.rangeMode = decodeRange(icons);
    state.minMax = decodeMinMax(icons);
    state.hold = icons.contains("HOLD");
    state.relative = icons.contains("Delta");
    state.lowBattery = icons.contains("LowBattery");
    state.overload = isOverload(display);
    state.continuity = icons.contains("BUZ");
    state.diode = icons.contains("DIODE");
    state.unit = resolveUnit(state);
    return state;
  }

  String? announceMode(MeterState newer, MeterState older) {
    if (newer.family != older.family || newer.acdc != older.acdc) {
      final mode = modeNames[newer.family];
      if (mode == null) {
        return null;
      }
      return "${acdcPrefix(newer)} $mode mode";
    }
    return null;
  }

  String? announceValue(MeterState newer, MeterState older) {
    if (newer.overload) return null;
    if (newer.family != older.family) {
      return null;
    }
    if (newer.family == Family.auto) {
      return null;
    }
    if (newer.rangeMode != older.rangeMode) {
      return null;
    }
    if (newer.hold) {
      return null;
    }
    final now = DateTime.now();
    if (!nearlyEqual(newer.value, lastStableValue)) {
      lastStableValue = newer.value;
      lastChangeTime = now;
      return null;
    }
    final diff = now.difference(lastChangeTime).inMilliseconds;
    if (diff < 500) {
      return null;
    }
    final spoken = "${newer.value} ${newer.unit}";
    if (spoken == lastSpokenValue) {
      return null;
    }
    lastSpokenValue = spoken;
    return "$spoken ${acdcPrefix(newer)}";
  }

  String? announceSpecial(MeterState newer, MeterState older) {
    if (newer.overload && newer.overload != older.overload) {
      return "overload";
    }
    if (newer.minMax != older.minMax) {
      if (newer.minMax == MinMaxMode.max) {
        return "max mode";
      }
      if (newer.minMax == MinMaxMode.min) {
        return "min mode";
      }
      return "min max disabled";
    }
    if (newer.lowBattery && newer.lowBattery != older.lowBattery) {
      return "low battery";
    }
    if (newer.relative != older.relative) {
      return newer.relative
          ? "relative mode enabled"
          : "relative mode disabled";
    }
    if (newer.hold != older.hold) {
      return newer.hold ? "hold value ${newer.value}" : "resume";
    }
    return null;
  }

  Future<void> processState(MeterState newer) async {
    String? msg;
    msg = announceMode(newer, old);
    if (msg != null) {
      await speech.speak(msg, interrupt: true);
    } else {
      msg = announceSpecial(newer, old);
      if (msg != null) {
        await speech.speak(msg, interrupt: true);
      } else {
        msg = announceValue(newer, old);
        if (msg != null) {
          await speech.speak(msg);
        }
      }
    }
    old = newer.copy();
  }
}

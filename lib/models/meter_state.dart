import 'package:voxdmm/enums/meter_enums.dart';

class MeterState {
  Family? family;
  ResistanceUnit? resistanceUnit;
  CapacitanceUnit? capacitanceUnit;
  ACDC acdc;
  bool continuity;
  bool rangeEnabled;
  RangeMode rangeMode;
  MinMaxMode minMax;
  int rangeIndex;
  String value;
  String unit;
  bool overload;
  bool hold;
  bool relative;
  bool lowBattery;
  MeterState({
    this.family,
    this.resistanceUnit,
    this.capacitanceUnit,
    this.acdc = ACDC.none,
    this.continuity = false,
    this.rangeEnabled = false,
    this.rangeMode = RangeMode.auto,
    this.minMax = MinMaxMode.none,
    this.rangeIndex = 0,
    this.value = "",
    this.unit = "",
    this.overload = false,
    this.hold = false,
    this.relative = false,
    this.lowBattery = false,
  });

  MeterState copy() {
    return MeterState(
      family: family,
      resistanceUnit: resistanceUnit,
      capacitanceUnit: capacitanceUnit,
      acdc: acdc,
      continuity: continuity,
      rangeEnabled: rangeEnabled,
      rangeMode: rangeMode,
      minMax: minMax,
      rangeIndex: rangeIndex,
      value: value,
      unit: unit,
      overload: overload,
      hold: hold,
      relative: relative,
      lowBattery: lowBattery,
    );
  }
}

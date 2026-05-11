enum Family {
  RESISTANCE,
  FREQUENCY,
  DUTY,
  NCV,
  TEMPERATURE_C,
  TEMPERATURE_F,
  DIODE_CONTINUITY,
  CAPACITANCE,
  VOLTAGE_V,
  VOLTAGE_MV,
  CURRENT_A,
  CURRENT_MA,
  CURRENT_U,
  AUTO,
}

enum Resistance_Unit { OHM, K_OHM, M_OHM }

enum Capacitance_Unit { U_FARADS, N_FARADS, M_FARADS }

enum ACDC { AC, DC, none }

enum RangeMode { AUTO, MANUAL }

enum MinMaxMode { NONE, MIN, MAX }

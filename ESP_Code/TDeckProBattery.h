// LilyGO T-Deck Pro — BQ27220 fuel gauge (I2C 0x55, SDA=13, SCL=14)
#ifndef TDECK_PRO_BATTERY_H
#define TDECK_PRO_BATTERY_H

#if defined(LILYGO_T_DECK_PRO)

#include <Arduino.h>
#include <Wire.h>

#ifndef TDECK_PRO_I2C_SDA
  #define TDECK_PRO_I2C_SDA 13
#endif
#ifndef TDECK_PRO_I2C_SCL
  #define TDECK_PRO_I2C_SCL 14
#endif
#ifndef TDECK_PRO_BQ27220_ADDR
  #define TDECK_PRO_BQ27220_ADDR 0x55
#endif

#define BQ27220_CMD_BATTERY_STATUS  0x0A
#define BQ27220_CMD_STATE_OF_CHARGE 0x2C

static bool tdeck_pro_battery_ready = false;
static int tdeck_pro_battery_pct = -1;
static bool tdeck_pro_battery_charging = false;
static uint32_t tdeck_pro_battery_last_ms = 0;

inline bool tdeck_pro_bq27220_read_u16(uint8_t reg, uint16_t &out) {
  Wire.beginTransmission(TDECK_PRO_BQ27220_ADDR);
  Wire.write(reg);
  if (Wire.endTransmission(false) != 0) {
    return false;
  }
  if (Wire.requestFrom((uint8_t)TDECK_PRO_BQ27220_ADDR, (uint8_t)2) != 2) {
    return false;
  }
  uint8_t lo = Wire.read();
  uint8_t hi = Wire.read();
  out = ((uint16_t)hi << 8) | lo;
  return true;
}

inline void tdeck_pro_battery_update() {
  if (!tdeck_pro_battery_ready) {
    return;
  }
  uint32_t now = millis();
  if (tdeck_pro_battery_last_ms != 0 && (now - tdeck_pro_battery_last_ms) < 10000) {
    return;
  }
  tdeck_pro_battery_last_ms = now;

  uint16_t soc = 0;
  uint16_t status = 0;
  if (!tdeck_pro_bq27220_read_u16(BQ27220_CMD_STATE_OF_CHARGE, soc)) {
    tdeck_pro_battery_ready = false;
    return;
  }
  tdeck_pro_battery_pct = (soc > 100) ? 100 : (int)soc;

  if (tdeck_pro_bq27220_read_u16(BQ27220_CMD_BATTERY_STATUS, status)) {
    // DSG (bit 0): 1 = discharging, 0 = charging or at rest on USB
    tdeck_pro_battery_charging = !(status & 0x0001);
  }
}

inline void tdeck_pro_battery_init() {
  Wire.begin(TDECK_PRO_I2C_SDA, TDECK_PRO_I2C_SCL);
  delay(10);
  Wire.beginTransmission(TDECK_PRO_BQ27220_ADDR);
  tdeck_pro_battery_ready = (Wire.endTransmission() == 0);
  #if defined(SERIAL_PRINTING)
    if (tdeck_pro_battery_ready) {
      Serial.println("Battery: BQ27220 detected");
    } else {
      Serial.println("Battery: BQ27220 not found on I2C");
    }
    Serial.flush();
  #endif
  if (tdeck_pro_battery_ready) {
    tdeck_pro_battery_last_ms = 0;
    tdeck_pro_battery_update();
  }
}

inline bool tdeck_pro_battery_get(int &pct, bool &charging) {
  tdeck_pro_battery_update();
  if (!tdeck_pro_battery_ready || tdeck_pro_battery_pct < 0) {
    return false;
  }
  pct = tdeck_pro_battery_pct;
  charging = tdeck_pro_battery_charging;
  return true;
}

#endif
#endif

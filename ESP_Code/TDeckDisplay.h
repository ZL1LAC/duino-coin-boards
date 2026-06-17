#ifndef TDECK_DISPLAY_H
#define TDECK_DISPLAY_H

#if defined(LILYGO_T_DECK) && defined(DISPLAY_ST7789)

#include <Arduino.h>
#include <SPI.h>
#include <TFT_eSPI.h>

#ifndef TDECK_POWER_ON
  #define TDECK_POWER_ON 10
#endif
#ifndef TDECK_TFT_CS
  #define TDECK_TFT_CS 12
#endif
#ifndef TDECK_SDCARD_CS
  #define TDECK_SDCARD_CS 39
#endif
#ifndef TDECK_LORA_CS
  #define TDECK_LORA_CS 9
#endif
#ifndef TDECK_TFT_BL
  #define TDECK_TFT_BL 42
#endif
#ifndef TDECK_SPI_SCK
  #define TDECK_SPI_SCK 40
#endif
#ifndef TDECK_SPI_MISO
  #define TDECK_SPI_MISO 38
#endif
#ifndef TDECK_SPI_MOSI
  #define TDECK_SPI_MOSI 41
#endif

inline void tdeck_backlight_set(uint8_t value) {
  static uint8_t level = 0;
  const uint8_t steps = 16;
  if (value == 0) {
    digitalWrite(TDECK_TFT_BL, LOW);
    delay(3);
    level = 0;
    return;
  }
  if (level == 0) {
    digitalWrite(TDECK_TFT_BL, HIGH);
    level = steps;
    delayMicroseconds(30);
  }
  int from = steps - level;
  int to = steps - value;
  int num = (steps + to - from) % steps;
  for (int i = 0; i < num; i++) {
    digitalWrite(TDECK_TFT_BL, LOW);
    digitalWrite(TDECK_TFT_BL, HIGH);
  }
  level = value;
}

struct TDeckLcdCmd {
  uint8_t cmd;
  uint8_t data[14];
  uint8_t len;
};

static const TDeckLcdCmd TDECK_LCD_INIT[] = {
  {0x01, {0}, 0x80},
  {0x11, {0}, 0x80},
  {0x3A, {0x05}, 1},
  {0x36, {0x55}, 1},
  {0xB2, {0x0C, 0x0C, 0x00, 0x33, 0x33}, 5},
  {0xB7, {0x75}, 1},
  {0xBB, {0x1A}, 1},
  {0xC0, {0x2C}, 1},
  {0xC2, {0x01}, 1},
  {0xC3, {0x13}, 1},
  {0xC4, {0x20}, 1},
  {0xC6, {0x0F}, 1},
  {0xD0, {0xA4, 0xA1}, 2},
  {0xD6, {0xA1}, 1},
  {0xE0, {0xD0, 0x0D, 0x14, 0x0D, 0x0D, 0x09, 0x38, 0x44, 0x4E, 0x3A, 0x17, 0x18, 0x2F, 0x30}, 14},
  {0xE1, {0xD0, 0x09, 0x0F, 0x08, 0x07, 0x14, 0x37, 0x44, 0x4D, 0x38, 0x15, 0x16, 0x2C, 0x3E}, 14},
  {0x21, {0}, 0},
  {0x29, {0}, 0},
  {0x2C, {0}, 0},
};

inline void tdeck_lcd_apply_init_table(TFT_eSPI &tft) {
  const size_t count = sizeof(TDECK_LCD_INIT) / sizeof(TDECK_LCD_INIT[0]);
  for (size_t i = 0; i < count; i++) {
    tft.writecommand(TDECK_LCD_INIT[i].cmd);
    for (int j = 0; j < (TDECK_LCD_INIT[i].len & 0x7f); j++) {
      tft.writedata(TDECK_LCD_INIT[i].data[j]);
    }
    if (TDECK_LCD_INIT[i].len & 0x80) {
      delay(120);
    }
  }
}

inline void tdeck_board_power_spi_init() {
  pinMode(TDECK_POWER_ON, OUTPUT);
  digitalWrite(TDECK_POWER_ON, HIGH);
  delay(50);
  pinMode(TDECK_SDCARD_CS, OUTPUT);
  pinMode(TDECK_LORA_CS, OUTPUT);
  pinMode(TDECK_TFT_CS, OUTPUT);
  digitalWrite(TDECK_SDCARD_CS, HIGH);
  digitalWrite(TDECK_LORA_CS, HIGH);
  digitalWrite(TDECK_TFT_CS, HIGH);
  pinMode(TDECK_SPI_MISO, INPUT_PULLUP);
  SPI.begin(TDECK_SPI_SCK, TDECK_SPI_MISO, TDECK_SPI_MOSI);
}

inline void tdeck_display_init(TFT_eSPI &tft, uint8_t rotation) {
  tdeck_board_power_spi_init();
  tft.begin();
  tdeck_lcd_apply_init_table(tft);
  tft.setRotation(rotation);
  tft.fillScreen(TFT_BLACK);
  pinMode(TDECK_TFT_BL, OUTPUT);
  tdeck_backlight_set(16);
}

#endif
#endif

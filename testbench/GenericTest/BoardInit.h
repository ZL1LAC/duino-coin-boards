#ifndef BOARD_INIT_H
#define BOARD_INIT_H

#include <Arduino.h>
#include <SPI.h>
#include "TestConfig.h"

#if defined(DISPLAY_ST7789) || defined(DISPLAY_ST7735) || defined(DISPLAY_GC9A01)
  #include <TFT_eSPI.h>
#endif

#if defined(LILYGO_T_DECK)
  #include "../../ESP_Code/TDeckDisplay.h"
#endif

#if defined(DISPLAY_ST7735)
  #ifndef MINITV_SPI_SCLK
    #define MINITV_SPI_SCLK 3
  #endif
  #ifndef MINITV_SPI_MOSI
    #define MINITV_SPI_MOSI 4
  #endif
#endif

#if defined(DISPLAY_GC9A01)
  #ifndef ROUND_SPI_SCLK
    #define ROUND_SPI_SCLK 6
  #endif
  #ifndef ROUND_SPI_MOSI
    #define ROUND_SPI_MOSI 7
  #endif
  #ifndef ROUND_TFT_BL
    #define ROUND_TFT_BL 3
  #endif
#endif

inline void board_power_init() {
#if defined(LILYGO_T_DECK)
  Serial.println("T-Deck: power + CS (via tdeck_display_init)");
#endif
}

inline void board_spi_init() {
#if defined(LILYGO_T_DECK)
  // handled in tdeck_display_init
#elif defined(DISPLAY_ST7735)
  SPI.begin(MINITV_SPI_SCLK, -1, MINITV_SPI_MOSI, -1);
  Serial.println("Mini TV: SPI 3/4");
#elif defined(DISPLAY_GC9A01)
  SPI.begin(ROUND_SPI_SCLK, -1, ROUND_SPI_MOSI, -1);
  pinMode(ROUND_TFT_BL, OUTPUT);
  digitalWrite(ROUND_TFT_BL, HIGH);
  Serial.println("Round GC9A01: SPI 6/7");
#endif
}

template<typename Tft>
inline void display_init(Tft &tft, uint8_t rotation) {
  board_power_init();
  board_spi_init();

#if defined(LILYGO_T_DECK)
  Serial.println("T-Deck: tft.begin()...");
  tdeck_display_init(tft, rotation);
#elif defined(DISPLAY_ST7735) || defined(DISPLAY_GC9A01)
  tft.init();
#else
  tft.begin();
#endif

#if !defined(LILYGO_T_DECK)
  tft.setRotation(rotation);
  tft.fillScreen(TFT_BLACK);
#endif

  Serial.printf("Display init OK — %dx%d @ rot %u\n", tft.width(), tft.height(), rotation);
}

#endif

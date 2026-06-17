// LilyGO T-Deck Pro — GDEQ031T10 240×320 e-paper (UC8253) via GxEPD2
// Pins from https://github.com/Xinyuan-LilyGO/T-Deck-Pro (HD-V2-250915 / V1.1)
#ifndef TDECK_PRO_DISPLAY_H
#define TDECK_PRO_DISPLAY_H

#include <Arduino.h>
#include <SPI.h>

#ifndef TDECK_PRO_SPI_SCK
  #define TDECK_PRO_SPI_SCK  36
#endif
#ifndef TDECK_PRO_SPI_MOSI
  #define TDECK_PRO_SPI_MOSI 33
#endif
#ifndef TDECK_PRO_SPI_MISO
  #define TDECK_PRO_SPI_MISO 47
#endif
#ifndef TDECK_PRO_EPD_CS
  #define TDECK_PRO_EPD_CS   34
#endif
#ifndef TDECK_PRO_EPD_DC
  #define TDECK_PRO_EPD_DC   35
#endif
#ifndef TDECK_PRO_EPD_BUSY
  #define TDECK_PRO_EPD_BUSY 37
#endif
#ifndef TDECK_PRO_EPD_RST
  #define TDECK_PRO_EPD_RST  16   // V1.1 — use -1 in TestConfig for V1.0 boards
#endif
#ifndef TDECK_PRO_EPD_BL
  #define TDECK_PRO_EPD_BL   45
#endif
#ifndef TDECK_PRO_LORA_CS
  #define TDECK_PRO_LORA_CS  3
#endif
#ifndef TDECK_PRO_LORA_RST
  #define TDECK_PRO_LORA_RST 4
#endif
#ifndef TDECK_PRO_SD_CS
  #define TDECK_PRO_SD_CS    48
#endif
#ifndef TDECK_PRO_GPS_EN
  #define TDECK_PRO_GPS_EN   39
#endif
#ifndef TDECK_PRO_LORA_EN
  #define TDECK_PRO_LORA_EN  46
#endif
#ifndef TDECK_PRO_MODEM_EN
  #define TDECK_PRO_MODEM_EN 41
#endif

#ifndef TDECK_PRO_EPD_MIN_MS
  #define TDECK_PRO_EPD_MIN_MS 3000
#endif

inline void tdeck_pro_cs_all_idle() {
  pinMode(TDECK_PRO_LORA_CS, OUTPUT);
  pinMode(TDECK_PRO_LORA_RST, OUTPUT);
  pinMode(TDECK_PRO_SD_CS, OUTPUT);
  pinMode(TDECK_PRO_EPD_CS, OUTPUT);
  digitalWrite(TDECK_PRO_LORA_CS, HIGH);
  digitalWrite(TDECK_PRO_LORA_RST, HIGH);
  digitalWrite(TDECK_PRO_SD_CS, HIGH);
  digitalWrite(TDECK_PRO_EPD_CS, HIGH);
}

inline void tdeck_pro_board_power_init() {
  pinMode(TDECK_PRO_GPS_EN, OUTPUT);
  digitalWrite(TDECK_PRO_GPS_EN, HIGH);
  pinMode(TDECK_PRO_LORA_EN, OUTPUT);
  digitalWrite(TDECK_PRO_LORA_EN, HIGH);
  pinMode(TDECK_PRO_MODEM_EN, OUTPUT);
  digitalWrite(TDECK_PRO_MODEM_EN, HIGH);
  pinMode(TDECK_PRO_EPD_BL, OUTPUT);
  digitalWrite(TDECK_PRO_EPD_BL, HIGH);
  delay(50);
}

#if defined(DISPLAY_GDEQ031T10)
  #include <GxEPD2_BW.h>

  inline bool tdeck_pro_epd_rate_limit(uint32_t min_ms = TDECK_PRO_EPD_MIN_MS) {
    static uint32_t last_ms = 0;
    uint32_t now = millis();
    if (now - last_ms < min_ms) {
      return false;
    }
    last_ms = now;
    return true;
  }

  template<typename EpdType>
  inline void tdeck_pro_display_init(EpdType &epd, uint8_t rotation) {
    tdeck_pro_board_power_init();
    tdeck_pro_cs_all_idle();
    SPI.begin(TDECK_PRO_SPI_SCK, TDECK_PRO_SPI_MISO, TDECK_PRO_SPI_MOSI);
    epd.epd2.selectSPI(SPI, SPISettings(2000000, MSBFIRST, SPI_MODE0));
    epd.init(115200, true, 2, false);
    epd.setRotation(rotation);
    epd.setFullWindow();
    epd.fillScreen(GxEPD_WHITE);
    epd.display(false);
  }

  template<typename EpdType>
  inline void tdeck_pro_epd_flush_full(EpdType &epd) {
    tdeck_pro_cs_all_idle();
    epd.setFullWindow();
    epd.display(false);
  }

  template<typename EpdType>
  inline void tdeck_pro_epd_flush_fast(EpdType &epd) {
    tdeck_pro_cs_all_idle();
    epd.setFullWindow();
    if (epd.epd2.hasFastPartialUpdate) {
      epd.display(true);
    } else if (epd.epd2.hasPartialUpdate) {
      epd.display(true);
    } else {
      epd.display(false);
    }
  }

  // Mining UI: throttle + periodic full refresh to avoid partial-update busy timeouts
  template<typename EpdType>
  inline void tdeck_pro_epd_flush_mining(EpdType &epd) {
    static uint16_t partial_count = 0;
    tdeck_pro_cs_all_idle();
    epd.setFullWindow();
    partial_count++;
    if (partial_count >= 15) {
      partial_count = 0;
      epd.display(false);
    } else {
      epd.display(true);
    }
  }
#endif

#endif

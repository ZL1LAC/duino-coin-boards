// TFT_eSPI User_Setup for LilyGO T-Deck (ESP32-S3, ST7789 240×320)
// Based on LilyGO Setup210 — https://github.com/Xinyuan-LilyGO/T-Deck
// Pin map: https://wiki.lilygo.cc/products/t-deck-series/t-deck/
//
// IMPORTANT: Do NOT define TFT_BL here — T-Deck backlight uses a special
// 16-level driver; GenericTest/BoardInit.h handles GPIO 42 after tft.begin().

#define USER_SETUP_ID 210
#define USER_SETUP_INFO "LilyGO_T_Deck"

#define ST7789_DRIVER

#define TFT_WIDTH  240
#define TFT_HEIGHT 320

#define TFT_RGB_ORDER TFT_RGB
#define INIT_SEQUENCE_2

#define TFT_MISO 38
#define TFT_MOSI 41
#define TFT_SCLK 40
#define TFT_CS   12
#define TFT_DC   11
#define TFT_RST  -1
// #define TFT_BL 42  // leave off — see BoardInit.h tdeck_backlight_set()

// ESP32-S3 + Arduino esp32 core 3.x: FSPI register base is broken in stock TFT_eSPI
// (StoreProhibited EXCVADDR 0x10 in tft.begin). See Bodmer/TFT_eSPI#3329 #3743.
#define USE_HSPI_PORT

#define TFT_BACKLIGHT_ON HIGH

#define LOAD_GLCD
#define LOAD_FONT2
#define LOAD_FONT4

#define SPI_FREQUENCY       40000000
#define SPI_READ_FREQUENCY  20000000
#define SPI_TOUCH_FREQUENCY  2500000

#ifndef USER_SETUP_LOADED
#define USER_SETUP_LOADED
#endif

// Copy to Arduino/libraries/TFT_eSPI/User_Setup.h
// Source of truth: boards/esp32c3-round128/GC9A01_setup.h

#define USER_SETUP_ID 301
#define USER_SETUP_INFO "ESP32_2424S012_GC9A01"

#define GC9A01_DRIVER

#define TFT_WIDTH  240
#define TFT_HEIGHT 240

#define TFT_MOSI 7
#define TFT_SCLK 6
#define TFT_CS   10
#define TFT_DC   2
#define TFT_RST  -1
#define TFT_BL   3
#define TFT_MISO -1

#define TFT_BACKLIGHT_ON HIGH

#define TFT_RGB_ORDER TFT_BGR

#define LOAD_GLCD
#define LOAD_FONT2
#define LOAD_FONT4
#define LOAD_FONT6
#define LOAD_FONT7
#define LOAD_FONT8
#define LOAD_GFXFF
#define SMOOTH_FONT

#define SPI_FREQUENCY       40000000
#define SPI_READ_FREQUENCY  20000000

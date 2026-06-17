// TFT_eSPI User_Setup template — copy to Arduino/libraries/TFT_eSPI/User_Setup.h
// Rename this file for your board (e.g. ST7789_setup.h) and fill in pins + driver.

#define USER_SETUP_ID 399
#define USER_SETUP_INFO "YOUR_BOARD_ID"

// Pick ONE driver:
// #define ST7735_DRIVER
// #define ST7789_DRIVER
// #define GC9A01_DRIVER
// #define ILI9341_DRIVER

#define TFT_WIDTH  240
#define TFT_HEIGHT 240

// SPI (adjust GPIOs for your board)
#define TFT_MOSI 7
#define TFT_SCLK 6
#define TFT_CS   10
#define TFT_DC   2
#define TFT_RST  -1
#define TFT_BL   3
#define TFT_MISO -1

#define TFT_BACKLIGHT_ON HIGH

#define LOAD_GLCD
#define LOAD_FONT2
#define LOAD_FONT4

#define SPI_FREQUENCY 27000000

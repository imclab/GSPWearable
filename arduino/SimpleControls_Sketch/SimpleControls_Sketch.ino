#include <SPI.h>
#include <ble.h>
 
#define DIGITAL_OUT_RED     3
#define DIGITAL_OUT_GREEN   4
#define DIGITAL_OUT_BLUE    5

void setup() {
    SPI.setDataMode(SPI_MODE0);
    SPI.setBitOrder(LSBFIRST);
    SPI.setClockDivider(SPI_CLOCK_DIV16);
    SPI.begin();

    ble_begin();
  
    pinMode(DIGITAL_OUT_RED, OUTPUT);
    pinMode(DIGITAL_OUT_GREEN, OUTPUT);
    pinMode(DIGITAL_OUT_BLUE, OUTPUT);
}

void loop() {  
    // If data is ready
    while(ble_available()) {
        // read out command and data
        byte on = ble_read();
        byte red = ble_read();
        byte green = ble_read();
        byte blue = ble_read();
    
        // Command is to control digital out pin
        if (on == 0x01) {
            digitalWrite(DIGITAL_OUT_RED, LOW);
            digitalWrite(DIGITAL_OUT_GREEN, LOW);
            digitalWrite(DIGITAL_OUT_BLUE, LOW);
            if (red == 0x01) {
                digitalWrite(DIGITAL_OUT_RED, HIGH);
            } else if( green == 0x01 ) {
                digitalWrite(DIGITAL_OUT_GREEN, HIGH);
            } else if( blue == 0x01 ) {
                digitalWrite(DIGITAL_OUT_BLUE, HIGH);
            }
        } else {
            digitalWrite(DIGITAL_OUT_RED, LOW);
            digitalWrite(DIGITAL_OUT_GREEN, LOW);
            digitalWrite(DIGITAL_OUT_BLUE, LOW);
        }
    }
  
    if (!ble_connected()) {
        digitalWrite(DIGITAL_OUT_RED, LOW);
    }
  
    // Allow BLE Shield to send/receive data
    ble_do_events();  
}
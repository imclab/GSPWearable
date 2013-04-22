
#include <ble.h>
 
#define DIGITAL_OUT_RING     6

void setup() {
//    SPI.setDataMode(SPI_MODE0);
//    SPI.setBitOrder(LSBFIRST);
//    SPI.setClockDivider(SPI_CLOCK_DIV16);
//    SPI.begin();

    ble_begin();
  
    pinMode(DIGITAL_OUT_RING, OUTPUT);
}

void loop() {  
    // If data is ready
    while(ble_available()) {
        // read out command and data
        byte on = ble_read();
    
        // Command is to control digital out pin
        if (on == 0x01) {
            digitalWrite(DIGITAL_OUT_RING, HIGH);
            delay(150);
            digitalWrite(DIGITAL_OUT_RING, LOW);
        }
    }
  
    if (!ble_connected()) {
        digitalWrite(DIGITAL_OUT_RING, LOW);
    }
  
    // Allow BLE Shield to send/receive data
    ble_do_events();  
}

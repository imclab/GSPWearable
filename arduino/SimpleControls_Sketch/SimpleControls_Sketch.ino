#define DIGITAL_OUT_RED     3
#define DIGITAL_OUT_GREEN   4
#define DIGITAL_OUT_BLUE    5

void setup() {
    Serial.begin( 57600 );
  
    pinMode(DIGITAL_OUT_RED, OUTPUT);
    pinMode(DIGITAL_OUT_GREEN, OUTPUT);
    pinMode(DIGITAL_OUT_BLUE, OUTPUT);
}

void loop() {
    while ( Serial.available() ) {
        delay(10);
       
        byte on = Serial.read();
        byte red = Serial.read();
        byte green = Serial.read();
        byte blue = Serial.read();
    
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

        Serial.flush();
    }
}

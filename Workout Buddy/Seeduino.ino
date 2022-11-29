#include <LSM6DS3.h>
#include "Wire.h"
 
//Create an instance of class LSM6DS3
LSM6DS3 myIMU(I2C_MODE, 0x6A);    //I2C device address 0x6A
double position = 0;
double velocity = 0;
void setup() {
    // put your setup code here, to run once:
    Serial.begin(9600);
    while (!Serial);
    //Call .begin() to configure the IMUs
    if (myIMU.begin() != 0) {
        Serial.println("Device error");
    } else {
        Serial.println("Device OK!");
    }
}
 
void loop() {
    //Accelerometer
    Serial.print("\nAccelerometer:\n");
    double x = 10*myIMU.readFloatAccelX();
    double y = 10*myIMU.readFloatAccelY();
    double z = 10*myIMU.readFloatAccelZ();
    double magnitude = sqrt(x * x + y * y + z * z) - 10.3;
    Serial.println(magnitude);    
    double deltaV = int(magnitude * 20) / 20 * 0.5; 
    velocity += deltaV;
    position += int(velocity * 20) / 20 * 0.5;
    Serial.println(deltaV);    
    Serial.println(velocity);   
    delay(100);
}

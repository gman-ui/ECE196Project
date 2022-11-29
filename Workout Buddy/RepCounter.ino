//Main Sources are: "DIY Arduino Pedometer - Counting Steps using Arduino and Accelerometer" and "Send/Receive Data to Mobile App with XIAO BLE nRF52840 Sense"
#include <ArduinoBLE.h>
#include "LSM6DS3.h"
#include "Wire.h"

BLEService RepService("180F"); //Service Address
BLEUnsignedCharCharacteristic RepCountChar("2A19", BLERead | BLENotify); //Characteristic for Rep Counter, we write to this value
LSM6DS3 myIMU(I2C_MODE, 0x6A); //initialize IMU

double sensitivity = 3; //modify this value to adjust sensitivity
int reps, flag = 0;

void setup() {
    Serial.begin(9600);
    while (!Serial);
    if (myIMU.begin() != 0) {
        Serial.println("Device error");
    } 
    else {
        Serial.println("Device OK!");
    }
    
    BLE.setLocalName("RepCounter");
    BLE.setAdvertisedService(RepService);
    RepService.addCharacteristic(RepCountChar);//this is where you would add multiple characteristics if you desired
    
    //using the logic above, we could create other characteristics for the acceleration and jerk, such that we perform statistical analyis by way of rep quality
    //BUT due to budget cuts, this feature may not make it
    
    BLE.addService(RepService); //add the service after characteristics are added
    RepCountChar.writeValue(reps); //write the initial value of reps to our counter
    
    BLE.advertise();
    Serial.println("Bluetooth® device active, waiting for connections...");
}

void loop() {
    double acceleration[100] = {0}; //acceleration, stores the magnitudes of acceleration
    double jerk[100] = {0}; //uses the instantaneous change in acceleration to figure out jerk
    double xaccl[100] = {0}; //x acceleration
    double yaccl[100] = {0}; //y acceleration
    double zaccl[100] = {0}; //z acceleration

    for (int i = 0; i < 100; i++){
      xaccl[i] = 10*myIMU.readFloatAccelX(); //get input from IMU
      yaccl[i] = 10*myIMU.readFloatAccelY();
      zaccl[i] = 10*myIMU.readFloatAccelZ();
      acceleration[i] = sqrt((xaccl[i] * xaccl[i]) + (yaccl[i] * yaccl[i] ) + (zval[i] * zval[i])) - 10.3; //magnitude of the acceleration at any given time, might want to MODIFY 10.3 value
      jerk[i] = (acceleration[i] + acceleration[i - 1]) / 2 ; //jerk calculation, might go over the bounds of the 100 unit array but no issues so far :)
      Serial.println("Jerk: ");
      Serial.println(jerk[i]);
      Serial.println('\n');
      Serial.print("Reps: ");
      delay(100); //modify this to change rep counter displaying frequency
      
      if (jerk[i] > sensitivity && flag == 0){ //if jerk is greater than sensitivity and a rep has not been flagged, increase reps
          reps = reps + 1;
          flag = 1;
      }
      if (jerk[i] < sensitivity && flag == 1){ //if jerk is less than sensitivity and a rep has been flagged already, rep is at rest and we start looking for reps again
          flag = 0;
      }

      Serial.println(reps); //write the value of reps
      RepCountChar.writeValue(reps);
      
      delay(100); //modify this to change sampling frequency
    }
    delay(1000); //must keep
}

#include <ArduinoBLE.h>
#include <LSM6DS3.h>
#include "Wire.h"

//Create an instance of class LSM6DS3
LSM6DS3 myIMU(I2C_MODE, 0x6A);    //I2C device address 0x6A
 
BLEService service("19B10000-E8F2-537E-4F6C-D104768A1214"); // Bluetooth® Low Energy LED Service
 
// Bluetooth® Low Energy LED Switch Characteristic - custom 128-bit UUID, read and writable by central
BLEByteCharacteristic switchCharacteristic("19B10001-E8F2-537E-4F6C-D104768A1214", BLERead | BLEWrite);
BLEByteCharacteristic sending_value("19B10001-E8F2-537E-4F6C-D104768A1212", BLERead | BLEWrite);
BLEByteCharacteristic quality_value("19B10001-E8F2-537E-4F6C-D104768A1213", BLERead | BLEWrite);
 
const int ledPin = LED_BUILTIN; // pin to use for the LED

int count = 0;
boolean moving = true;
int previous = 0;
int goal = 10;
double v = 0.0;

const int start = 2;
int recordState = false;
int ledState = LOW;

int patience = 0;
int hold = 0;

int wristMode = true;

int pacing = 0;
int totalPacing = 0;

void setup() {
  Serial.begin(9600);
  
  //Call .begin() to configure the IMUs
  if (myIMU.begin() != 0) {
      Serial.println("Device error");
  } else {
      Serial.println("Device OK!");
  }
  
  // set LED pin to output mode
  pinMode(ledPin, OUTPUT);
 
  // begin initialization
  if (!BLE.begin()) {
    Serial.println("starting Bluetooth® Low Energy module failed!");
 
    while (1);
  }
 
  // set advertised local name and service UUID:
  BLE.setLocalName("LED");
  BLE.setAdvertisedService(service);
 
  // add the characteristic to the service
  service.addCharacteristic(switchCharacteristic);
  // add the characteristic to the service
  service.addCharacteristic(sending_value);
  service.addCharacteristic(quality_value);

  // add service
  BLE.addService(service);
 
  // set the initial value for the characeristic:
  switchCharacteristic.writeValue(0);
  // set the initial value for the characeristic:
  sending_value.writeValue(0);
  quality_value.writeValue(0);
 
  // start advertising
  BLE.advertise();
 
  Serial.println("BLE LED Peripheral");

  pinMode(1, OUTPUT);
  pinMode(2, INPUT);
  pinMode(3, OUTPUT);
}


void loop() {
  // listen for Bluetooth® Low Energy peripherals to connect:
  BLEDevice central = BLE.central();
 
  // if a central is connected to peripheral:
  if (central) {
    Serial.print("Connected to central: ");
    // print the central's MAC address:
    Serial.println(central.address());
 
    // while the central is still connected to peripheral:
  // central.connected()
  while (central.connected()) {  
//    if (switchCharacteristic.written()) {
//      if (switchCharacteristic.value()) {   
//        Serial.println("hi");
//      } else {                              
//        Serial.println(F("LED off"));
//        Serial.print("not sending");
//      }
//    }
    
  int buttonState = analogRead(start);
  if (buttonState == 0) {
    patience++;
  } else {
    patience = 0;
    hold = 0;
  }
  if ((!recordState && patience == 10) || (recordState && patience == 8)){
    hold++;
    patience = 0;
  }
  if (hold == 7){
    sending_value.writeValue(count/2);
    Serial.println((pacing-50)*100/(50*count));
    quality_value.writeValue((totalPacing-50)*100/(50*count));
    Serial.println(count/2);
    
    hold = 0;
    recordState = ~recordState;
    ledState = (ledState == LOW)? HIGH: LOW;
    digitalWrite(1, ledState);
  }
    
  if (recordState){
    int reps = count/2;
    Serial.println(count);
    if (pacing <= 50){
      pacing++;
      digitalWrite(3, HIGH);
    }
    else{
      digitalWrite(3, LOW);
    }
    float ax;
    float az;

    ax = myIMU.readFloatAccelX();
    ay = myIMU.readFloatAccelY();
    az = myIMU.readFloatAccelZ();
    a = sqrt(ax*ax + ay*ay + az*az) - 1;
    if (moving == true) //previously moved
    {
      if ((switchCharacteristic.value() == 1 && stopped(a))  || (switchCharacteristic.value() == 0 && stopped(az))) //now stopped
      {
        previous++;
        if (previous >=15 )
        {
          count++;
          totalPacing += pacing;
          pacing = 0;
          previous = 0;
          moving = false;
        }
      }
      else //still moving
      {
        previous++;
      }
    }
    
    if (moving == false) //previously stopped
    {
      if ((switchCharacteristic.value() == 1 && !stopped(a))  || (switchCharacteristic.value() == 0 && !stopped(az))) //now moving
      {
        previous++;
        if (previous >=15)
        {
          previous = 0;
          moving = true;
        }
      }
      else //still stopped
      {
        previous++;
      }
    }
   }
   else{
     count = 0;
   }
   delay(40);
  }
    
    // when the central disconnects, print it out:
    Serial.print(F("Disconnected from central: "));
    Serial.println(central.address());
  }
  
  
}

bool stopped(float a)//If acceleration is low, assume it 0 (sensor fluctuations)
{
  return abs(a) < 0.21;
}

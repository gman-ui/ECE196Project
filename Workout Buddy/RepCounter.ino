#include "LSM6DS3.h"
#include "Wire.h"

//Create an instance of class LSM6DS3
LSM6DS3 myIMU(I2C_MODE, 0x6A);    //I2C device address 0x6A

//Based off "DIY Arduino Pedometer - Counting Steps using Arduino and Accelerometer"

float threshold = 0.9; //edit
//Resting threshold is .66
float xval[100] = {0};
float yval[100] = {0};
float zval[100] = {0};
float xavg, yavg, zavg;
int steps, flag = 0;

void setup() {
    // put your setup code here, to run once:
    Serial.begin(9600);
    while (!Serial);
    //Call .begin() to configure the IMUs
    if (myIMU.begin() != 0) {
        Serial.println("Device error");
    } 
    else {
        Serial.println("Device OK!");
    }
}
 
void loop() {
    int acc = 0;
    float totvect[100] = {0};
    float totave[100] = {0};
    float xaccl[100] = {0};
    float yaccl[100] = {0};
    float zaccl[100] = {0};
    for (int a = 0; a < 100; a++){
      xaccl[a] = float(myIMU.readFloatAccelX()); //- 345);
      yaccl[a] = float(myIMU.readFloatAccelY()); //- 346);
      zaccl[a] = float(myIMU.readFloatAccelZ()); //- 416);
      totvect[a] = sqrt(((xaccl[a] - xavg) * (xaccl[a] - xavg)) + ((yaccl[a] - yavg) * (yaccl[a] - yavg)) + ((zval[a] - zavg) * (zval[a] - zavg)));
      totave[a] = (totvect[a] + totvect[a - 1]) / 2 ;
      Serial.println("Acceleration");
      Serial.println(totave[a]);
      delay(100);
      if (totave[a] > threshold ){//&& flag == 0){
          steps = steps + 1;
          flag = 1;
      }
      if (totave[a] < threshold && flag == 1){
        flag = 0;
      }
      if (steps < 0) {
        steps = 0;
      }
      Serial.println('\n');
      Serial.print("Reps: ");
      Serial.println(steps);
      delay(100); //edit
    }
    delay(1000);
}

void calibrate(){
  float sum = 0;
  float sum1 = 0;
  float sum2 = 0;
  for (int i = 0; i < 100; i++) {
    xval[i] = float(myIMU.readFloatAccelX() - 345);
    sum = xval[i] + sum;
  }
  delay(100);
  xavg = sum / 100.0;
  Serial.println(xavg);
  for (int j = 0; j < 100; j++)
  {
    yval[j] = float(myIMU.readFloatAccelY() - 346);
    sum1 = yval[j] + sum1;
  }
  yavg = sum1 / 100.0;
  Serial.println(yavg);
  delay(100);
  for (int q = 0; q < 100; q++)
  {
    zval[q] = float(myIMU.readFloatAccelZ() - 416);
    sum2 = zval[q] + sum2;
  }
  zavg = sum2 / 100.0;
  delay(100);
  Serial.println(zavg);
}

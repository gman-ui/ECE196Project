## Welcome!

This is our webpage for our ECE 196 Project - Workout Buddy!
UC San Diego - Jacobs School of Engineering
Electrical and Computering Engineering
Department of Athletics


### Problem Statement: 
Making “gains” in the gym is hard, especially when working out alone. Through loud music and intense exercises, we want to optimize workouts by tracking the quantity and quality of repetitions.

### [Meet the Team](website/AboutTeam.md)

### Solution:
We are developing a cheap wearable device that tracks repetitions.

### Design Flow:

<p align="center">
<img src="website/site_resources/FlowChart.png" width="600" height="480"/>
</p>

### Components Used:
<p align="center">
PCB Design(Left), CAD Model + PCB (Middle), Seeed nRF52480 Sense (Right)
</p>
 
<p align="center">
<img src="website/site_resources/PCB_Design.png" width="200" height="200"/>
<img src= "website/site_resources/CAD.png" width="200" height="200"/>
<img src= "website/site_resources/SEEED.jpg" width="250" height="200"/>
</p>

### Design of Physical Device: 
Using a Seeed nRF52840, we were able to create a compact bluetooth system to measure repetitions via embedded acceleration calculations.

### Software Application: 
Using SwiftUI, we created an iOS app that provides monitoring of the user’s repetitions based on data sent by the device and provides positive or negative comments based on the user’s preference. 

### Behind the Arduino
How exactly does the IMU track repetitions? 
The IMU can track acceleration in three direction, and we can unify these three quantities into another quantity known as the magnitude.
If we square each of the x, y, and z, accelerations, we can get the total acceleration in a certain direction. 
One important note is the there will always be a magnitude of 1 present due to the normalized force of gravity calculated by the accelerometer. 
Since we are dealing with low acceleration states, we can subtract 1 from the total magnitude and make calculations with minimal error. 
The meat of the code lies in the "ticks" of the repetition. 
There are four points where acceleration will be 0, the bottom of the rep, the middle of the concentric motion, the top of the concentric motion, and the middle of the eccentric motion. This is because we are encouraging paused repetitions which increases muscle usage. 
The conditionals uses these checkpoints and keeps count whether it is at the top or bottom of the rep. Then divides this value by two to track the number of reps. 

### Updates:
#### [11/16 Progress Report](website/11_16_Progress_Report.md)

### Final Product:
<p align="center">
<img src="website/site_resources/FinalProduct.png" width="400" height="400"/>
 </p>
<p align="center">
 <img src="website/site_resources/WorkoutBuddyPicOne.png" width="325" height="650"/>
 <img src="website/site_resources/WorkoutBuddyPicTwo.png" width="325" height="650"/>
</p>

### [Final Presentation](https://docs.google.com/presentation/d/1JhQONRMlsEj1D5vUSwP1L23lphcnRkILb456B_p8MZ8/edit#slide=id.p)

### [Video Demonstration](https://drive.google.com/file/d/1s5_zrb8chxxecz5kb8jw5V9imzpqXm9z/view?usp=sharing)

### Going Forward:
Overall, we are satisfied with how our project turned out, given the time constraint. If we had more than 5 weeks, we would want to:
  * Improve rep counting algorithm
  * Reduce cost and size further
  * Outsource less components
  * Integrate OLED display
  * Monitor other elements while minimizing cost and size

### [Resources](website/resources.md)


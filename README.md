# Description of this work

## 1、Our Teams

We are We are currently students of XX College of XX (deleted due to contest requirements), a Chinese university, and our team is participating in the 2022 National Student Embedded Chip and System Design Competition FPGA Innovation Design Competition. The team members are: (deleted due to contest requirements) Team name is: (deleted due to contest requirements)

## 2、Introduction of this work

This is our project for the FPGA Innovation Design Competition of the National Student Embedded Chip and System Design Competition 2022, which is dedicated to solving the problem of difficult energy supply in IoT deployment. This work is actually a multi-energy self-powered device for collecting information about the node environment and transmitting the data with the domestic symmetric encryption algorithm SM4. This work uses various power supply methods such as solar energy and wireless energy to charge the node's capacitor, and the node chip can detect the remaining power of the capacitor in real time to change the encryption mode. The encryption mode is divided into three levels, with power consumption from high to low and encryption efficiency correspondingly from high to low. This work is based on the SparkRoad-V development board with the EG4S20BG256 core from Shanghai Anlu Technology.

## 3、Visualization interface

Link：https://cyberspacesecurity1.github.io/web/web/index.html

## 4、How to run this project

Firstly you need to download our source code project file, secondly you need to download TD platform from Anlu, import the project file of this work into TD platform, compile and run it, then burn the generated bit stream into sparkroad.

Open the serial debugging assistant, detect the serial port of the development board, enter the key information and the plaintext to be encrypted, after the processing and calculation of the development board, the ciphertext will be displayed back to the window of the serial debugging assistant.

## 5、Application Scenarios

This paper provides low-power IoT node design techniques for intermittent computing, which are currently focused on solving the problem of self-powered devices that operate for long periods of time, at low power consumption, and intermittently. Battery is the biggest threat to sustainable IoT or traditional computing. While it can provide continuous power to keep a device running uninterrupted, it will limit the lifetime of the device if it is not regularly maintained or replaced. On the one hand, it is impractical to pin hopes on improvements in battery technology; on the other hand, it is not possible to power a large distributed IoT system through a power supply such as an outlet. By adding intermittent computing technology, it is possible to initially realize the function of data collection as well as data transmission by saving intermediate result data before power failure in outdoor or even unmanned area scenarios where the deployed movable devices cannot get timely energy supply.

Take the wildlife tracking problem as an example: animal researchers put on a special video collar for wild animals, and the camera collects image information and then passes through the encrypted computing module of the device to transmit the data that needs to be kept confidential back to the research base safely. During operation, even if the device is short of energy supply, it can continue to perform through intermittent computing technology until the energy supply is restored. The device uses a variety of ways to harvest energy from the environment, so no matter how covert the behavior of the animal being tracked and how harsh the environment, it is not limited by time, place, or climate. Data security is also protected while enabling sustainable work.

With the progress of society and the continuous development of IoT technology, IoT has now entered all aspects of society. During the operation of an energy harvesting system, it is susceptible to frequent power outages due to various factors such as environmental changes and power usage. The use of batteries, capacitors and other power storage devices can alleviate this problem but cannot fundamentally eliminate the impact of intermittent power supply. Once the power storage is on the verge of depletion, and the capacity collection is not enough to maintain the power supply, the device will face intermittent power supply situation. If nothing is done about the power outage, once the system runs out of power, all the intermediate run results stored in volatile memory are lost and everything has to start from scratch. However, when power is restored, the device may still lose power again before it has finished running all its calculations. The cycle repeats itself, and the device never gets the target result data. For a huge number of end devices, traditional, battery-powered devices, which require frequent charging or frequent battery replacement, are difficult to apply in IoT systems that accommodate a huge number of end devices.

Therefore, more and more end devices are designed as self-powered devices, i.e., they obtain energy from the external environment (including solar energy, wind energy, and RF energy, etc.) to sustain their operation. This work is based on self-powered devices using FPGAs to implement low-energy IoT node design. The work can use wind energy, light energy, wireless charging, etc. to provide energy for encrypted computing, and can switch the main energy supply method in different situations. When the energy supply is insufficient or the power is suddenly cut off, it can effectively save the current state and wait for the next start-up to restore the then state and continue working without repeating the completed work. Intermittent computing may change the way these devices are powered, and thus fundamentally change their operation.


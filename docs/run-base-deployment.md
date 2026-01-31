# Programming and Running the BaseDeployment Application on Hardware
The goal is to be able to establish a connection bewteen a microcontroller and fprime-gds. From there, you will be able to enable/disable the LED blinking as well as adjusting the blinking interval. This base deployment utilizes minimal F' components and an LED blinker component.

## BEFORE PROCEEDING TO THE NEXT STEPS
Unless you're on a Teensy4.1, make sure to change the `default_toolchain:` flag in `settings.ini` to reflect the toolchain `.cmake` file that corresponds to your platform. If it does't already exist in `fprime-arduino`, you may need to manually make/add your own toolchain to your local copy of this reference deployment.

Make sure to run `fprime-util generate -f` (or `fprime-util generate -f --make` if weird errors occur) and `fprime-util build`. 


## Uploading hex file for the Teensy
The Teensyduino application should have appeared after running `fprime-util build`. Choose the hex file to load into Teensyduino located in `./build-artifacts/ReferenceDeployment/bin/`. Manually press the reset button on the Teensy to upload the program.

## Uploading binary file for the Feather M0
Double press on the reset button on the Feather to set it to programming mode. Then run the following commands below.

## Uploading hex file for the STM32
After building, find the hex file that should appear in `./build-artifacts/ReferenceDeployment/bin`. Flash the hex file onto your STM32 board using STM32CubeProgrammer.

Note: STM32CubeProgrammer does not support Linux running on an ARM CPU.

```sh
~/.arduino15/packages/adafruit/tools/bossac/1.8.0-48-gb176eee/bossac -i -d --port=ttyACM0 -U -i --offset=0x2000 -w -v ./build-artifacts/featherM0/ReferenceDeployment/bin/ReferenceDeployment.bin -R
```
Note:
  - If you have more than one device connected, or if you are using a different OS, `ttyACM0` may differ for your system.

## Using GDS over serial
```sh
fprime-gds -n --dictionary ./build-artifacts/YOUR_DEVICE/ReferenceDeployment/dict/ReferenceDeploymentTopologyAppDictionary.json --communication-selection uart --uart-device /dev/ttyACM0 --uart-baud 115200
```

Note: 
  - If F' GDS seems to not be able to communicate with the deployment on your platform despite visually confirming F' is running due to the execution of the blinking LED code in this reference, ensure that the frame plugin that F' GDS and your platform are using are consistent. You might want to look into appending the flag `--framing-selection: ARGUMENT` to the aforementioned fprime-gds command. For more information about the arguments that are associated with `--framing-selection: ARGUMENT`, run `fprime-gds -h`.

More Notes:
  - If you have more than one device connected, or if you are using a different OS, `/dev/ttyACM0` may differ for your system.
  - Change `YOUR_DEVICE` to the respective device. (i.e. `teensy41`, `featherM0`)

### Next Step: [Building and Running the Baremetal Reference on Hardware](./run-baremetal-reference.md)

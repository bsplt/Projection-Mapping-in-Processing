# Projection Mapping in Processing

This code was part of an installation for a short exhibition in which I was featured. It is the working prototype of a projection mapping software, written in and executed via the [Processing IDE](https://www.processing.org/). The visual effects can be programmed in a linear timeline. The software also implents a feature to ineract with an [Arduino](https://www.arduino.cc/). I put it here as a documentation for myself as well as for a couple of other people who were interested in the code. The program might not be the ideal approach to the subject but an interesting solution that crystallized under high time pressure.

## Documentation

[![Documentation of projection mapping in Processing](http://img.youtube.com/vi/atJcAT2Y294/maxresdefault.jpg)](https://www.youtube.com/watch?v=atJcAT2Y294)

I wrote this code for an artistic practice. [Check out the documentation video](https://www.youtube.com/watch?v=atJcAT2Y294).

## Getting Started

The sketch is pretty much ready to start. There is an option to trigger a relay with an [Arduino](https://www.arduino.cc/) over [Firmata](https://www.arduino.cc/en/Reference/Firmata), you can turn it on in the `projection_arduino` tab, you'll see. But it it default off, so it doesn't interfere with if there is no Arduino connected.

Most important is the timeline. It is located in the `data` folder as `timeline.csv`. It works like this:

| Start in ms | End in ms | Projection Area | Effect Name   |
| ----------- | --------- | --------------- | ------------- |
| 63980       | 64200     | 2               | "FFTFillFast" |
| 64100       | 67500     | 1               | "Outline"     |
| 66560       | 66810     | 0               | "LineVertUp"  |

Included are the following effects:
* LineVertDown
* LineVertUp 
* LineHoriLeft 
* LineHoriRight 
* Fill 
* FadeOut
* FadeIn 
* Outline 
* StripesHori 
* StripesVert 
* RandomHori 
* RandomVert 
* FFTFillSlow 
* FFTFillFast 
* BlueScreen 

Additional effects:
* Restart (Resets the timeline to 0)
* ArduinoButton (Waits for a button push on the Arduino to continue the loop)
* ArduinoSwitch (Turning on a relay)

My advice is if you're interested in my project: Please read the code yourself or contact me directly. Most of the stuff should explain itself and/or is commented.

## Running

Most important to projection mapping is to map the projection to the wall. :tada: I made a configuration mode that is accessible with the key `c`. It let's you drag the mapped areas around with your mouse. Once `c` is pressed again, it will be saved to a file called `planes.csv` in the `data` folder. 

There is a `mapping_sound.wav` in the `data` folder. It will be played with the [minim library](http://code.compartmental.net/tools/minim/) for Processing.

In the installation set up I used a button that you can see in the video to re-start the loop. I works with the `ArduinoButton` effect.

So if this is given it will run smoothly once you press play in the Processing IDE.

## Further information

Please feel free to contact me if you have questions or suggestions.

License is according to the software used.
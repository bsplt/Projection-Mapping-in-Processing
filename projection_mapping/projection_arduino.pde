/* if this is false, the software doesn't even search for an Arduino
 though the class have to be implemented for the compiler */
Boolean useArduino = false;

import processing.serial.*;
import cc.arduino.*;
Arduino arduino;

void arduinoSetup() {
  if (useArduino) {
    println("Potential Arduinos:" + Arduino.list());
    arduino = new Arduino(this, Arduino.list()[1], 57600);
    arduino.pinMode(12, Arduino.OUTPUT);
    arduino.pinMode(6, Arduino.INPUT);
    println("Arduino: " + arduino.digitalRead(6));
  }
}

class ArduinoSwitch extends Effect {
  // I used this to turn on and off strobes for the duration of the effect
  ArduinoSwitch(float start, float end, PGraphics target) {
    super(start, end, target);
    if (useArduino) {
      arduino.digitalWrite(12, Arduino.HIGH);
    }
  }

  float transition() {
    float trans = ((millis() - start) / (end - start));
    if (useArduino && (trans > 1)) {
      arduino.digitalWrite(12, Arduino.LOW);
    }
    return trans;
  }
}

class ArduinoButton extends Effect {
  // This effect waits for a button to be pushed and then restarts the loop
  ArduinoButton(float start, float end, PGraphics target) {
    super(start, end, target);
    if (useArduino) {
      println("Arduino: " + arduino.digitalRead(6));
      while (arduino.digitalRead(6) == Arduino.LOW) {
        delay(50);
        println("Arduino: " + arduino.digitalRead(6));
      };
      triggerInit = true;
    }
  }
}
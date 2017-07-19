/* Design and written by Alexander Lehmann
 Follow me at Twitter: @vonbieberstein */

/* This software renders virtual displays and distorts them for projection mapping.
 It's designed to work with one projector.
 In the field of projection you can drag around quadrangular displays (named planes here) to distort on the projection target.
 The count of planes depends on the coordinates rows in the "planes.csv".
 There are several graphical effects that can be displayed on the planes.
 Each effect is an extension of the Effect superclass.
 You can create an animation loop with the "timeline.csv" in which you set up the effects.
 To enter config mode press "c" on your keyboard. */


ArrayList<Plane> planes;

import ddf.minim.*;
import ddf.minim.analysis.*;
Minim minim;
AudioPlayer audioPlayer;

// timeOffset is necessary for restarting the sketch since you can't reset millis() 
float timeOffset;

// config mode let's you drag around the procetion planes, you can also switch the mode with "c"
Boolean configMode = false;

// when triggerInit is set "true" the loop restarts
Boolean triggerInit;

// --------------------------------

void setup() {
  size(1600, 800, P3D);
  smooth(4);
  noCursor();
  init();
  arduinoSetup();
  // Test pattern for conifguartion:
  img = loadImage("pattern.png");
}

void init() {
  /* for restarting the sketch –
   everything in here needs to be reset for each cycle of the loop */

  // basically init() is called when triggerInit is set true, so it has to be set false again
  triggerInit = false;

  // playing the sound and setting the offset should hapen quite at the same time
  minim = new Minim(this);
  audioPlayer = minim.loadFile("mapping_sound.wav");
  audioPlayer.play();

  /* timeOffset is the time added to the events in the timeline
   which is handy when you want to restart the loop without restarting the sketch */
  timeOffset = millis();

  planes = new ArrayList<Plane>();
  // get the coordinates in the plane objects:
  loadQuadsCSV();
  graphicsSetup(planesCSV.getRowCount());
}

// --------------------------------

void draw() {
  if (frameCount % 120 == 0) {
    println(frameRate);
  }

  background(0);

  if (configMode) {
    configDrawing();
  } else {
    showDrawing();
  }

  input();

  // triggerInit is set "true" be the "restart" effect
  if (triggerInit) {
    init();
  }
}

void showDrawing() {
  // this runs the loop presentation
  graphicsDraw();
  for (int i = planes.size() - 1; i >= 0; i--) {
    Plane plane = planes.get(i);
    plane.update(graphics[i]);
  }
}

void configDrawing() {
  // this lets you drag around the corner of the planes with debug graphics and without loop 
  dragging = false;
  for (int i = planes.size() - 1; i >= 0; i--) {
    Plane plane = planes.get(i);
    plane.dragCorners();
    plane.updateConfig();
    plane.debugCountConfig(i);
  }
  mouse();
  saveQuadsCSV();
}

// --------------------------------

void input() {
  if (keyPressed) {
    if (key == 'r' || key == 'R') {
      init();
    }
    if (key == 'c' || key == 'C') {
      init();
      configMode = !configMode;
    }
    // debouncing, sort of:
    float pauseStart = millis();
    while (millis() < pauseStart + 200);
  }
}
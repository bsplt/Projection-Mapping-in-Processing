// this is a fixed value for all effects using strokeWeight()
float lineWeight = 3;

// stores virtual displays, that will be mapped:
PGraphics[] graphics;
int graphicsCount;

// stores all effects that are in action with the target display:
ArrayList<Effect> effects;

// stores all effects
Table timelineCSV;

void loadTimelineCSV() {
  /* the CSV with the effects timeline is written without header in the style of:
   "3000,5000,2,"LineHoriLeft""
   which is:
   "Start Time, End Time, Target Display (PGraphics), Effect Name" */
  timelineCSV = loadTable("timeline.csv");
}

void graphicsSetup(int amount) {
  //creates as much virtual displays as there are planes to project on
  loadTimelineCSV();
  graphicsCount = amount;
  graphics = new PGraphics[graphicsCount];
  for (int i = 0; i < graphicsCount; i++) {
    // this is actually a quality/performance setting, also this is important for the aspect ratio 
    graphics[i] = createGraphics(400, 400);
  }
  effects = new ArrayList<Effect>();
  println("Set up " + graphicsCount + " virtual canvases.");
}

void graphicsDraw() {
  for (int i = timelineCSV.getRowCount() - 1; i >= 0; i--) {
    TableRow row = timelineCSV.getRow(i);
    /* when the realtime is between the start and end time of an effect stated in the timeline
     the effect gets removed from the CSV and is loaded into the effects list */
    if ((row.getFloat(0) < millis() - timeOffset) && (row.getFloat(1) > millis() - timeOffset)) {
      switch(row.getString(3)) {
        /* this is somehow the translation between the CSV and the classes –
         each effect needs an entry here to be accessible through the CSV */
      case "LineVertDown":
        effects.add(new LineVertDown(row.getFloat(0), row.getFloat(1), graphics[row.getInt(2)]));
        break;
      case "LineVertUp":
        effects.add(new LineVertUp(row.getFloat(0), row.getFloat(1), graphics[row.getInt(2)]));
        break;
      case "LineHoriLeft":
        effects.add(new LineHoriLeft(row.getFloat(0), row.getFloat(1), graphics[row.getInt(2)]));
        break;
      case "LineHoriRight":
        effects.add(new LineHoriRight(row.getFloat(0), row.getFloat(1), graphics[row.getInt(2)]));
        break;
      case "Fill":
        effects.add(new Fill(row.getFloat(0), row.getFloat(1), graphics[row.getInt(2)]));
        break;
      case "FadeOut":
        effects.add(new FadeOut(row.getFloat(0), row.getFloat(1), graphics[row.getInt(2)]));
        break;
      case "FadeIn":
        effects.add(new FadeIn(row.getFloat(0), row.getFloat(1), graphics[row.getInt(2)]));
        break;
      case "Outline":
        effects.add(new Outline(row.getFloat(0), row.getFloat(1), graphics[row.getInt(2)]));
        break;
      case "StripesHori":
        effects.add(new StripesHori(row.getFloat(0), row.getFloat(1), graphics[row.getInt(2)]));
        break;
      case "StripesVert":
        effects.add(new StripesVert(row.getFloat(0), row.getFloat(1), graphics[row.getInt(2)]));
        break;
      case "RandomHori":
        effects.add(new RandomHori(row.getFloat(0), row.getFloat(1), graphics[row.getInt(2)]));
        break;
      case "RandomVert":
        effects.add(new RandomVert(row.getFloat(0), row.getFloat(1), graphics[row.getInt(2)]));
        break;
      case "FFTFillSlow":
        effects.add(new FFTFillSlow(row.getFloat(0), row.getFloat(1), graphics[row.getInt(2)]));
        break;
      case "FFTFillFast":
        effects.add(new FFTFillFast(row.getFloat(0), row.getFloat(1), graphics[row.getInt(2)]));
        break;
      case "BlueScreen":
        effects.add(new BlueScreen(row.getFloat(0), row.getFloat(1), graphics[row.getInt(2)]));
        break;
      case "ArduinoSwitch":
        effects.add(new ArduinoSwitch(row.getFloat(0), row.getFloat(1), graphics[row.getInt(2)]));
        break;
      case "ArduinoButton":
        effects.add(new ArduinoButton(row.getFloat(0), row.getFloat(1), graphics[row.getInt(2)]));
        break;
      case "Restart":
        effects.add(new Restart(row.getFloat(0), row.getFloat(1), graphics[row.getInt(2)]));
        break;
      default:
        println("SOMETHING IS WRONG");
        break;
      }
      timelineCSV.removeRow(i);
    }
  }

  // refreshing each display with a black background:
  for (int i = 0; i < graphicsCount; i++) {
    graphics[i].beginDraw();
    graphics[i].background(0);
    graphics[i].endDraw();
  }

  // drawing every active effect and eventually removing them: 
  for (int i = effects.size() - 1; i >= 0; i--) {
    Effect effect = effects.get(i);
    effect.update();
    if (effect.transition() > 1) {
      effects.remove(i);
    }
  }
}

// --------------------------------

class Effect {
  /* This is the parent class for all effects and does nothing.
   Though it has transition() which is used for effect animation and checking if the effect is done in the graphicsDraw() */
  float start, end;
  PGraphics target;

  Effect(float start, float end, PGraphics target) {
    this.start = start + timeOffset;
    this.end = end + timeOffset;
    this.target = target;
  }

  void update() {
  };

  float transition() {
    return ((millis() - start) / (end - start));
  }
}

// --------------------------------

/* Following are the graphical effects.
 Each is a class inhertied by the Effect class so they all can be stored in one ArrayList.
 GraphicsDraw() cares about the proper initialization and removing, so nothing weird happens.*/

class LineVertDown extends Effect {
  LineVertDown(float start, float end, PGraphics target) {
    super(start, end, target);
  }

  void update() {
    target.beginDraw();
    target.stroke(255);
    target.strokeWeight(lineWeight);
    target.line(0, target.height * transition(), target.width, target.height * transition());
    target.endDraw();
  }
}

class LineVertUp extends Effect {
  LineVertUp(float start, float end, PGraphics target) {
    super(start, end, target);
  }

  void update() {
    target.beginDraw();
    target.stroke(255);
    target.strokeWeight(lineWeight);
    target.line(0, target.height - target.height * transition(), target.width, target.height - target.height * transition());
    target.endDraw();
  }
}

class LineHoriLeft extends Effect {
  LineHoriLeft(float start, float end, PGraphics target) {
    super(start, end, target);
  }

  void update() {
    target.beginDraw();
    target.stroke(255);
    target.strokeWeight(lineWeight);
    target.line(target.width * transition(), 0, target.width * transition(), target.height);
    target.endDraw();
  }
}

class LineHoriRight extends Effect {
  LineHoriRight(float start, float end, PGraphics target) {
    super(start, end, target);
  }

  void update() {
    target.beginDraw();
    target.stroke(255);
    target.strokeWeight(lineWeight);
    target.line(target.width - target.width * transition(), 0, target.width - target.width * transition(), target.height);
    target.endDraw();
  }
}

class Fill extends Effect {
  Fill(float start, float end, PGraphics target) {
    super(start, end, target);
  }

  void update() {
    target.beginDraw();
    target.fill(255);
    target.noStroke();
    target.rect(0, 0, target.width, target.height);
    target.endDraw();
  }
}

class FadeOut extends Effect {
  FadeOut(float start, float end, PGraphics target) {
    super(start, end, target);
  }

  void update() {
    target.beginDraw();
    target.fill(255, 255 * (1- transition()));
    target.noStroke();
    target.rect(0, 0, target.width, target.height);
    target.endDraw();
  }
}

class FadeIn extends Effect {
  FadeIn(float start, float end, PGraphics target) {
    super(start, end, target);
  }

  void update() {
    target.beginDraw();
    target.fill(255, 255 * transition());
    target.noStroke();
    target.rect(0, 0, target.width, target.height);
    target.endDraw();
  }
}

class Outline extends Effect {
  Outline(float start, float end, PGraphics target) {
    super(start, end, target);
  }

  void update() {
    target.beginDraw();
    target.stroke(255);
    target.strokeWeight(lineWeight);
    target.line(0, 0, map(transition(), 0, 0.25, 0, target.width - lineWeight), 0);
    if (transition() > 0.25) {
      target.line(target.width - lineWeight, 0, target.width - lineWeight, map(transition(), 0.25, 0.5, 0, target.height));
    }
    if (transition() > 0.5) {
      target.line(target.width - lineWeight, target.height - lineWeight, map(transition(), 0.5, 0.75, target.width - lineWeight, 0), target.height - lineWeight);
    }
    if (transition() > 0.75) {
      target.line(0, target.height - lineWeight, 0, map(transition(), 0.75, 1, target.height - lineWeight, 0));
    }
    target.endDraw();
  }
}

class StripesHori extends Effect {
  int lineCount = 15;
  StripesHori(float start, float end, PGraphics target) {
    super(start, end, target);
  }

  void update() {
    target.beginDraw();
    target.stroke(255);
    target.strokeWeight(lineWeight);
    for (int i = 0; i < lineCount; i++) {
      float pos = (target.height * ((float) i / lineCount) + target.height * transition()) % target.height; 
      target.line(0, pos, target.width, pos);
    }
    target.endDraw();
  }
}

class StripesVert extends Effect {
  int lineCount = 15;
  StripesVert(float start, float end, PGraphics target) {
    super(start, end, target);
  }

  void update() {
    target.beginDraw();
    target.stroke(255);
    target.strokeWeight(lineWeight);
    for (int i = 0; i < lineCount; i++) {
      float pos = (target.width * ((float) i / lineCount) + target.width * transition()) % target.width; 
      target.line(pos, 0, pos, target.height);
    }
    target.endDraw();
  }
}

class RandomHori extends Effect {
  RandomHori(float start, float end, PGraphics target) {
    super(start, end, target);
  }

  void update() {
    target.beginDraw();
    target.fill(255);
    target.noStroke();
    for (int i = 0; i < random(2, 10); i++) {
      target.fill(random(255), random(255));
      target.rect(random(target.width), 0, random(target.width), target.height);
    }
    target.endShape();
    target.endDraw();
  }
}

class RandomVert extends Effect {
  RandomVert(float start, float end, PGraphics target) {
    super(start, end, target);
  }

  void update() {
    target.beginDraw();
    target.fill(255);
    target.noStroke();
    for (int i = 0; i < random(2, 10); i++) {
      target.fill(random(255), random(255));
      target.rect(0, random(target.height), target.width, random(target.height));
    }
    target.endShape();
    target.endDraw();
  }
}

class FFTFillSlow extends Effect {
  BeatDetect beat;
  float fill = 0;
  FFTFillSlow(float start, float end, PGraphics target) {
    super(start, end, target);
    beat = new BeatDetect();
  }

  void update() {
    beat.detect(audioPlayer.mix);
    if (beat.isOnset()) {
      fill = 255;
    }
    target.beginDraw();
    target.background(int(fill));
    target.endDraw();
    fill *= 0.97;
  }
}

class FFTFillFast extends Effect {
  BeatDetect beat;
  float fill = 0;
  FFTFillFast(float start, float end, PGraphics target) {
    super(start, end, target);
    beat = new BeatDetect();
  }

  void update() {
    beat.detect(audioPlayer.mix);
    if (beat.isOnset()) {
      fill = 255;
    }
    target.beginDraw();
    target.background(int(fill));
    target.endDraw();
    fill *= 0.7;
  }
}

class BlueScreen extends Effect {
  BlueScreen(float start, float end, PGraphics target) {
    super(start, end, target);
  }

  void update() {
    background(0, 0, 255);
    target.beginDraw();
    target.background(0, 0, 255);
    target.endDraw();
  }
}

class Restart extends Effect {
  Restart(float start, float end, PGraphics target) {
    super(start, end, target);
    triggerInit = true;
  }
}
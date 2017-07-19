/* When you use textures for quads, Processing can't distort the textures right, like you would expect in projection mapping for example.
 Instead it divides the texture up into two triangles which distort from a middle axis.
 This software splits the large projection quad into a lot of smaller ones, so that you can stretch the texture right over them with the help of UV mapping.
 Then the perspectively distortion looks a lot more right because you can't see the triangles anymore.*/

class SmallQuad {
  /* This class stores the coordinates and UV coordinates of a grid unit of a Plane depending on the resolution.
   It's a wrapper without functions for convenience. */

  PVector e, f, g, h;
  float uLow, uHigh, vLow, vHigh;

  SmallQuad(PVector eIn, PVector fIn, PVector gIn, PVector hIn, float uLowIn, float uHighIn, float vLowIn, float vHighIn) {
    e = eIn;
    f = fIn;
    g = gIn;
    h = hIn;
    uLow = uLowIn;
    uHigh = uHighIn;
    vLow = vLowIn;
    vHigh = vHighIn;
  }
}

// --------------------------------

// A plane that you would map in projection:
class Plane {
  // Resolution of the distortion grid, value of n results in n² quads.
  float resolution = 16;

  PVector[] shape = new PVector[4];
  ArrayList<SmallQuad> smallQuads = new ArrayList<SmallQuad>();

  Plane(float x1, float y1, float x2, float y2, float x3, float y3, float x4, float y4) {
    shape[0] = new PVector(x1, y1);
    shape[1] = new PVector(x2, y2);
    shape[2] = new PVector(x3, y3);
    shape[3] = new PVector(x4, y4);
    refresh();
  }

  void refresh() {
    for (int i = smallQuads.size() - 1; i >= 0; i--) {
      smallQuads.remove(i);
    }

    for (int i = 0; i < resolution; i++) {
      for (int j = 0; j < resolution; j++) {
        /* Imagine the large quad has corners called A, B, C and D clockwise.
         What this does now is to make a small quad for every step in the resolution.
         Small quads have corner points called E, F, G and H clockwise.
         These line up perfectly well so that for example line FG of one quad is the HE of the right neighbour. 
         First this calculates the heights from AB to CD and from BC to DA, each twice in an offset of a step.
         Then it searches for the four intersections of the four heights, which are the corners of the small quad.
         */

        // calculating the heights:
        PVector ab0 = getQuadHeightPoints(shape[0].x, shape[0].y, shape[1].x, shape[1].y, float(i));
        PVector bc0 = getQuadHeightPoints(shape[1].x, shape[1].y, shape[2].x, shape[2].y, float(j)); 
        PVector cd0 = getQuadHeightPoints(shape[3].x, shape[3].y, shape[2].x, shape[2].y, float(i));
        PVector da0 = getQuadHeightPoints(shape[0].x, shape[0].y, shape[3].x, shape[3].y, float(j));
        PVector ab1 = getQuadHeightPoints(shape[0].x, shape[0].y, shape[1].x, shape[1].y, float(i + 1));
        PVector bc1 = getQuadHeightPoints(shape[1].x, shape[1].y, shape[2].x, shape[2].y, float(j + 1)); 
        PVector cd1 = getQuadHeightPoints(shape[3].x, shape[3].y, shape[2].x, shape[2].y, float(i + 1));
        PVector da1 = getQuadHeightPoints(shape[0].x, shape[0].y, shape[3].x, shape[3].y, float(j + 1));

        // calculating the intersections:
        PVector e = getHeightIntersection(ab0, cd0, da0, bc0);
        PVector f = getHeightIntersection(ab1, cd1, da0, bc0);
        PVector g = getHeightIntersection(ab1, cd1, da1, bc1);
        PVector h = getHeightIntersection(ab0, cd0, da1, bc1);

        // calculating the UV coordinates for the texture:
        float uLow = (float) i / resolution;
        float uHigh = (float) (i + 1) / resolution;
        float vLow = (float) j / resolution;
        float vHigh = (float) (j + 1) / resolution;

        smallQuads.add(new SmallQuad(e, f, g, h, uLow, uHigh, vLow, vHigh));
      }
    }
  }

  PVector getQuadHeightPoints(float x0, float y0, float x1, float y1, float step) {
    return new PVector((x1 - x0) * (step / resolution) + x0, (y1 - y0) * (step / resolution) + y0);
  }

  PVector getHeightIntersection(PVector p1, PVector p2, PVector p3, PVector p4) {
    // got this from the interwebs, it calculates the intersection between two vectors
    PVector b = PVector.sub(p2, p1);
    PVector d = PVector.sub(p4, p3);

    float b_dot_d_perp = b.x * d.y - b.y * d.x;
    if (b_dot_d_perp == 0) { 
      return null;
    }

    PVector c = PVector.sub(p3, p1);
    float t = (c.x * d.y - c.y * d.x) / b_dot_d_perp;
    if (t < 0 || t > 1) { 
      //return null;
    }
    float u = (c.x * b.y - c.y * b.x) / b_dot_d_perp;
    if (u < 0 || u > 1) { 
      //  return null;
    }

    return new PVector(p1.x+t*b.x, p1.y+t*b.y);
  }

  void updateConfig() {
    for (int i = smallQuads.size() - 1; i >= 0; i--) {
      SmallQuad sq = smallQuads.get(i);
      // mapping:
      noStroke();
      beginShape();
      textureMode(NORMAL);
      texture(img);
      try {
        vertex(sq.e.x, sq.e.y, sq.uLow, sq.vLow);
        vertex(sq.f.x, sq.f.y, sq.uHigh, sq.vLow);
        vertex(sq.g.x, sq.g.y, sq.uHigh, sq.vHigh);
        vertex(sq.h.x, sq.h.y, sq.uLow, sq.vHigh);
      } 
      catch (NullPointerException e) {
        // sometimes this happens ... ?
      }
      endShape();
    }
  }
  
  void debugCountConfig(int i) {
    float x = (shape[2].x - shape[0].x) / 2 + shape[0].x;
    float y = (shape[2].y - shape[0].y) / 2 + shape[0].y;
    textAlign(CENTER, CENTER);
    textSize(32);
    fill(255);
    text(i, x, y);
  }

  void update(PGraphics graphic) {
    for (int i = smallQuads.size() - 1; i >= 0; i--) {
      SmallQuad sq = smallQuads.get(i);
      // mapping:
      noStroke();
      beginShape();
      textureMode(NORMAL);
      texture(graphic);
      vertex(sq.e.x, sq.e.y, sq.uLow, sq.vLow);
      vertex(sq.f.x, sq.f.y, sq.uHigh, sq.vLow);
      vertex(sq.g.x, sq.g.y, sq.uHigh, sq.vHigh);
      vertex(sq.h.x, sq.h.y, sq.uLow, sq.vHigh);
      endShape();
    }
  }

  void dragCorners() {
    for (int i = 0; i < 4; i++) {
      if ((dist(mouseX, mouseY, shape[i].x, shape[i].y) < 15) || (dist(pmouseX, pmouseY, shape[i].x, shape[i].y) < 15)) {
        if (mousePressed && !dragging) {
          dragging = true;
          shape[i].x = mouseX;
          shape[i].y = mouseY;
        }
      }
    }
    refresh();
  }

  TableRow coords() {
    /* Exporting the corner points as a row for the CSV */
    Table table = new Table();
    TableRow coords = table.addRow();
    int rowPos = 0;
    for (int i = 0; i < 8; i++) {
      table.addColumn();
    }
    for (int i = 0; i < 4; i++) {
      coords.setFloat(rowPos, shape[i].x);
      coords.setFloat(rowPos + 1, shape[i].y);
      rowPos += 2;
    }
    return coords;
  }
}
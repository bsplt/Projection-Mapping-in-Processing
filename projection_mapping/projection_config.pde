// This is a lock when dragging corners, so that you can't accidentally drag multiple:
Boolean dragging;

// Testpattern goes in here:
PImage img;

Table planesCSV;

void mouse() {
  float radius = 15;
  noCursor();
  noStroke();
  fill(#FFFF00, 64);
  ellipseMode(RADIUS);
  ellipse(mouseX, mouseY, radius, radius);
  if (!mousePressed) {
    stroke(255);
    strokeWeight(1);
    line(mouseX, mouseY - radius * 0.75, mouseX, mouseY + radius * 0.75);
    line(mouseX - radius * 0.75, mouseY, mouseX + radius * 0.75, mouseY);
  }
}

void loadQuadsCSV() {
  /* the CSV with the planes is written without header in the style of:
   "211.0,44.0,756.0,42.0,759.0,412.0,218.0,413.0"
   which is:
   "A.x, A.y, B.x, B.y, C.x, C.y, D.x, D.y" */
  planesCSV = loadTable("planes.csv");
  for (TableRow row : planesCSV.rows()) {
    planes.add(new Plane(row.getFloat(0), row.getFloat(1), row.getFloat(2), row.getFloat(3), row.getFloat(4), row.getFloat(5), row.getFloat(6), row.getFloat(7)));
  }
}

void saveQuadsCSV() {
  if (keyPressed) {
    if (key == 's' || key == 'S') {
      Table saveTable = new Table();
      for (int i = 0; i < planes.size(); i++) {
        Plane plane = planes.get(i);
        saveTable.addRow(plane.coords());
      }
      saveTable(saveTable, "data/planes.csv");
      println("SAVED");

      // debouncing, sort of again:
      float pauseStart = millis();
      while (millis() < pauseStart + 200);
    }
  }
}
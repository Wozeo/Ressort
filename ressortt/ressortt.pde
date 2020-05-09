//Inspiré de http://www.alessandroroussel.com/creationsList/springs/
int nr = 2;
ArrayList<ressort> res = new ArrayList<ressort>();
float frottement = 0.9;
float masseR = 50;
float kR = 1;
float loR = 150;
float deltaM = 0; // prourcentage : 0.1 -> +- 10 pourcent de masseI

float xb = 0, yb = 0, lxb = 400, lyb = 150;
boolean box = false;

boolean grav = false;
float g = 0.1;

boolean record = false;
int t = 0;
void setup() {
  size(700, 700);
  for (int i = 0; i < nr; i ++) {
    ArrayList<Integer> rel = new ArrayList<Integer>();
    for (int j = 0; j < nr; j ++) {
      if (i != j) {
        rel.add(j);
      }
    }
    res.add(new ressort(random(0, width), random(0, height), rel, masseR, kR, loR, false));
  }

  //nr ++;
  //ArrayList<Integer> rel = new ArrayList<Integer>();
  //for (int j = 0; j < nr-1; j ++) {
  //  rel.add(j);
  //}
  //for (int i = 0; i < res.size(); i ++) {
  //  ressort resi = res.get(i);
  //  resi.relier.add(nr-1);
  //}
  //res.add(new ressort(width/2, height/2, rel, masseR, kR, loR/2.0, true));
}


void draw() {
  background(0);
  for (int i = 0; i < res.size(); i ++) {
    ressort resi = res.get(i);
    resi.force();
    resi.deplaff();
  }
  if ( mousePressed == true) {
    if (mouseButton ==RIGHT) {
      centrage(mouseX, mouseY);
    } else if (box) {
      xb = mouseX;
      yb = mouseY;
    }
  }
  if (box) {
    stroke(180);
    fill(180);
    rect(xb, yb, lxb, lyb);
  }
  if (record ) {
    t ++;
    if (t%3 == 0) {
      saveFrame("images/frame-#########.png");
      //println("record"+int(random(0,10)));
    }
  }
}

class ressort {

  float x, y, vx, vy;
  ArrayList<Integer> relier;
  float masse;
  float k;
  float lo;
  float vgrav;
  boolean fix;

  ressort(float xi, float yi, ArrayList<Integer> relierI, float masseI, float ki, float loi, boolean fixer) {
    x = xi;
    y = yi;
    relier = relierI;
    masse = random(masseI*(1-deltaM), masseI*(1+deltaM));
    k = ki;
    lo = loi;
    vx = 0;
    vy = 0;
    fix = fixer;
  }

  void force() {
    if (fix == false) {
      float fx = 0;
      float fy = 0;
      for (int i = 0; i < relier.size(); i ++) {

        ressort resi = res.get(relier.get(i));

        float xrr = resi.x;
        float yrr = resi.y;

        float dist = sqrt((x-xrr)*(x-xrr)+(y-yrr)*(y-yrr));
        float nf = -k*(dist-lo);

        float ag = atan2((y-yrr), (x-xrr));

        fx += cos(ag)*nf;
        fy += sin(ag)*nf;
      }

      float ax = fx/masse;
      float ay = (fy)/masse;

      vx += ax;
      vy += ay;

      vx *= frottement;
      vy *= frottement;

      if (grav) {
        vgrav += g;
      }
    }
  }

  void deplaff() {
    if (fix == false) {
      x += vx;
      y += vy+vgrav;


      if (x > width) {
        x = width;
      }
      if (x < 0) {
        x = 0;
      }
      if (y > height) {
        y = height;
      }
      if (y < 0) {
        y = 0;
      }

      if (box) {
        if (x > xb && x < xb+lxb && y > yb && y < yb+lyb) {
          if ( min(abs(yb-y), abs(yb+lyb-y)) < min(abs(xb-x), abs(xb+lxb-x))) {
            if (y < yb+lyb/2.0) {
              y = yb;
            } else {
              y = yb+lyb;
            }
          } else {
            if (x < xb+lxb/2.0) {
              x = xb;
            } else {
              x = xb+lxb;
            }
          }
        }
      }
    }

    stroke(255);
    fill(255);
    ellipse(x, y, masse/4.0, masse/4.0);
    //ellipse(x, y, 2.924*pow(masse,1/3.0), 2.924*pow(masse,1/3.0));
  }
}

void ajout(float xa, float ya) {
  nr ++;
  ArrayList<Integer> rel = new ArrayList<Integer>();
  for (int j = 0; j < nr-1; j ++) {
    rel.add(j);
  }
  for (int i = 0; i < res.size(); i ++) {
    ressort resi = res.get(i);
    resi.relier.add(nr-1);
  }
  res.add(new ressort(xa, ya, rel, masseR, kR, loR, false));
}

void centrage(float xc, float yc) {
  float xm = 0;
  float ym = 0;
  for (int i = 0; i < res.size(); i ++) {
    ressort resi = res.get(i);
    if (resi.fix == false) {
      xm += (resi.x-xc);
      ym += (resi.y-yc);
    }
  }
  xm /= res.size();
  ym /= res.size();

  for (int i = 0; i < res.size(); i ++) {
    ressort resi = res.get(i);
    if (resi.fix == false) {
      resi.x -= xm;
      resi.y -= ym;
      resi.vx = 0;
      resi.vy = 0;
      resi.vgrav = 0;
    }
  }
}

void mouseClicked() {
  if (mouseButton ==LEFT && box == false) {
    ajout(mouseX, mouseY);
  } else {
    centrage(mouseX, mouseY);
  }
}


void keyPressed() {
  if (keyCode == 68) {//d
    for (int i = 0; i < 10; i ++) {
      ajout(random(0, width), random(0, height));
    }
  } else if (keyCode == 66) {//b
    box = !box;
  } else if (keyCode == 78) {//n
    float li = lxb;
    lxb = lyb;
    lyb = li;
  }
  if (keyCode == 37) {
    lxb -= 1;
  }
  if (keyCode == 38) {
    lyb -= 2;
  }
  if (keyCode == 39) {
    lxb += 5;
  }
  if (keyCode == 40) {
    lyb += 5;
  }
  if (keyCode == 71) {
    grav = !grav;
  }
  if (keyCode == 80) {//p
    //lo += 5;
  }
  if (keyCode == 77) {//m
    //lo -= 5;
  }
  if (keyCode == 82) {//r
    record = !record;
    println(record);
  }
  println(keyCode);
}

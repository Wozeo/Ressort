float boule[][] = {{534.0, 321.0}, {489.0, 258.0}, {419.0, 216.0}, {336.0, 222.0}, {248.0, 277.0}, {214.0, 368.0}, {262.0, 454.0}, {365.0, 486.0}, {473.0, 433.0}, {517.0, 346.0}, {440.0, 284.0}, {335.0, 275.0}, {271.0, 323.0}, {276.0, 395.0}, {338.0, 426.0}, {438.0, 395.0}, {375.0, 341.0}, {326.0, 361.0}, {343.0, 384.0}, {432.0, 336.0}, {511.0, 383.0}, {421.0, 461.0}, {397.0, 406.0}, {305.0, 467.0}, {380.0, 279.0}};
float boule2[][] = {{234.0, 417.0}, {267.0, 417.0}, {290.0, 407.0}, {323.0, 392.0}, {343.0, 382.0}, {363.0, 379.0}, {382.0, 364.0}, {384.0, 337.0}, {365.0, 309.0}, {347.0, 301.0}, {322.0, 292.0}, {285.0, 287.0}, {265.0, 310.0}, {231.0, 338.0}, {201.0, 358.0}, {189.0, 382.0}, {202.0, 404.0}, {216.0, 433.0}, {241.0, 441.0}, {269.0, 432.0}, {268.0, 388.0}, {237.0, 396.0}, {222.0, 380.0}, {240.0, 366.0}, {260.0, 347.0}, {287.0, 375.0}, {289.0, 339.0}, {299.0, 308.0}, {316.0, 336.0}, {338.0, 323.0}, {361.0, 338.0}, {337.0, 354.0}, {311.0, 367.0}};

boolean grav = false;
float g = 0.01;
ressort test = new ressort(boule2);

void setup() {
  size(700, 700);
  float pt[][] = new float[50][2];
  for (int i = 0; i < 50; i ++) {
    float x;
    float y;
    do {
      x = random(0, width);
      y  = random(0, height);
    } while (sqrt((x-width/2)*(x-width/2)+(y-height/2)*(y-height/2)) > width/4.0);
    pt[i][0] = x;
    pt[i][1] = y;
  }
  //test = new ressort(pt);
}

void draw() {
  background(0);
  test.force();
  test.depla();
  test.aff();
  test.deplS(mouseX, mouseY);
}

class ressort {

  float points[][];
  float pos[][];
  float vit[][];
  ArrayList<ArrayList> lier = new ArrayList<ArrayList>();
  int np;
  float masse = 40;
  float frottement = 0.90;
  float k = 2;
  float dcontact = 100;

  ressort(float pointsi[][]) {
    np = pointsi.length;
    points = pointsi;
    pos = new float[np][2];
    vit = new float[np][2];
    for (int i = 0; i < np; i ++) {
      pos[i][0] = points[i][0];
      pos[i][1] = points[i][1];
    }
    deflien();
  }

  void force() {

    for (int i = 0; i < np; i ++) {
      float fx = 0;
      float fy = 0;
      for (int j = 0; j < np; j ++) {
        if (dedans(j, lier.get(i))) {
          float d = sqrt( (pos[i][0]-pos[j][0])*(pos[i][0]-pos[j][0])+(pos[i][1]-pos[j][1])*(pos[i][1]-pos[j][1]));
          float lo = sqrt( (points[i][0]-points[j][0])*(points[i][0]-points[j][0])+(points[i][1]-points[j][1])*(points[i][1]-points[j][1]));

          float nf = -k*(d-lo);
          float ag = atan2((pos[i][1]-pos[j][1]), (pos[i][0]-pos[j][0]));
          fx += cos(ag)*nf;
          fy += sin(ag)*nf;
        }
      }

      float ax = fx/masse;
      float ay = fy/masse;
      if (grav) {
        ay += g/frottement;
      }
      vit[i][0] += ax;
      vit[i][1] += ay;
      vit[i][0] *= frottement;
      vit[i][1] *= frottement;
    }
  }

  void depla() {
    for (int i = 0; i < np; i ++) {
      pos[i][0] += vit[i][0];
      pos[i][1] += vit[i][1];
      if (pos[i][0] < 0) {
        pos[i][0] = 0;
        vit[i][0] = 0;
      }
      if (pos[i][1] < 0) {
        pos[i][1] = 0;
        vit[i][1] = 0;
      }
      if (pos[i][0] > width) {
        pos[i][0] = width;
        vit[i][0] = 0;
      }
      if (pos[i][1] > height) {
        pos[i][1] = height;
        vit[i][1] = 0;
      }
    }
  }

  void aff() {
    for (int i = 0; i < np; i ++) {

      stroke(255);
      for (int j = 0; j < np; j ++) {
        if (dedans(j, lier.get(i))) {
          line(pos[i][0], pos[i][1], pos[j][0], pos[j][1]);
        }
      }
      stroke(0);
      fill(255);
      ellipse(pos[i][0], pos[i][1], 10, 10);
    }
    deflien();
  }

  void deplS(float xc, float yc) {
    if (mousePressed && mouseButton == RIGHT) {
      float xm = 0;
      float ym = 0;
      for (int i = 0; i < np; i ++) {
        xm += (pos[i][0]-xc);
        ym += (pos[i][1]-yc);
      }
      xm /= np;
      ym /= np;

      for (int i = 0; i < np; i ++) {
        pos[i][0] -= xm;
        pos[i][1] -= ym;
        //vit[i][0] = 0;
        //vit[i][1] = 0;
      }
    }
  }

  void deflien() {
    lier = new ArrayList<ArrayList>();
    for (int i = 0; i < np; i ++) {
      ArrayList<Integer> liste = new ArrayList<Integer>();
      //liste.add(i);
      for (int j = 0; j < np; j ++) {
        if (sqrt( (pos[i][0]-pos[j][0])*(pos[i][0]-pos[j][0])+(pos[i][1]-pos[j][1])*(pos[i][1]-pos[j][1])) < dcontact) {
          liste.add(j);
        }

        //for (int k = 0; k < np; k ++) {
        //  if (i != j && i != k && j != k) {
        //    PVector result[] = TC(points[i], points[j], points[k]);
        //    boolean dedans = false;

        //    for (int l = 0; l < np; l ++) {
        //      if (l != i && l != j && l != k ) {
        //        if ( (points[l][0]-result[1].x)*(points[l][0]-result[1].x) + (points[l][1]-result[1].y)*(points[l][1]-result[1].y) < result[0].x) {
        //          dedans = true;
        //        }
        //      }
        //    }

        //    if (dedans == false) {
        //      liste.add(j);
        //      liste.add(k);
        //    }
        //  }
        //}
      }
      lier.add(liste);
    }
  }
}


PVector[] TC (float p1[], float p2[], float p3[]) {
  PVector centre  = new PVector(0, 0);

  float a = p1[0]-p3[0];
  float b = p1[1]-p3[1];
  float c = (p3[0]-p1[0])*(p1[0]+p3[0])/2 + (p3[1]-p1[1])*(p1[1]+p3[1])/2;

  float ap = p1[0]-p2[0];
  float bp = p1[1]-p2[1];
  float cp = (p2[0]-p1[0])*(p1[0]+p2[0])/2 + (p2[1]-p1[1])*(p1[1]+p2[1])/2;

  float xC= 0, yC = 0;
  if (a == 0) {
    xC = (c*bp-b*cp)/(b*ap);
    yC = -c/b;
  } else {
    yC = (ap*c-a*cp)/(a*bp-ap*b);
    xC = -(b*yC+c)/a;
  }

  centre.x = xC;
  centre.y = yC;


  float dist = (p1[0]-centre.x)*(p1[0]-centre.x)+(p1[1]-centre.y)*(p1[1]-centre.y);
  PVector d = new PVector(dist, dist);
  PVector result[] = {d, centre};
  return result;
}

boolean dedans(int x, ArrayList<Integer> liste) {
  if (liste.size() > 0) {
    boolean rep = false;
    for (int i = 0; i < liste.size(); i ++) {
      if (liste.get(i) == x) {
        rep = true;
      }
    }
    return rep;
  } else {
    return false;
  }
}
float vl = 40;
void keyPressed() {
  println(keyCode);
  if (keyCode == 81 ||keyCode == 90 || keyCode == 68 || keyCode == 83) {
    for (int i = 0; i < test.np; i ++) {
      if (keyCode == 81) {//q
        test.vit[i][0] -= vl;
      }
      if (keyCode == 90) {//z
        test.vit[i][1] -= vl;
      }
      if (keyCode == 68) {//d
        test.vit[i][0] += vl;
      }
      if (keyCode == 83) {//s
        test.vit[i][1] += vl;
      }
    }
  }
  if (keyCode == 71) {//g
    grav = !grav;
  }
  if (keyCode == 80) {//p
    test.dcontact += 5;
    println(test.dcontact);
  }
  if (keyCode == 77) {
    test.dcontact -= 5;
    println(test.dcontact);
  }
}

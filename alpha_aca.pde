import java.util.*;

final int box_size = 10;
int time_len;
int cells;
float alpha=1.0;

int randomIC[] = {1, 0, 1, 0, 0, 0, 1, 1, 1, 1, 1, 1, 0, 1, 1, 0, 1, 0, 0, 1, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 0, 1, 0, 1, 0, 1, 1, 1, 1, 1, 0, 1, 1, 0, 0, 1, 1, 1, 0, 1, 0, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 1, 1, 1, 1, 0, 0, 0, 1, 1, 1, 1, 1, 0, 1, 0, 1, 0, 1, 0, 0, 0, 0, 1, 1, 0, 0, 1, 0, 0, 1, 1, 0, 0, 1, 1};

int ecas[] = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 18, 19, 22, 23, 24, 25,
         26, 27, 28, 29, 30, 32, 33, 34, 35, 36, 37, 38, 40, 41, 42, 43, 44, 45, 46, 50, 51,
         54, 56, 57, 58, 60, 62, 72, 73, 74, 76, 77, 78, 90, 94, 104, 105, 106, 108, 110, 128,
         129, 130, 132, 134, 136, 138, 140, 142, 146, 150, 152, 154, 156, 160, 161, 162, 164, 168,
         170, 172, 178, 184, 200, 204, 232};

int alfy[] = { 0, 1, 2, 3 , 4, 5, 6, 7, 8, 9, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100, 200, 300, 400, 500, 600,
700, 800, 900, 910, 920, 930, 940, 950, 960, 970, 980, 990, 991, 992, 993, 994, 995, 996, 997, 998, 999, 1000};

void setup() {
  size(691 , 2073);
  time_len = height / box_size;
  cells = width / box_size;
  background(102);
  noLoop();
}


void draw() {
  stroke(128);
  int[] a = new int[cells];
  fillRandom(a, randomIC);
  
  int[] gaps0 = getRandomGaps(0);
  
   boolean[][] spatial0 = getSpatialPos(0);
   boolean[][] noise0 = getSpatialPos(0);



  for(int e : ecas) {
    for(int al : alfy) {
      CA ca = new CA(1, e);
      alpha = al / 1000.0;
  drawCA(ca, a, 0, gaps0, noise0, spatial0);
  String ec = String.format("%03d",e);
  
  save("alpha/"+ec+"/ECA-"+ec+"-alpha-"+al+".png"); 
    }
}
  exit ();

  
}

boolean[][] getSpatialPos(float prob) {
  boolean[][] s = new boolean[time_len][cells];
  for(int t = 0; t<time_len; t++)
  for(int c = 0; c<cells; c++)
    s[t][c] = random(1.0) < prob;
  
  return s;
}

int[] getRandomGaps(int max) {
  int[] gaps = new int[time_len];
  for (int i=0;i<time_len;i++) {
    gaps[i] = max==0 ? 0 : int(random(0, max));
  }
  return gaps;
}

void drawCA(CA automata, int[] ic, int x) {
  drawCA(automata, ic, x, getRandomGaps(maxTimeGap), getSpatialPos(noiseProb), getSpatialPos(spatialProb));
}

int[] processRow(int[] row, boolean[] noise, boolean[] spatial) {
  int[] result = new int[row.length];
  for(int i=0;i<row.length;i++) {
    result[i] = row[i];
    if(spatial[i]) result[i] = -1;
    else if(noise[i]) result[i] = 1-result[i];
  }
  return result;
}


void drawCA(CA automata, int[] ic, int x, int[] gaps, boolean[][] noise, boolean[][] spatial) {
  int[] row = ic.clone();

  for (int i =0; i<time_len; i++) {
    drawLine(x, i, processRow(row, noise[i], spatial[i]));
    
    for (int j=0; j<gaps[i]; j++) {
      row=automata.eval(row, alpha);
    }
    
    row=automata.eval(row, alpha);
  }
}

void drawLine(int x_base, int l, int a[]) {
  for (int i=0; i<a.length; i++) {
    float x = a[i] == -1 ? 0.5 : float(a[i]);
    
    if(x > 0 && x < 1.0) {
      fill(128);
    } else {
      fill(256*(1-x));
    }
      
    rect(x_base + i*box_size, l*box_size, box_size, box_size);
  }
}

void fillRandom(int a[], int src[]) {
  
  for (int i=0; i<a.length; i++) {
    a[i] = random(1.0) > 0.5 ? 1 : 0;
  }
  
  if(src!=null && src.length>0) {
    int l = min(a.length, src.length);
    for(int i=0;i<l;i++) {
      a[i] = src[i];
    }
  }
  
  
}

int pow(int x, int y) {
  int result = 1;
  for (int i=0; i<y; i++) {
    result*=x;
  }
  return result;
}

class CA {
  private int[] lut;
  private int radius;
 
  public CA(int radius, int ruleNum) {
    this.radius = radius;
    lut = getLut(ruleNum);
  }

  public CA(int radius, int[] lut) {
    this.radius = radius;
    this.lut = lut.clone();
  }

  private int[] getLut(int ruleNum) {
    int r = ruleNum;
    int[] result = new int[pow(2, 2*radius+1)];
    for (int i=0; i<result.length; i++) {
      result[i] = r % 2;
      r = r >> 1;
    }
    return result;
  }

  private int roll(int x, int max) {
    if (x>=0 && x<max) { return x; }
    if (x<0) { return roll(x+max, max); }
    return roll(x-max, max);
  }

  private int lutPos(int[] row, int pos) {
    int p = 1;
    int result = 0;
    for (int i = radius; i>=-1*radius; i--) {
      result += p * row[roll(pos+i, row.length)];
      p*=2;
    }
    return  result;
  }

  public int[] eval(int[] row, float alpha) {
    int[] result = new int[row.length];
    for (int i=0; i<row.length; i++) {
      result[i] = random(1.0) < alpha ? lut[lutPos(row, i)] : row[i];
    }
    return result;
  }
}
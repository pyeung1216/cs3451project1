// CS 3451 Spring 2013 Homework 1 Stub
// Dummy routines for matrix transformations.
// These are for you to write!
gtMatrix[] stack;
gtVertex[] vertices;
gtMatrix view;
int vertexCount;
float right, left, top, bottom, nnear, ffar, fovy;
boolean orth, persp;

void gtInitialize() {
  vertices = new gtVertex[2];
  stack = new gtMatrix[10];
  stack[0] = new gtMatrix();
}

void gtPushMatrix() {
  for(int i = 9; i > 0; i--)  {
    stack[i] = stack[i-1];
  }
}

void gtPopMatrix() {
  if(stack[1] == null)  {  
    print("Cannot pop, only one element in stack");
    return;
  }
  
  for(int i = 1; i < 10; i++)  {
    stack[i-1] = stack[i];
  }
  stack[9] = null;
}

void gtTranslate(float tx, float ty, float tz) {
  gtMatrix translate = new gtMatrix(new float[][]{
    {1,0,0,tx},
    {0,1,0,ty},
    {0,0,1,tz},
    {0,0,0,1}});
    
  stack[0] = stack[0].mult(translate);
}

void gtScale(float sx, float sy, float sz) {
  gtMatrix scale = new gtMatrix(new float[][]{
    {sx,0,0,0},
    {0,sy,0,0},
    {0,0,sz,0},
    {0,0,0,1}});
    
  stack[0] = stack[0].mult(scale);
}

void gtRotate(float angle, float ax, float ay, float az) {
  float nx, ny, nz;
  if(ax == 0)  {
    nx = 1;
    ny = 0;
    nz = 0;
  }
  else  {
    nx = 0;
    ny = 1;
    nz = 0;
  }
  
  float magA = sqrt(pow(ax,2)+pow(ay,2)+pow(az,2));
  float axNorm = ax/magA;
  float ayNorm = ay/magA;  
  float azNorm = az/magA;
  
  float bx = ayNorm*nz - ny*azNorm;
  float by = azNorm*nx - nz*axNorm;
  float bz = axNorm*ny - nx*ayNorm;
  
  float magB = sqrt(pow(bx,2)+pow(by,2)+pow(bz,2));
  float bxNorm = bx/magB;
  float byNorm = by/magB;  
  float bzNorm = bz/magB;
  
  float cx = ayNorm*bzNorm - byNorm*azNorm;
  float cy = azNorm*bxNorm - bzNorm*axNorm;
  float cz = axNorm*byNorm - bxNorm*ayNorm;
  
  gtMatrix rotate1 = new gtMatrix(new float[][]{
    {axNorm,ayNorm,azNorm,0},
    {bxNorm,byNorm,bzNorm,0},
    {cx,cy,cz,0},
    {0,0,0,1}});

  gtMatrix rotate2 = new gtMatrix(new float[][]{
    {1,0,0,0},
    {0,cos(angle/180*PI),-sin(angle/180*PI),0},
    {0,sin(angle/180*PI),cos(angle/180*PI),0},
    {0,0,0,1}});
    
  gtMatrix rotate3 = new gtMatrix(new float[][]{
    {axNorm,bxNorm,cx,0},
    {ayNorm,byNorm,cy,0},
    {azNorm,bzNorm,cz,0},
    {0,0,0,1}});
    
  gtMatrix rotate = rotate3.mult(rotate2).mult(rotate1);
  
  stack[0] = stack[0].mult(rotate);
}

void gtPerspective(float fovy, float nnear, float ffar) {
  this.fovy = fovy;
  this.nnear = -1*nnear;
  this.ffar = -1*ffar;
  orth = false;
  persp = true;
}

void gtOrtho(float left, float right, float bottom, float top, float nnear, float ffar) {
  this.left = left;
  this.right = right;
  this.bottom = bottom;
  this.top = top;
  this.nnear = -1*nnear;
  this.ffar = -1*ffar;
  orth = true;
  persp = false;
}

void gtBeginShape(int type) {
  vertexCount = 0;
}

void gtEndShape() {

}

void gtVertex(float x, float y, float z) {
  gtVertex vertex = new gtVertex(new float[][]{{x},{y},{z},{1}});
  vertex = new gtVertex(stack[0].mult(vertex.matrix));
  
  vertices[vertexCount] = vertex;
  if(vertexCount == 0)  {
    vertexCount = 1;
  }
  else  {
    xyz p0 = new xyz(vertices[0].vertex[0][0], vertices[0].vertex[1][0], vertices[0].vertex[2][0]);
    xyz p1 = new xyz(vertices[1].vertex[0][0], vertices[1].vertex[1][0], vertices[1].vertex[2][0]);
    if((near_far_clip(nnear, ffar, p0, p1)) > 0)  {
      vertices[0] = new gtVertex(new float[][]   {
        {p0.x},
        {p0.y},
        {p0.z},
        {1}});
      vertices[1] = new gtVertex(new float[][]   {
        {p1.x},
        {p1.y},
        {p1.z},
        {1}});   
      if(orth == true)  {
        vertices[0].vertex[0][0] = (vertices[0].vertex[0][0] - left) / (right - left) * width;
        vertices[0].vertex[1][0] = (vertices[0].vertex[1][0] - bottom) / (top - bottom) * height;
        vertices[1].vertex[0][0] = (vertices[1].vertex[0][0] - left) / (right - left) * width;
        vertices[1].vertex[1][0] = (vertices[1].vertex[1][0] - bottom) / (top - bottom) * height;
      }
      if(persp == true)  {
        float k = nnear * (fovy / 180 * PI / 2);
        vertices[0].vertex[0][0] = ((nnear*vertices[0].vertex[0][0]/Math.abs(vertices[0].vertex[2][0])) + k) * width / 2 / k;
        vertices[0].vertex[1][0] = ((nnear*vertices[0].vertex[1][0]/Math.abs(vertices[0].vertex[2][0])) + k) * height / 2 / k;
        vertices[1].vertex[0][0] = ((nnear*vertices[1].vertex[0][0]/Math.abs(vertices[1].vertex[2][0])) + k) * width / 2 / k;
        vertices[1].vertex[1][0] = ((nnear*vertices[1].vertex[1][0]/Math.abs(vertices[1].vertex[2][0])) + k) * height / 2 / k;
      }
      draw_line(vertices[0].vertex[0][0], vertices[0].vertex[1][0], vertices[1].vertex[0][0], vertices[1].vertex[1][0]);
    }
    vertexCount = 0;
  }
}

class gtMatrix  {
  float[][] values;
  
  gtMatrix()  {
    values = new float[][]
    {{1,0,0,0},
    {0,1,0,0},
    {0,0,1,0},
    {0,0,0,1}};
  }
  
  gtMatrix(float[][] m)  {
    values = m;
  }
  
  gtMatrix mult(gtMatrix m)  {
    if(values[0].length != m.values.length)  {
      print("Incompatible numbers");
      return null;
    }
    
    float[][] ret = new float[values.length][m.values[0].length];
    for(int i = 0; i < ret.length; i++ )  {
      for(int j = 0; j < ret[0].length; j++ )  {
        for(int k = 0; k < m.values.length; k++ )  {
          ret[i][j] += values[i][k] * m.values[k][j];
        }
      }
    }
   return new gtMatrix(ret);
  }
  
  String toString()  {
    String ret = "";
    for(int i = 0; i < values.length; i++)  {
      for(int j = 0; j < values[0].length; j++)  {
        ret += values[i][j] + "\t";
      }
      ret += "\n";
    }
    return ret;       
  }
  
}

class gtVertex {
  gtMatrix matrix;
  float[][] vertex;
  
  gtVertex() {
    matrix = new gtMatrix(new float[][]{{0},{0},{0},{1}});
    vertex = matrix.values;
  }
  
  gtVertex(float[][] v)  {
    matrix = new gtMatrix(v);
    vertex = v;
  }
  
  gtVertex(gtMatrix v)  {
    matrix = v;
    vertex = matrix.values;
  }
}


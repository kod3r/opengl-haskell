#version 110

uniform sampler2D image;

varying vec2 point;
varying vec2 p0;
varying vec2 p1;
varying vec2 p2;
varying vec2 av;
varying vec2 bv;
varying vec2 cv;
varying vec2 dv;
varying float collinear;

float cubeRoot(float a) {
  if(a >= 0.0)
    return pow(a, 1.0/3.0);
  else
    return -pow(-a, 1.0/3.0);
}

vec2 curve(float t) {
  float a = 1.0-t;
  return ((a*a)*p0) + (2.0*(1.0-t)*t*p1) + ((t*t)*p2);
}

float distance(vec2 a, vec2 b) {
  return length(a - b);
}

vec4 grey(float c) {
  return vec4(c, c, c, 1.0);
}

float antiAlias(float root, float width) {
  return smoothstep(0.0, 0.007, width - distance(point, curve(root)));
}

bool withinStroke(float root, float strokeWidth) {
  return root >= 0.0 && root <= 1.0 && distance(point, curve(root)) <= strokeWidth;
}

float add(vec2 a) {
  return a.x + a.y;
}

float solveForThreeRealRoots(float a, float b, float c, float d, float g, float f, float h) {
  float i  = sqrt(((g*g) / 4.0) - h);
  float j  = cubeRoot(i);
  float k  = acos(-(g / (2.0*i)));
  float l  = j * (-1.0);
  float m  = cos(k / 3.0);
  float n  = sqrt(3.0 * sin(k / 3.0));
  float p  = (b / (3.0*a)) * (-1.0);

  float x1   = (2.0*j) * (cos(k / 3.0)) + p;
  float x2   = l * (m + n) + p;
  float x3   = l * (m - n) + p;
  float temp = x1;

  if(distance(point, curve(x1)) < distance(point, curve(x2)) && distance(point, curve(x1)) < distance(point, curve(x3)))
    return x1;
  else if(distance(point, curve(x2)) < distance(point, curve(x3)))
    return x2;
  else
    return x3;
}

float solveForOneRealRoot(float a, float b, float c, float d, float g, float f, float h) {
  float r = -(g/2.0) + sqrt(h);
  float s = cubeRoot(r);
  float t = -(g/2.0) - sqrt(h);
  float u = cubeRoot(t);
  return (s + u) - (b / (3.0*a));
}

float solveForEqualRoots(float a, float b, float c, float d, float g, float f, float h) {
  return cubeRoot((d / a) * (-1.0));
}

float cubicRoot(float a, float b, float c, float d) {
  float f = ((3.0*a*c) - (b*b)) / (3.0*a*a);
  float g = ((2.0*b*b*b) - (9.0*a*b*c) + (27.0*a*a*d)) / (27.0*a*a*a);
  float h = ((g*g) / 4.0) + ((f*f*f) / 27.0);
  if(h < 0.0)
    return solveForThreeRealRoots(a, b, c, d, g, f, h);
  else if(h > 0.0)
    return solveForOneRealRoot(a, b, c, d, g, f, h);
  else
    return solveForEqualRoots(a, b, c, d, g, f, h);
}

float alpha(float width, float distanceFromEdge) {
  return smoothstep(0.0, 0.005, width - distanceFromEdge);
}

void bezier(float width) {
  float a     = add(av);
  float b     = add(bv);
  float c     = add(cv);
  float d     = add(dv);

  float root = cubicRoot(a, b, c, d);

  if(withinStroke(root, width)) {
    float x = p0.x + (point.x - curve(root).x);
    gl_FragColor = texture2D(image, vec2(x, root));
    gl_FragColor.a = alpha(width, distance(point, curve(root)));
  } else {
    discard;
  }
}

void line(float width) {
  vec2 unit = normalize(p2 - p0);
  float distance = length((p0 - point) - (dot(p0 - point, unit) * unit));
  float sign     = 1.0;

  if(point.x < p0.x) sign = -1.0;

  if(distance <= width) {
    gl_FragColor = texture2D(image, vec2(p0.x + (distance * sign), point.y));
    gl_FragColor.a = alpha(width, distance);
  } else {
    discard;
  }
}

void main(void) {
  float width = 0.006;
  if(collinear == 1.0)
    line(width);
  else
    bezier(width);
}

#version 110
#define DELTA 0.03

uniform vec2 c0;
uniform vec2 c1;
uniform vec2 c2;
uniform float force;

attribute vec4  position;
attribute float index;

varying vec2 point;
varying vec2 p0;
varying vec2 p1;
varying vec2 p2;
varying vec2 av;
varying vec2 bv;
varying vec2 cv;
varying vec2 dv;
varying float collinear;

bool areCollinear(vec2 a, vec2 b, vec2 c) {
  return abs(a.x*(b.y - c.y) + b.x*(c.y - a.y) + c.x*(a.y - b.y)) <= DELTA;
}

float rand(vec2 co){
  return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

void main(void) {
  p0    = c0;
  p1    = c1;
  p2    = c2;

  p2.x = p2.x + (rand(p0)/10.0) + (rand(p2)*force);

  vec2 alpha = p0 - (2.0 * p1) + p2;
  vec2 beta  = 2.0 * (p1 - p0);

  float width = 0.008;

  float minx = min(p2.x, min(p0.x - width, p1.x));
  float maxx = max(p2.x, max(p0.x + width, p1.x));
  float miny = min(p2.y, min(p0.y - width, p1.y));
  float maxy = max(p2.y, max(p0.y + width, p1.y));

  if(index == 0.0)
    point = vec2(minx, miny);
  else if(index == 1.0)
    point = vec2(maxx, miny);
  else if(index == 2.0)
    point = vec2(maxx, maxy);
  else if(index == 3.0)
    point = vec2(minx, maxy);

  gl_Position = vec4(point, 0.0, 1.0);
  gl_Position.z = -p0.x;

  av    = -2.0 * (alpha * alpha);
  bv    = -3.0 * (alpha * beta);
  cv    = (2.0 * alpha * point) - (2.0 * alpha * p0) - (beta * beta);
  dv    = beta * (point - p0);

  if(areCollinear(p0, p1, p2))
    collinear = 1.0;
  else
    collinear = 0.0;
}

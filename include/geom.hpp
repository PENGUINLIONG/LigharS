#pragma once
#include <cmath>
#include <cassert>
#include <algorithm>

#ifndef M_PI
#define M_PI   3.14159265358979323846264338327950288
#endif

namespace gpumagi {

using u8 = uint8_t;
using u32 = unsigned;
using f32 = float;



struct Dim {
  u32 x, y, z;
};



struct Point {
  f32 x, y, z;
};
inline Point make_pt(f32 x, f32 y, f32 z) {
  return Point { x, y, z };
}

struct Vector {
  f32 x, y, z;
};
inline Vector make_vec(f32 x, f32 y, f32 z) {
  return Vector { x, y, z };
}

inline Vector operator+(const Vector& a, const Vector& b) {
  return { a.x + b.x, a.y + b.y, a.z + b.z };
}
inline Vector operator-(const Vector& a, const Vector& b) {
  return { a.x - b.x, a.y - b.y, a.z - b.z };
}
inline Vector operator*(const Vector& a, f32 b) {
  return { a.x * b, a.y * b, a.z * b };
}
inline Vector operator*(f32 a, const Vector& b) {
  return { a * b.x, a * b.y, a * b.z };
}
inline Vector operator/(const Vector& a, f32 b) {
  return { a.x / b, a.y / b, a.z / b };
}

inline Point operator+(const Point& a, const Vector& b) {
  return { a.x + b.x, a.y + b.y, a.z + b.z };
}
inline Point operator-(const Point& a, const Vector& b) {
  return { a.x - b.x, a.y - b.y, a.z - b.z };
}

inline Vector operator-(const Point& a, const Point& b) {
  return { a.x - b.x, a.y - b.y, a.z - b.z };
}

inline f32 dot(const Vector& a, const Vector& b) {
  return a.x * b.x + a.y * b.y + a.z * b.z;
}
inline Vector cross(const Vector& a, const Vector& b) {
  return Vector {
    a.y * b.z - a.z * b.y,
    a.z * b.x - a.x * b.z,
    a.x * b.y - a.y * b.x,
  };
}
inline f32 magnitude(const Vector& a) {
  return std::sqrt(dot(a, a));
}
inline Vector normalize(const Vector& a) {
  return a / magnitude(a);
}
inline Point min(const Point& a, const Point& b) {
  return Point {
    std::fmin(a.x, b.x),
    std::fmin(a.y, b.y),
    std::fmin(a.z, b.z),
  };
}
inline Point max(const Point& a, const Point& b) {
  return Point {
    std::fmax(a.x, b.x),
    std::fmax(a.y, b.y),
    std::fmax(a.z, b.z),
  };
}



struct Ray {
  Point o;
  Vector v;
};
inline Ray make_ray(const Point& o, const Vector& v) {
  return Ray { o, v };
}



struct Triangle {
  Point o;
  Vector u;
  Vector v;
};
inline Triangle make_tri(const Point& a, const Point& b, const Point& c) {
  Vector u = b - a;
  Vector v = c - a;
  return Triangle { a, u, v };
}



struct Aabb {
  Point min_pt;
  Point max_pt;
};

// for given triangle, it will return the Aabb
inline Aabb make_aabb(const Triangle& t) {
  // t.o is point a
  Point b = t.o + t.u; // add point and vector to get the other points of the triangle
  Point c = t.o + t.v;
  Point max_pt {
    std::fmax(std::fmax(t.o.x, b.x), c.x),
    std::fmax(std::fmax(t.o.y, b.y), c.y),
    std::fmax(std::fmax(t.o.z, b.z), c.z),
  };
  Point min_pt {
    std::fmin(std::fmin(t.o.x, b.x), c.x),
    std::fmin(std::fmin(t.o.y, b.y), c.y),
    std::fmin(std::fmin(t.o.z, b.z), c.z),
  };
  return Aabb { max_pt, min_pt };
}
// true if 2 AABBs are intersecting
inline bool intersect(const Aabb& a, const Aabb& b) {
  return
    (b.min_pt.x <= a.min_pt.x && a.min_pt.x <= b.max_pt.x) ||
    (b.min_pt.x <= a.max_pt.x && a.max_pt.x <= b.max_pt.x) ||
    (a.min_pt.x <= b.min_pt.x && b.min_pt.x <= a.max_pt.x) ||
    (a.min_pt.x <= b.max_pt.x && b.max_pt.x <= a.max_pt.x) ||
    (b.min_pt.y <= a.min_pt.y && a.min_pt.y <= b.max_pt.y) ||
    (b.min_pt.y <= a.max_pt.y && a.max_pt.y <= b.max_pt.y) ||
    (a.min_pt.y <= b.min_pt.y && b.min_pt.y <= a.max_pt.y) ||
    (a.min_pt.y <= b.max_pt.y && b.max_pt.y <= a.max_pt.y) ||
    (b.min_pt.z <= a.min_pt.z && a.min_pt.z <= b.max_pt.z) ||
    (b.min_pt.z <= a.max_pt.z && a.max_pt.z <= b.max_pt.z) ||
    (a.min_pt.z <= b.min_pt.z && b.min_pt.z <= a.max_pt.z) ||
    (a.min_pt.z <= b.max_pt.z && b.max_pt.z <= a.max_pt.z);
}
inline Aabb extend(const Aabb& a, const Aabb& b) {
  return Aabb {
    min(a.min_pt, b.min_pt),
    max(a.max_pt, b.max_pt),
  };
}



struct TransformRow {
  float x, y, z, w;
};
inline float dot(const TransformRow& a, const Vector& b) {
  return a.x * b.x + a.y * b.y + a.z * b.z;
}
inline float dot(const TransformRow& a, const Point& b) {
  return a.x * b.x + a.y * b.y + a.z * b.z + a.w;
}

struct Transform {
  union {
    float mat[12];
    struct { TransformRow r1, r2, r3; };
    TransformRow rows[3];
  };

  Transform() : mat{ 1,0,0,0, 0,1,0,0, 0,0,1,0 } {}
  Transform(TransformRow r1, TransformRow r2, TransformRow r3) : r1(r1), r2(r2), r3(r3) {}
  Transform(float a, float b, float c, float d,
            float e, float f, float g, float h,
            float i, float j, float k, float l) : mat{ a,b,c,d,e,f,g,h,i,j,k,l } {}
  Transform(float mat[12]) { mat = mat; }
  Transform(const Transform&) = default;
  Transform(Transform&&) = default;
  Transform& operator=(const Transform&) = default;
  Transform& operator=(Transform&&) = default;

  inline Transform operator*(const Transform& rhs) const {
    Vector c1 { rhs.mat[0], rhs.mat[4], rhs.mat[8] };
    Vector c2 { rhs.mat[1], rhs.mat[5], rhs.mat[9] };
    Vector c3 { rhs.mat[2], rhs.mat[6], rhs.mat[10] };
    Point c4 { rhs.mat[3], rhs.mat[7], rhs.mat[11] };
    return Transform{
      dot(r1, c1), dot(r1, c2), dot(r1, c3), dot(r1, c4),
      dot(r2, c1), dot(r2, c2), dot(r2, c3), dot(r2, c4),
      dot(r3, c1), dot(r3, c2), dot(r3, c3), dot(r3, c4),
    };
  }
  inline Vector apply_vec(const Vector& rhs) const {
    return Vector {
      dot(rows[0], rhs),
      dot(rows[1], rhs),
      dot(rows[2], rhs),
    };
  }
  inline Point apply_pt(const Point& rhs) const {
    return Point {
      dot(rows[0], rhs),
      dot(rows[1], rhs),
      dot(rows[2], rhs)
    };
  }

  inline Transform scale(float x, float y, float z) const {
    return Transform { x,0,0,0, 0,y,0,0, 0,0,z,0 } * (*this);
  }
  inline Transform scale(Vector v) const {
    return scale(v.x, v.y, v.z);
  }
  inline Transform translate(float x, float y, float z) const {
    return Transform { 1,0,0,x, 0,1,0,y, 0,0,1,z } * (*this);
  }
  inline Transform translate(Vector v) const {
    return translate(v.x, v.y, v.z);
  }
  inline Transform rotate(float x, float y, float z, float rad) const {
    float sin = std::sinf(rad);
    float cos = std::cosf(rad);
    float rcos = 1.0f - cos;
    return Transform {
        cos + rcos * x * x, rcos * x * y - sin * z, rcos * x * z + sin * y, 0,
        rcos * y * x + sin * z, cos + rcos * y * y, rcos * y * z - sin * x, 0,
        rcos * z * x - sin * y, rcos * z * y + sin * x, cos + rcos * z * z, 0,
    } *(*this);
  }
  inline Transform rotate(Vector axis, float rad) const {
    return rotate(axis.x, axis.y, axis.z, rad);
  }
  inline Transform rotate_vec2vec(Vector from, Vector to) const {
    auto axis = normalize(cross(from, to));
    auto rad = std::acos(dot(from, to));
    return rotate(axis, rad);
  }
  inline Transform inverse() const {
    float det {
      r1.x * (r2.y * r3.z - r2.z * r3.y) -
      r2.x * (r1.y * r3.z - r1.z * r3.y) +
      r3.x * (r1.y * r2.z - r1.z * r2.y)
    };
    TransformRow r1_ {
      (r2.y * r3.z - r3.y * r2.z) / det,
      (r1.z * r3.y - r1.y * r3.z) / det,
      (r1.y * r2.z - r1.z * r2.y) / det,
      (-r1.y * r2.z * r3.w - r1.z * r2.w * r3.y - r1.w * r2.y * r3.z +
        r1.w * r2.z * r3.y + r1.z * r2.y * r3.w + r1.y * r2.w * r3.z) / det,
    };
    TransformRow r2_ {
      (r2.z * r3.x - r2.x * r3.z) / det,
      (r1.x * r3.z - r1.z * r3.x) / det,
      (r2.x * r1.z - r1.x * r2.z) / det,
      (r1.x * r2.z * r3.w + r1.z * r2.w * r3.x + r1.w * r2.x * r3.z -
        r1.w * r2.z * r3.x - r1.z * r2.x * r3.w - r1.x * r2.w * r3.z) / det,
    };
    TransformRow r3_ {
      (r2.x * r3.y - r2.y * r3.x) / det,
      (r1.y * r3.x - r1.x * r3.y) / det,
      (r1.x * r2.y - r2.x * r1.y) / det,
      (-r1.x * r2.y * r3.w - r1.y * r2.w * r3.x - r1.w * r2.x * r3.y +
        r1.w * r2.y * r3.x + r1.y * r2.x * r3.w + r1.x * r2.w * r3.y) / det,
    };
    return Transform { r1_, r2_, r3_ };
  }
};
constexpr float deg2rad(float deg) { return deg / 180.0 * M_PI; }
constexpr float rad2deg(float deg) { return deg / M_PI * 180.0; }



struct Barycentric {
  f32 u, v;
};
Barycentric make_bary(const Point& p_, const Triangle& tri) {
  Vector a = tri.u;
  Vector b = tri.v;
  Vector p = p_ - tri.o;
  // See: https://gamedev.stackexchange.com/questions/23743/whats-the-most-efficient-way-to-find-barycentric-coordinates
  f32 d00 = dot(a, a);
  f32 d01 = dot(a, b);
  f32 d11 = dot(b, b);
  f32 d20 = dot(p, a);
  f32 d21 = dot(p, b);
  f32 denom = d00 * d11 - d01 * d01;
  f32 u = (d11 * d20 - d01 * d21) / denom;
  f32 v = (d00 * d21 - d01 * d20) / denom;

  return Barycentric { u, v };
}
inline bool is_valid_bary(const Barycentric& bary) {
  return bary.u >= 0 && bary.v >= 0 && bary.u + bary.v <= 1;
}


enum HitKind {
  L_HIT_KIND_NONE  = 0,
  L_HIT_KIND_FRONT = 1,
  L_HIT_KIND_BACK  = 2,
};
struct TriangleHit {
  Barycentric bary;
  HitKind kind;
  f32 t;
};
// Returns positive ray time if the ray intersects the triangle plane at front;
// negative ray time if the ray intersects the triangle plane at back; NaN if
// the ray doesn't intersect the triangle.
bool ray_cast_tri(const Ray& ray, const Triangle& tri, TriangleHit& hit) {
  Vector n = normalize(cross(tri.u, tri.v));
  // Distance from the ray origin to the triangle plane.
  f32 r1 = dot(tri.o - ray.o, n);
  // Length of projection of the ray direction vector in normal direction.
  f32 r2 = dot(ray.v, n);
  if (r1 * r2 <= 0.0) { return false; }
  // Distance from the ray origin to the triangle.
  f32 t = r1 / r2;

  Point p = ray.o + ray.v * t;
  Barycentric bary = make_bary(p, tri);
  if (!is_valid_bary(bary)) { return false; }
  HitKind kind = r2 < 0.0 ? L_HIT_KIND_FRONT : L_HIT_KIND_BACK;

  hit.bary = bary;
  hit.kind = kind;
  hit.t = t;
  return true;
}
struct AabbHit {
  HitKind kind;
  f32 t;
};
bool ray_cast_aabb(const Ray& ray, const Aabb& aabb, AabbHit& hit) {
  f32 t1 = (aabb.min_pt.x - ray.o.x) / ray.v.x;
  f32 t2 = (aabb.max_pt.x - ray.o.x) / ray.v.x;
  f32 t4 = (aabb.max_pt.y - ray.o.y) / ray.v.y;
  f32 t3 = (aabb.min_pt.y - ray.o.y) / ray.v.y;
  f32 t5 = (aabb.min_pt.z - ray.o.z) / ray.v.z;
  f32 t6 = (aabb.max_pt.z - ray.o.z) / ray.v.z;

  f32 tmin = std::fmax(std::fmax(std::fmin(t1, t2), std::fmin(t3, t4)), std::fmin(t5, t6));
  f32 tmax = std::fmin(std::fmin(std::fmax(t1, t2), std::fmax(t3, t4)), std::fmax(t5, t6));

  if (tmax < 0 || tmin > tmax) {
    return false;
  } else if (tmin < 0) {
    hit.t = tmax;
    hit.kind = L_HIT_KIND_BACK;
    return true;
  } else {
    hit.t = tmin;
    hit.kind = L_HIT_KIND_FRONT;
    return true;
  }
}




} // namespace gpumagi

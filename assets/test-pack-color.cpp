typedef float f32;
typedef unsigned int u32;

struct Vec3 {
  f32 x, y, z;
};
Vec3 operator+(const Vec3& a, const Vec3& b) {
  return { a.x + b.x, a.y + b.y, a.z + b.z };
}
Vec3 operator-(const Vec3& a, const Vec3& b) {
  return { a.x - b.x, a.y - b.y, a.z - b.z };
}
Vec3 operator-(const Vec3& a) {
  return { -a.x, -a.y, -a.z };
}
Vec3 operator*(const Vec3& a, f32 b) {
  return { a.x * b, a.y * b, a.z * b };
}
Vec3 operator*(f32 a, const Vec3& b) {
  return { a * b.x, a * b.y, a * b.z };
}
Vec3 operator*(const Vec3& a, const Vec3& b) {
  return { a.x * b.x, a.y * b.y, a.z * b.z };
}
Vec3 operator/(const Vec3& a, f32 b) {
  return { a.x / b, a.y / b, a.z / b };
}
Vec3 operator/(const Vec3& a, const Vec3& b) {
  return { a.x / b.x, a.y / b.y, a.z / b.z };
}

f32 max(f32 a, f32 b) {
  return a < b ? b : a;
}
f32 min(f32 a, f32 b) {
  return a < b ? a : b;
}

Vec3 clamp(const Vec3& c, f32 mn, f32 mx) {
  return {
    max(min(c.x, mx), mn),
    max(min(c.y, mx), mn),
    max(min(c.z, mx), mn),
  };
}
u32 pack_unorm4_rgba(const Vec3& x) {
  Vec3 clamped = clamp(x, 0.0f, 1.0f);
  return ((u32)(clamped.x * 255.999f)) |
    ((u32)(clamped.y * 255.999f) << 8) |
    ((u32)(clamped.z * 255.999f) << 16) |
    0xff000000;
}

extern "C" u32 test_pack_unorm4_rgba(u32 r, u32 g, u32 b) {
  return pack_unorm4_rgba(Vec3 { f32(r), f32(g), f32(b) });
}

extern "C" u32 test_clamp(u32 i) {
  return (u32)clamp(Vec3{ f32(i), f32(i), f32(i) }, 50.0f, 100.0f).x;
}
extern "C" u32 test_min(u32 a, u32 b) {
  return min(f32(a), f32(b));
}
extern "C" u32 test_max(u32 a, u32 b) {
  return max(f32(a), f32(b));
}

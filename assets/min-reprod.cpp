typedef float f32;
typedef unsigned int u32;

f32 random() {
  static u32 seed = 0;
  seed *= 0x5deece66d;
  seed += 0xb;
  u32 rv = ((0b01111110 << 23) | (seed & 0x007fffff));
  return *((f32*)((void*)(&rv)));
}

f32 sin(f32 x) {
  f32 x2 = x * x;

  f32 coe_x1 = 1.0f * x;
  f32 coe_x3 = x2 / 6.0f * x;
  f32 coe_x5 = coe_x3 / 20.0f * x2;

  return coe_x1 - coe_x3 + coe_x5;
}
f32 cos(f32 x) {
  f32 x2 = x * x;

  f32 coe_x2 = x2 / 4.0f;
  f32 coe_x4 = coe_x2 / 6.0f * x2;
  f32 coe_x6 = coe_x4 / 30.0f * x2;
  return 1.0f - coe_x2 + coe_x4 - coe_x6;
}
f32 sqrt(f32 x) {
  f32 xhalf = 0.5f * x;
  int i = *(int*)&x;
  i = 0x5f3759df - (i >> 1);
  x = *(f32*)&i;
  x = x * (1.5f - xhalf * x * x);
  return 1 / x;
}
// FIXME: bxx series instruction are malfunctioning.
f32 max(f32 a, f32 b) {
  return a > b ? a : b;
}
f32 min(f32 a, f32 b) {
  return a < b ? a : b;
}


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
f32 dot(const Vec3& a, const Vec3& b) {
  return a.x * b.x + a.y * b.y + a.z * b.z;
}
Vec3 cross(const Vec3& a, const Vec3& b) {
  return Vec3 {
    a.y * b.z - a.z * b.y,
    a.z * b.x - a.x * b.z,
    a.x * b.y - a.y * b.x,
  };
}
f32 magnitude(const Vec3& a) {
  return sqrt(dot(a, a));
}
Vec3 normalized(const Vec3& a) {
  return a / magnitude(a);
}
Vec3 clamp(const Vec3& c, f32 mn, f32 mx) {
  return {
    max(min(c.x, mx), mn),
    max(min(c.y, mx), mn),
    max(min(c.z, mx), mn),
  };
}
Vec3 reflect(Vec3 i, Vec3 n) {
  return 2.0f * n * dot(n, i) - i;
}
u32 pack_unorm4_rgba(const Vec3& x) {
  Vec3 clamped = clamp(x, 0.0f, 1.0f);
  return ((u32)(clamped.x * 255.999f)) |
    ((u32)(clamped.y * 255.999f) << 8) |
    ((u32)(clamped.z * 255.999f) << 16) |
    0xff000000;
}

struct Ray {
  Vec3 o, v;
};
struct Triangle {
  Vec3 a, b, c;
};
struct Material {
  Vec3 albedo, emit;
};

Triangle tris[] {
  Triangle { Vec3 { -0.35355338, -0.41161162, 1.5883884 }, Vec3 { -0.70710677, -0.16161163, 1.3383884 }, Vec3 { -0.70710677, 0.19194174, 1.6919417 } },
  Triangle { Vec3 { -0.35355338, -0.41161162, 1.5883884 }, Vec3 { -0.70710677, 0.19194174, 1.6919417 }, Vec3 { -0.35355338, -0.058058247, 1.9419417 } },
  Triangle { Vec3 { 0.0, -0.16161165, 1.3383884 }, Vec3 { -0.35355338, -0.41161162, 1.5883884 }, Vec3 { -0.35355338, -0.058058247, 1.9419417 } },
  Triangle { Vec3 { 0.0, -0.16161165, 1.3383884 }, Vec3 { -0.35355338, -0.058058247, 1.9419417 }, Vec3 { 0.0, 0.19194172, 1.6919417 } },
  Triangle { Vec3 { -0.35355338, 0.08838834, 1.0883884 }, Vec3 { 0.0, -0.16161165, 1.3383884 }, Vec3 { 0.0, 0.19194172, 1.6919417 } },
  Triangle { Vec3 { -0.35355338, 0.08838834, 1.0883884 }, Vec3 { 0.0, 0.19194172, 1.6919417 }, Vec3 { -0.35355338, 0.44194174, 1.4419417 } },
  Triangle { Vec3 { -0.70710677, -0.16161163, 1.3383884 }, Vec3 { -0.35355338, 0.08838834, 1.0883884 }, Vec3 { -0.35355338, 0.44194174, 1.4419417 } },
  Triangle { Vec3 { -0.70710677, -0.16161163, 1.3383884 }, Vec3 { -0.35355338, 0.44194174, 1.4419417 }, Vec3 { -0.70710677, 0.19194174, 1.6919417 } },
  Triangle { Vec3 { -0.70710677, 0.19194174, 1.6919417 }, Vec3 { -0.35355338, 0.44194174, 1.4419417 }, Vec3 { 0.0, 0.19194172, 1.6919417 } },
  Triangle { Vec3 { -0.70710677, 0.19194174, 1.6919417 }, Vec3 { 0.0, 0.19194172, 1.6919417 }, Vec3 { -0.35355338, -0.058058247, 1.9419417 } },
  Triangle { Vec3 { -0.70710677, -0.16161163, 1.3383884 }, Vec3 { -0.35355338, -0.41161162, 1.5883884 }, Vec3 { 0.0, -0.16161165, 1.3383884 } },
  Triangle { Vec3 { -0.70710677, -0.16161163, 1.3383884 }, Vec3 { 0.0, -0.16161165, 1.3383884 }, Vec3 { -0.35355338, 0.08838834, 1.0883884 } },
  Triangle { Vec3 { 0.32683605, -0.6249085, 0.5085789 }, Vec3 { -0.07937503, -0.3644755, 0.37755537 }, Vec3 { -0.008646786, -0.058439553, 0.76657915 } },
  Triangle { Vec3 { 0.32683605, -0.6249085, 0.5085789 }, Vec3 { -0.008646786, -0.058439553, 0.76657915 }, Vec3 { 0.3975643, -0.31887257, 0.8976027 } },
  Triangle { Vec3 { 0.60966116, -0.3273911, 0.22310853 }, Vec3 { 0.32683605, -0.6249085, 0.5085789 }, Vec3 { 0.3975643, -0.31887257, 0.8976027 } },
  Triangle { Vec3 { 0.60966116, -0.3273911, 0.22310853 }, Vec3 { 0.3975643, -0.31887257, 0.8976027 }, Vec3 { 0.6803894, -0.021355152, 0.6121323 } },
  Triangle { Vec3 { 0.20345007, -0.06695807, 0.092085004 }, Vec3 { 0.60966116, -0.3273911, 0.22310853 }, Vec3 { 0.6803894, -0.021355152, 0.6121323 } },
  Triangle { Vec3 { 0.20345007, -0.06695807, 0.092085004 }, Vec3 { 0.6803894, -0.021355152, 0.6121323 }, Vec3 { 0.27417833, 0.23907787, 0.48110878 } },
  Triangle { Vec3 { -0.07937503, -0.3644755, 0.37755537 }, Vec3 { 0.20345007, -0.06695807, 0.092085004 }, Vec3 { 0.27417833, 0.23907787, 0.48110878 } },
  Triangle { Vec3 { -0.07937503, -0.3644755, 0.37755537 }, Vec3 { 0.27417833, 0.23907787, 0.48110878 }, Vec3 { -0.008646786, -0.058439553, 0.76657915 } },
  Triangle { Vec3 { -0.008646786, -0.058439553, 0.76657915 }, Vec3 { 0.27417833, 0.23907787, 0.48110878 }, Vec3 { 0.6803894, -0.021355152, 0.6121323 } },
  Triangle { Vec3 { -0.008646786, -0.058439553, 0.76657915 }, Vec3 { 0.6803894, -0.021355152, 0.6121323 }, Vec3 { 0.3975643, -0.31887257, 0.8976027 } },
  Triangle { Vec3 { -0.07937503, -0.3644755, 0.37755537 }, Vec3 { 0.32683605, -0.6249085, 0.5085789 }, Vec3 { 0.60966116, -0.3273911, 0.22310853 } },
  Triangle { Vec3 { -0.07937503, -0.3644755, 0.37755537 }, Vec3 { 0.60966116, -0.3273911, 0.22310853 }, Vec3 { 0.20345007, -0.06695807, 0.092085004 } },
  Triangle { Vec3 { -0.35355338, -0.94194174, 1.0580583 }, Vec3 { -0.70710677, -0.69194174, 0.80805826 }, Vec3 { -0.70710677, -0.33838832, 1.1616117 } },
  Triangle { Vec3 { -0.35355338, -0.94194174, 1.0580583 }, Vec3 { -0.70710677, -0.33838832, 1.1616117 }, Vec3 { -0.35355338, -0.5883883, 1.4116117 } },
  Triangle { Vec3 { 0.0, -0.69194174, 0.80805826 }, Vec3 { -0.35355338, -0.94194174, 1.0580583 }, Vec3 { -0.35355338, -0.5883883, 1.4116117 } },
  Triangle { Vec3 { 0.0, -0.69194174, 0.80805826 }, Vec3 { -0.35355338, -0.5883883, 1.4116117 }, Vec3 { 0.0, -0.33838835, 1.1616117 } },
  Triangle { Vec3 { -0.35355338, -0.44194174, 0.55805826 }, Vec3 { 0.0, -0.69194174, 0.80805826 }, Vec3 { 0.0, -0.33838835, 1.1616117 } },
  Triangle { Vec3 { -0.35355338, -0.44194174, 0.55805826 }, Vec3 { 0.0, -0.33838835, 1.1616117 }, Vec3 { -0.35355338, -0.08838835, 0.9116117 } },
  Triangle { Vec3 { -0.70710677, -0.69194174, 0.80805826 }, Vec3 { -0.35355338, -0.44194174, 0.55805826 }, Vec3 { -0.35355338, -0.08838835, 0.9116117 } },
  Triangle { Vec3 { -0.70710677, -0.69194174, 0.80805826 }, Vec3 { -0.35355338, -0.08838835, 0.9116117 }, Vec3 { -0.70710677, -0.33838832, 1.1616117 } },
  Triangle { Vec3 { -0.70710677, -0.33838832, 1.1616117 }, Vec3 { -0.35355338, -0.08838835, 0.9116117 }, Vec3 { 0.0, -0.33838835, 1.1616117 } },
  Triangle { Vec3 { -0.70710677, -0.33838832, 1.1616117 }, Vec3 { 0.0, -0.33838835, 1.1616117 }, Vec3 { -0.35355338, -0.5883883, 1.4116117 } },
  Triangle { Vec3 { -0.70710677, -0.69194174, 0.80805826 }, Vec3 { -0.35355338, -0.94194174, 1.0580583 }, Vec3 { 0.0, -0.69194174, 0.80805826 } },
  Triangle { Vec3 { -0.70710677, -0.69194174, 0.80805826 }, Vec3 { 0.0, -0.69194174, 0.80805826 }, Vec3 { -0.35355338, -0.44194174, 0.55805826 } },
  Triangle { Vec3 { -5.303301, 0.53033006, 1.5303301 }, Vec3 { 0.0, -3.2196698, 5.2803297 }, Vec3 { 5.303301, 0.53033006, 1.5303301 } },
  Triangle { Vec3 { -5.303301, 0.53033006, 1.5303301 }, Vec3 { 5.303301, 0.53033006, 1.5303301 }, Vec3 { 0.0, 4.2803297, -2.2196698 } },
};

Material mats[] {
  Material { Vec3 { 0.9607843, 0.89411765, 0.0 }, Vec3 { 0.9607843, 0.89411765, 0.0 } },
  Material { Vec3 { 0.9607843, 0.89411765, 0.0 }, Vec3 { 0.9607843, 0.89411765, 0.0 } },
  Material { Vec3 { 0.9607843, 0.89411765, 0.0 }, Vec3 { 0.9607843, 0.89411765, 0.0 } },
  Material { Vec3 { 0.9607843, 0.89411765, 0.0 }, Vec3 { 0.9607843, 0.89411765, 0.0 } },
  Material { Vec3 { 0.9607843, 0.89411765, 0.0 }, Vec3 { 0.9607843, 0.89411765, 0.0 } },
  Material { Vec3 { 0.9607843, 0.89411765, 0.0 }, Vec3 { 0.9607843, 0.89411765, 0.0 } },
  Material { Vec3 { 0.9607843, 0.89411765, 0.0 }, Vec3 { 0.9607843, 0.89411765, 0.0 } },
  Material { Vec3 { 0.9607843, 0.89411765, 0.0 }, Vec3 { 0.9607843, 0.89411765, 0.0 } },
  Material { Vec3 { 0.9607843, 0.89411765, 0.0 }, Vec3 { 0.9607843, 0.89411765, 0.0 } },
  Material { Vec3 { 0.9607843, 0.89411765, 0.0 }, Vec3 { 0.9607843, 0.89411765, 0.0 } },
  Material { Vec3 { 0.9607843, 0.89411765, 0.0 }, Vec3 { 0.9607843, 0.89411765, 0.0 } },
  Material { Vec3 { 0.9607843, 0.89411765, 0.0 }, Vec3 { 0.9607843, 0.89411765, 0.0 } },
  Material { Vec3 { 0.26666668, 0.89411765, 0.92156863 }, Vec3 { 0.1254902, 0.6784314, 0.5882353 } },
  Material { Vec3 { 0.26666668, 0.89411765, 0.92156863 }, Vec3 { 0.1254902, 0.6784314, 0.5882353 } },
  Material { Vec3 { 0.26666668, 0.89411765, 0.92156863 }, Vec3 { 0.1254902, 0.6784314, 0.5882353 } },
  Material { Vec3 { 0.26666668, 0.89411765, 0.92156863 }, Vec3 { 0.1254902, 0.6784314, 0.5882353 } },
  Material { Vec3 { 0.26666668, 0.89411765, 0.92156863 }, Vec3 { 0.1254902, 0.6784314, 0.5882353 } },
  Material { Vec3 { 0.26666668, 0.89411765, 0.92156863 }, Vec3 { 0.1254902, 0.6784314, 0.5882353 } },
  Material { Vec3 { 0.26666668, 0.89411765, 0.92156863 }, Vec3 { 0.1254902, 0.6784314, 0.5882353 } },
  Material { Vec3 { 0.26666668, 0.89411765, 0.92156863 }, Vec3 { 0.1254902, 0.6784314, 0.5882353 } },
  Material { Vec3 { 0.26666668, 0.89411765, 0.92156863 }, Vec3 { 0.1254902, 0.6784314, 0.5882353 } },
  Material { Vec3 { 0.26666668, 0.89411765, 0.92156863 }, Vec3 { 0.1254902, 0.6784314, 0.5882353 } },
  Material { Vec3 { 0.26666668, 0.89411765, 0.92156863 }, Vec3 { 0.1254902, 0.6784314, 0.5882353 } },
  Material { Vec3 { 0.26666668, 0.89411765, 0.92156863 }, Vec3 { 0.1254902, 0.6784314, 0.5882353 } },
  Material { Vec3 { 0.9019608, 0.19607843, 0.27450982 }, Vec3 { 0.5882353, 0.1254902, 0.21568628 } },
  Material { Vec3 { 0.9019608, 0.19607843, 0.27450982 }, Vec3 { 0.5882353, 0.1254902, 0.21568628 } },
  Material { Vec3 { 0.9019608, 0.19607843, 0.27450982 }, Vec3 { 0.5882353, 0.1254902, 0.21568628 } },
  Material { Vec3 { 0.9019608, 0.19607843, 0.27450982 }, Vec3 { 0.5882353, 0.1254902, 0.21568628 } },
  Material { Vec3 { 0.9019608, 0.19607843, 0.27450982 }, Vec3 { 0.5882353, 0.1254902, 0.21568628 } },
  Material { Vec3 { 0.9019608, 0.19607843, 0.27450982 }, Vec3 { 0.5882353, 0.1254902, 0.21568628 } },
  Material { Vec3 { 0.9019608, 0.19607843, 0.27450982 }, Vec3 { 0.5882353, 0.1254902, 0.21568628 } },
  Material { Vec3 { 0.9019608, 0.19607843, 0.27450982 }, Vec3 { 0.5882353, 0.1254902, 0.21568628 } },
  Material { Vec3 { 0.9019608, 0.19607843, 0.27450982 }, Vec3 { 0.5882353, 0.1254902, 0.21568628 } },
  Material { Vec3 { 0.9019608, 0.19607843, 0.27450982 }, Vec3 { 0.5882353, 0.1254902, 0.21568628 } },
  Material { Vec3 { 0.9019608, 0.19607843, 0.27450982 }, Vec3 { 0.5882353, 0.1254902, 0.21568628 } },
  Material { Vec3 { 0.9019608, 0.19607843, 0.27450982 }, Vec3 { 0.5882353, 0.1254902, 0.21568628 } },
  Material { Vec3 { 1.0, 1.0, 1.0 }, Vec3 { 0.0, 0.0, 0.0 } },
  Material { Vec3 { 1.0, 1.0, 1.0 }, Vec3 { 0.0, 0.0, 0.0 } },
};



extern "C" bool traverse(const Ray& ray, u32 depth, Vec3& color);
extern "C" bool trace(const Ray& ray, u32 itri, u32 depth, Vec3& color);

extern "C" bool traverse(const Ray& ray, u32 depth, Vec3& color) {
  const u32 NTRI = sizeof(mats) / sizeof(Material);
  for (u32 itri = 0; itri < NTRI; ++itri) {
    if (trace(ray, itri, depth, color)) { return true; }
  }
  return false;
}

extern "C" bool trace(const Ray& ray, u32 itri, u32 depth, Vec3& color) {
  const Triangle& tri = tris[itri];

  // Check for hit.
  Vec3 x = tri.b - tri.a;
  Vec3 y = tri.c - tri.a;
  Vec3 n = normalized(cross(y, x));

  Vec3 dtriray = ray.o - tri.a;
  f32 r1 = dot(dtriray, n);
  f32 r2 = dot(ray.v, n);

  if ((r1 * r2) >= 0.0f) { return false; }

  Vec3 hit_pt = ray.o - ray.v * r1 / r2;

  Vec3 p = hit_pt - tri.a;
  f32 d00 = dot(x, x);
  f32 d01 = dot(x, y);
  f32 d11 = dot(y, y);
  f32 d20 = dot(p, x);
  f32 d21 = dot(p, y);

  f32 denom = d00 * d11 - d01 * d01;
  f32 u = (d11 * d20 - d01 * d21) / denom;
  f32 v = (d00 * d21 - d01 * d20) / denom;

  if (u < 0.0f || v < 0.0f || 1.0f < u + v) { return false; }

  // Calculate light.
  const u32 NRAY = 16;
  const Vec3 AMBIENT { 0.2f, 0.2f, 0.2f };
  const f32 F0 = 0.04f;

  p = tri.a + u * x + v * y;
  Vec3 refl = -reflect(ray.v, n);
  Ray refl_ray = Ray { p, normalized(refl) };

  if (depth < 1) {
    // Lighting.
    Vec3 specular {};
    traverse(refl_ray, depth + 1, specular);
    Vec3 diffuse {};
    for (u32 i = 0; i < NRAY; ++i) {
      const f32 TWO_PI = 6.283185307179586476925286766559f;

      f32 a = random();
      f32 b = random();

      f32 r = sqrt(1.0f - a * a);
      f32 theta = b * TWO_PI;
      f32 sin_theta = sin(theta);
      f32 cos_theta = cos(theta);
      Vec3 dir { r * sin_theta, r * cos_theta, a };

      Ray diffuse_ray { p, normalized(dir) };
      Vec3 diffuse_contribute {};
      if (traverse(diffuse_ray, depth + 1, diffuse_contribute)) {
        diffuse = diffuse + diffuse_contribute;
      }
    }
    diffuse = diffuse / (f32)NRAY;

    color = mats[itri].emit + mats[itri].albedo * (diffuse + specular * F0);
  } else {
    color = mats[itri].emit + AMBIENT;
  }
  return true;
}

extern "C" u32 ray_gen(u32 w, u32 h, u32 edge) {
  f32 x = ((f32)w) / ((f32)edge / 2.0f) - 1.0f;
  f32 y = ((f32)h) / ((f32)edge / 2.0f) - 1.0f;

  Ray ray {
      Vec3 { x, y, 0.0f },
      Vec3 { 0.0f, 0.0f, 10.0f },
  };

  Vec3 color {};
  if (traverse(ray, 0, color)) {
      return pack_unorm4_rgba(color);
  } else {
      return 0xff000000;
  }
}

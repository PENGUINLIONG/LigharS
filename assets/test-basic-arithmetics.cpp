typedef float f32;
typedef unsigned int u32;
typedef int i32;

extern "C" u32 test_fadd(u32 a, u32 b) {
  f32 a2 = a + 0.5f;
  f32 b2 = b + 0.5f;
  u32 rv = a2 + b2;
  return rv;
}

extern "C" u32 test_add(u32 a, u32 b) {
  u32 rv = a + b;
  return rv;
}

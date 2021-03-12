typedef float f32;
typedef unsigned int u32;
typedef int i32;

// The following fp ops are tested with input of a=2, b=3.
extern "C" u32 test_fadd(u32 a, u32 b) {
  f32 a2 = a + 0.5f;
  f32 b2 = b + 0.5f;
  u32 rv = a2 + b2;
  return rv;
}
extern "C" u32 test_fsub(u32 a, u32 b) {
  f32 a2 = a + 0.5f;
  f32 b2 = b - 0.5f;
  u32 rv = a2 + b2;
  return rv;
}
extern "C" u32 test_fmul(u32 a, u32 b) {
  f32 a2 = a;
  f32 b2 = b + 0.5f;
  u32 rv = a2 * b2;
  return rv;
}
extern "C" u32 test_fdiv(u32 a, u32 b) {
  f32 a2 = a + 4.0f;
  f32 b2 = b;
  u32 rv = a2 / b2;
  return rv;
}

extern "C" u32 test_flt(u32 a, u32 b) {
  return a < b ? 1 : 0;
}
extern "C" u32 test_fle(u32 a, u32 b) {
  return a <= b ? 1 : 0;
}
extern "C" u32 test_feq(u32 a, u32 b) {
  return a == b ? 1 : 0;
}

extern "C" u32 test_add(u32 a, u32 b) {
  u32 rv = a + b;
  return rv;
}

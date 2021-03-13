typedef float f32;
typedef unsigned int u32;

extern "C" u32 test_lt(u32 a, u32 b) {
    return (f32)a < (f32)b ? 1 : 0;
}


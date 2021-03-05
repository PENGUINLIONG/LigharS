typedef float f32;
typedef unsigned int u32;
typedef int i32;

// Test with base=2, pow=4; should get 16. Remember to disable optimization
// otherwise it's degraded into a loop.
extern "C" u32 recurse_pow(u32 base, u32 pow) {
    if (pow == 0) {
        return 1;
    } else {
        return recurse_pow(base, pow - 1) * base;
    }
}

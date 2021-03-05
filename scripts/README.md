# Scripts

This directory contains scripts and script notebook that might be helpful in analysis and compilation of LigharS programs.

## Shader Compilation

Script file: `scripts/compile-shader.py`

LigharS shaders are compiler on per-thread basis. Use the following script to generate thread program with argument built-in:

```bash
compile-shader.py SOURCE_NAME ENTRY_POINT [ARG1] [ARG2] ...
```

Source name is the C++ file name in `assets` directory with extension stripped. The specified entry point function must be declared with `extern "C"` to disable symbol mangling. Unset arguments are zeroed by default and over-setting arguments will not trigger any error.

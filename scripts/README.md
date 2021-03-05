# Scripts

This directory contains scripts and script notebook that might be helpful in analysis and compilation of LigharS programs.

## Shader Compilation

Script file: `scripts/compile-shader.py`

LigharS shaders are compiler on per-thread basis. Use the following script to generate thread program with argument built-in:

```bash
compile-shader.py ARG1 ARG2 ...
```

Currently the thread program must have a entry-point called `ray_gen` without symbol mangling. Unset arguments are zeroed by default and over-setting arguments will not trigger any error.

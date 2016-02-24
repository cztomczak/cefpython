Patch to fix tcmalloc issue on Linux:
https://github.com/cztomczak/cefpython/issues/73

You have two options:
1. Copy `include.gypi` to `~/.gyp/`.
2. Or run the `use_allocator_none.sh` script - this will set
   the GYP_DEFINES env variable, but it will last only for
   current session.

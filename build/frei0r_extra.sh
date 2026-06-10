#!/bin/bash
# Custom build hooks for frei0r, sourced automatically by the suite's
# check_custom_patches (media-suite_helper.sh) when frei0r-git is built.
#
# frei0r's SSE4.1 code (src/filter/tint0r/tint0r.c) relies on implicit
# conversions between the __m128 and __m128i vector types. clang accepts
# those by default; MSYS2's GCC 16 rejects them:
#   error: incompatible type for argument 2 of '_mm_storeu_si128'
# -flax-vector-conversions makes GCC accept the same vector bit-casts.
#
# Note: the suite runs these hooks through log(), i.e. inside a pipeline
# subshell, so exporting CFLAGS here never reaches the cmake invocation
# (verified: an earlier version of this hook did exactly that and the flag
# was not applied). Editing a file does persist, so inject the flag into
# frei0r's CMakeLists.txt instead. extra_script runs this hook with the
# frei0r checkout as the working directory.

_pre_cmake() {
    grep -q 'flax-vector-conversions' CMakeLists.txt ||
        sed -i '/^project\s*(/a add_compile_options(-flax-vector-conversions)' CMakeLists.txt
    grep -q 'flax-vector-conversions' CMakeLists.txt ||
        echo "frei0r_extra.sh: WARNING: could not inject -flax-vector-conversions (project() line not found?)"
}

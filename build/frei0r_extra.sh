#!/bin/bash
# Custom build hooks for frei0r, sourced automatically by the suite's
# check_custom_patches (media-suite_helper.sh) when frei0r-git is built.
#
# The suite compiles everything with -march=haswell, which defines
# __SSE4_1__ and activates frei0r's SSE4.1 path (src/filter/tint0r/
# tint0r.c). That code mixes the __m128 and __m128i vector types and does
# not compile with MSYS2's GCC 16:
#   error: incompatible type for argument 2 of '_mm_storeu_si128'
# Build frei0r only with a generic architecture instead, so __SSE4_1__ is
# never defined and the scalar fallback is used. GCC honors the last
# -march flag, so appending -march=x86-64 -mtune=generic overrides the
# suite's -march=haswell for this package alone. (-march=generic is not
# valid GCC syntax; generic is only accepted for -mtune.)
#
# Note: the suite runs these hooks through log(), i.e. inside a pipeline
# subshell, so exporting CFLAGS here never reaches the cmake invocation
# (verified: an earlier version of this hook did exactly that and the flag
# was not applied). Editing a file does persist, so inject the flags into
# frei0r's CMakeLists.txt instead - add_compile_options() applies after
# CMAKE_C_FLAGS, regardless of the toolchain file. extra_script runs this
# hook with the frei0r checkout as the working directory.

_pre_cmake() {
    grep -q 'mtune=generic' CMakeLists.txt ||
        sed -i '/^project\s*(/a add_compile_options(-march=x86-64 -mtune=generic)' CMakeLists.txt
    grep -q 'mtune=generic' CMakeLists.txt ||
        echo "frei0r_extra.sh: WARNING: could not inject -march override (project() line not found?)"
}
